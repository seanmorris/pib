<?php
declare(strict_types=1);

/**
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace DebugKit;

use Cake\Core\Configure;
use Cake\Core\Exception\CakeException;
use Cake\Core\InstanceConfigTrait;
use Cake\Core\Plugin as CorePlugin;
use Cake\Datasource\Exception\MissingDatasourceConfigException;
use Cake\Event\EventManager;
use Cake\Http\ServerRequest;
use Cake\Log\Log;
use Cake\ORM\Locator\LocatorAwareTrait;
use Cake\Routing\Router;
use DebugKit\Model\Entity\Request;
use DebugKit\Panel\PanelRegistry;
use Exception;
use Psr\Http\Message\ResponseInterface;
use function Cake\Core\env;

/**
 * Used to create the panels and inject a toolbar into
 * matching responses.
 *
 * Used by the Routing Filter and Middleware.
 */
class ToolbarService
{
    use InstanceConfigTrait;
    use LocatorAwareTrait;

    /**
     * The panel registry.
     *
     * @var \DebugKit\Panel\PanelRegistry
     */
    protected PanelRegistry $registry;

    /**
     * Default configuration.
     *
     * @var array
     */
    protected array $_defaultConfig = [
        'panels' => [
            'DebugKit.Cache' => true,
            'DebugKit.Session' => true,
            'DebugKit.Request' => true,
            'DebugKit.SqlLog' => true,
            'DebugKit.Timer' => true,
            'DebugKit.Log' => true,
            'DebugKit.Variables' => true,
            'DebugKit.Environment' => true,
            'DebugKit.Include' => true,
            'DebugKit.History' => true,
            'DebugKit.Routes' => true,
            'DebugKit.Packages' => true,
            'DebugKit.Mail' => true,
            'DebugKit.Deprecations' => true,
        ],
        'forceEnable' => false,
        'safeTld' => [],
        'ignorePathsPattern' => null,
    ];

    /**
     * Constructor
     *
     * @param \Cake\Event\EventManager $events The event manager to use defaults to the global manager
     * @param array $config The configuration data for DebugKit.
     */
    public function __construct(EventManager $events, array $config)
    {
        $this->setConfig($config);
        $this->registry = new PanelRegistry($events);
    }

    /**
     * Fetch the PanelRegistry
     *
     * @return \DebugKit\Panel\PanelRegistry
     */
    public function registry(): PanelRegistry
    {
        return $this->registry;
    }

    /**
     * Check whether or not debug kit is enabled.
     *
     * @return bool
     */
    public function isEnabled(): bool
    {
        if (!isset($GLOBALS['FORCE_DEBUGKIT_TOOLBAR'])) {
            $GLOBALS['FORCE_DEBUGKIT_TOOLBAR'] = false;
        }
        if (
            defined('PHPUNIT_COMPOSER_INSTALL') &&
            !$GLOBALS['FORCE_DEBUGKIT_TOOLBAR']
        ) {
            return false;
        }
        $enabled = (bool)Configure::read('debug')
                && !$this->isSuspiciouslyProduction()
                && php_sapi_name() !== 'phpdbg';

        if ($enabled) {
            return true;
        }
        $force = $this->getConfig('forceEnable');
        if (is_callable($force)) {
            return $force();
        }

        return $force;
    }

    /**
     * Returns true if this application is being executed on a domain with a TLD
     * that is commonly associated with a production environment, or if the IP
     * address is not in a private or reserved range.
     *
     * Private  IPv4 = 10.0.0.0/8, 172.16.0.0/12 and 192.168.0.0/16
     * Reserved IPv4 = 0.0.0.0/8, 169.254.0.0/16, 127.0.0.0/8 and 240.0.0.0/4
     *
     * Private  IPv6 = fc00::/7
     * Reserved IPv6 = ::1/128, ::/128, ::ffff:0:0/96 and fe80::/10
     *
     * @return bool
     */
    protected function isSuspiciouslyProduction(): bool
    {
        $host = parse_url('http://' . env('HTTP_HOST'), PHP_URL_HOST);
        if ($host === false || $host === null) {
            return false;
        }

        // IPv6 addresses in URLs are enclosed in brackets. Remove them.
        $host = trim($host, '[]');

        // Check if the host is a private or reserved IPv4/6 address.
        $isIp = filter_var($host, FILTER_VALIDATE_IP) !== false;
        if ($isIp) {
            $flags = FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE;

            return filter_var($host, FILTER_VALIDATE_IP, $flags) !== false;
        }

        // So it's not an IP address. It must be a domain name.
        $parts = explode('.', $host);
        if (count($parts) == 1) {
            return false;
        }

        // Check if the TLD is in the list of safe TLDs.
        $tld = end($parts);
        $safeTlds = ['localhost', 'invalid', 'test', 'example', 'local'];
        $safeTlds = array_merge($safeTlds, (array)$this->getConfig('safeTld'));

        if (in_array($tld, $safeTlds, true)) {
            return false;
        }

        // Don't log a warning if forceEnable is set.
        if (!$this->getConfig('forceEnable')) {
            $safeList = implode(', ', $safeTlds);
            Log::warning(
                "DebugKit is disabling itself as your host `{$host}` " .
                "is not in the known safe list of top-level-domains ({$safeList}). " .
                'If you would like to force DebugKit on use the `DebugKit.forceEnable` Configure option.'
            );
        }

        return true;
    }

    /**
     * Get the list of loaded panels
     *
     * @return array
     */
    public function loadedPanels(): array
    {
        return $this->registry->loaded();
    }

    /**
     * Get the a loaded panel
     *
     * @param string $name The name of the panel you want to get.
     * @return \DebugKit\DebugPanel|null The panel or null.
     */
    public function panel(string $name): ?DebugPanel
    {
        return $this->registry->{$name};
    }

    /**
     * Load all the panels being used
     *
     * @return void
     */
    public function loadPanels(): void
    {
        foreach ($this->getConfig('panels') as $panel => $enabled) {
            [$panel, $enabled] = is_numeric($panel) ? [$enabled, true] : [$panel, $enabled];
            if ($enabled) {
                $this->registry->load($panel);
            }
        }
    }

    /**
     * Call the initialize method onl all the loaded panels.
     *
     * @return void
     */
    public function initializePanels(): void
    {
        foreach ($this->registry->loaded() as $panel) {
            $this->registry->{$panel}->initialize();
        }
    }

    /**
     * Save the toolbar state.
     *
     * @param \Cake\Http\ServerRequest $request The request
     * @param \Psr\Http\Message\ResponseInterface $response The response
     * @return \DebugKit\Model\Entity\Request|false Saved request data.
     */
    public function saveData(ServerRequest $request, ResponseInterface $response): Request|false
    {
        $path = $request->getUri()->getPath();
        $dashboardUrl = '/debug-kit';
        if (strpos($path, 'debug_kit') !== false || strpos($path, 'debug-kit') !== false) {
            if (!($path === $dashboardUrl || $path === $dashboardUrl . '/')) {
                // internal debug-kit request
                return false;
            }
            // debug-kit dashboard, save request and show toolbar
        }

        $ignorePathsPattern = $this->getConfig('ignorePathsPattern');
        $statusCode = $response->getStatusCode();
        if (
            $ignorePathsPattern &&
            $statusCode >= 200 &&
            $statusCode <= 299 &&
            preg_match($ignorePathsPattern, $path)
        ) {
            return false;
        }

        $data = [
            'url' => $request->getUri()->getPath(),
            'content_type' => $response->getHeaderLine('Content-Type'),
            'method' => $request->getMethod(),
            'status_code' => $response->getStatusCode(),
            'requested_at' => $request->getEnv('REQUEST_TIME'),
            'panels' => [],
        ];
        try {
            /** @var \DebugKit\Model\Table\RequestsTable $requests */
            $requests = $this->fetchTable('DebugKit.Requests');
            $requests->gc();
        } catch (MissingDatasourceConfigException $e) {
            Log::warning(
                'Unable to save request. Check your debug_kit datasource connection ' .
                'or ensure that PDO SQLite extension is enabled.'
            );
            Log::warning($e->getMessage());

            return false;
        }

        $row = $requests->newEntity($data);
        $row->setNew(true);

        foreach ($this->registry->loaded() as $name) {
            $panel = $this->registry->{$name};
            try {
                $content = serialize($panel->data());
            } catch (Exception $e) {
                $content = serialize([
                    'error' => $e->getMessage(),
                ]);
            }
            $row->panels[] = $requests->Panels->newEntity([
                'panel' => $name,
                'element' => $panel->elementName(),
                'title' => $panel->title(),
                'summary' => $panel->summary(),
                'content' => $content,
            ]);
        }

        try {
            return $requests->save($row);
        } catch (CakeException $e) {
            Log::warning('Unable to save request. This is probably due to concurrent requests.');
            Log::warning($e->getMessage());
        }

        return false;
    }

    /**
     * Reads the modified date of a file in the webroot, and returns the integer
     *
     * @return string
     */
    public function getToolbarUrl(): string
    {
        $url = 'js/inject-iframe.js';
        $filePaths = [
            str_replace('/', DIRECTORY_SEPARATOR, WWW_ROOT . 'debug_kit/' . $url),
            str_replace('/', DIRECTORY_SEPARATOR, CorePlugin::path('DebugKit') . 'webroot/' . $url),
        ];
        $url = '/debug_kit/' . $url;
        foreach ($filePaths as $filePath) {
            if (file_exists($filePath)) {
                return $url . '?' . filemtime($filePath);
            }
        }

        return $url;
    }

    /**
     * Injects the JS to build the toolbar.
     *
     * The toolbar will only be injected if the response's content type
     * contains HTML and there is a </body> tag.
     *
     * @param \DebugKit\Model\Entity\Request $row The request data to inject.
     * @param \Psr\Http\Message\ResponseInterface $response The response to augment.
     * @return \Psr\Http\Message\ResponseInterface The modified response
     */
    public function injectScripts(Request $row, ResponseInterface $response): ResponseInterface
    {
        $response = $response->withHeader('X-DEBUGKIT-ID', (string)$row->id);
        if (strpos($response->getHeaderLine('Content-Type'), 'html') === false) {
            return $response;
        }
        $body = $response->getBody();
        if (!$body->isSeekable() || !$body->isWritable()) {
            return $response;
        }
        $body->rewind();
        $contents = $body->getContents();

        $pos = strrpos($contents, '</body>');
        if ($pos === false) {
            return $response;
        }
        // Use Router to get the request so that we can see the
        // state after other middleware have been applied.
        $request = Router::getRequest();
        $nonce = '';
        if ($request && $request->getAttribute('cspScriptNonce')) {
            $nonce = sprintf(' nonce="%s"', $request->getAttribute('cspScriptNonce'));
        }

        $url = Router::url('/', true);
        $script = sprintf(
            '<script id="__debug_kit_script" data-id="%s" data-url="%s" type="module" src="%s"%s></script>',
            $row->id,
            $url,
            Router::url($this->getToolbarUrl()),
            $nonce
        );
        $contents = substr($contents, 0, $pos) . $script . substr($contents, $pos);
        $body->rewind();
        $body->write($contents);

        return $response->withBody($body);
    }
}
