<?php
declare(strict_types=1);

namespace Cake\Test\TestCase\Composer;

use Cake\Composer\Plugin;
use Composer\Composer;
use Composer\Config;
use Composer\IO\IOInterface;
use Composer\Package\Package;
use Composer\Package\RootPackage;
use Composer\Repository\RepositoryManager;
use Composer\Script\Event;
use Composer\Util\HttpDownloader;
use PHPUnit\Framework\TestCase;

class PluginTest extends TestCase
{
    protected Composer $composer;

    protected Package $package;

    /**
     * @var \Composer\IO\IOInterface&\PHPUnit\Framework\MockObject\MockObject
     */
    protected $io;

    protected Plugin $plugin;

    /**
     * Directories used during tests
     *
     * @var array<string>
     */
    protected array $testDirs = [
        'vendor',
        'plugins/Foo',
        'plugins/Fee/src',
        'plugins/Fee/tests',
        'plugins/Foe/src',
        'plugins/Fum',
        'app_plugins/Bar/src',
        'app_plugins/Bar/tests',
    ];

    protected string $path;

    /**
     * setUp
     *
     * @return void
     */
    public function setUp(): void
    {
        parent::setUp();

        $this->package = new Package('cake/plugin', '1.0', '1.0');
        $this->package->setType('cakephp-plugin');

        $this->path = sys_get_temp_dir() . DIRECTORY_SEPARATOR . 'plugin-installer-test';

        foreach ($this->testDirs as $dir) {
            if (!is_dir($this->path . '/' . $dir)) {
                mkdir($this->path . '/' . $dir, 0777, true);
            }
        }

        $this->composer = new Composer();
        $config = new Config();
        $config->merge([
            'config' => [
                'vendor-dir' => $this->path . '/vendor',
            ],
        ]);

        $this->composer->setConfig($config);

        /** @var \Composer\IO\IOInterface&\PHPUnit\Framework\MockObject\MockObject $io */
        $io = $this->getMockBuilder(IOInterface::class)->getMock();
        $this->io = $io;

        $httpDownloader = new HttpDownloader($this->io, $config);

        $rm = new RepositoryManager(
            $this->io,
            $config,
            $httpDownloader
        );
        $this->composer->setRepositoryManager($rm);

        $this->plugin = new Plugin();
    }

    public function tearDown(): void
    {
        parent::tearDown();

        if (PHP_OS === 'Windows') {
            exec(sprintf('rd /s /q %s', escapeshellarg($this->path)));
        } else {
            exec(sprintf('rm -rf %s', escapeshellarg($this->path)));
        }
    }

    public function testGetSubscribedEvents()
    {
        $expected = [
            'post-autoload-dump' => 'postAutoloadDump',
            'pre-autoload-dump' => 'preAutoloadDump',
        ];

        $this->assertSame($expected, $this->plugin->getSubscribedEvents());
    }

    public function testGetConfigFilePath()
    {
        $path = $this->plugin->getConfigFilePath('');
        $this->assertFileExists(dirname($path));
    }

    public function testPreAutoloadDump()
    {
        $package = new RootPackage('App', '1.0.0', '1.0.0');
        $package->setExtra([
            'plugin-paths' => [
                'app_plugins',
                'plugins',
            ],
        ]);
        $package->setAutoload([
            'psr-4' => [
                'Foo\\' => 'xyz/Foo/src',
            ],
        ]);
        $package->setDevAutoload([
            'psr-4' => [
                'Foo\Test\\' => 'xyz/Foo/tests',
            ],
        ]);
        $this->composer->setPackage($package);

        $event = new Event('', $this->composer, $this->io);

        $this->plugin->preAutoloadDump($event);

        $expected = [
            'psr-4' => [
                'Foo\\' => 'xyz/Foo/src',
                'Fee\\' => 'plugins/Fee/src',
                'Foe\\' => 'plugins/Foe/src',
                'Bar\\' => 'app_plugins/Bar/src',
            ],
        ];
        $this->assertEquals($expected, $package->getAutoload());

        $expected = [
            'psr-4' => [
                'Foo\Test\\' => 'xyz/Foo/tests',
                'Fee\Test\\' => 'plugins/Fee/tests',
                'Bar\Test\\' => 'app_plugins/Bar/tests',
            ],
        ];
        $this->assertEquals($expected, $package->getDevAutoload());
    }

    public function testPreAutoloadDumpNonExistentPluginPaths()
    {
        $package = new RootPackage('App', '1.0.0', '1.0.0');
        $package->setExtra([
            'plugin-paths' => [
                'unknown_folder',
            ],
        ]);
        $package->setAutoload([
            'psr-4' => [
                'Foo\\' => 'xyz/Foo/src',
            ],
        ]);
        $package->setDevAutoload([
            'psr-4' => [
                'Foo\Test\\' => 'xyz/Foo/tests',
            ],
        ]);
        $this->composer->setPackage($package);

        $event = new Event('', $this->composer, $this->io);

        $this->plugin->preAutoloadDump($event);

        $expected = [
            'psr-4' => [
                'Foo\\' => 'xyz/Foo/src',
            ],
        ];
        $this->assertEquals($expected, $package->getAutoload());

        $expected = [
            'psr-4' => [
                'Foo\Test\\' => 'xyz/Foo/tests',
            ],
        ];
        $this->assertEquals($expected, $package->getDevAutoload());
    }

    public function testGetPrimaryNamespace()
    {
        $autoload = [
            'psr-4' => [
                'FOC\\Authenticate' => '',
            ],
        ];
        $this->package->setAutoload($autoload);

        $ns = $this->plugin->getPrimaryNamespace($this->package);
        $this->assertEquals('FOC\Authenticate', $ns);

        $autoload = [
            'psr-4' => [
                'FOC\Acl\Test' => './tests',
                'FOC\Acl' => '',
            ],
        ];
        $this->package->setAutoload($autoload);
        $ns = $this->plugin->getPrimaryNamespace($this->package);
        $this->assertEquals('FOC\Acl', $ns);

        $autoload = [
            'psr-4' => [
                'Foo\Bar' => 'foo',
                'Acme\Plugin' => './src',
            ],
        ];
        $this->package->setAutoload($autoload);
        $ns = $this->plugin->getPrimaryNamespace($this->package);
        $this->assertEquals('Acme\Plugin', $ns);

        $autoload = [
            'psr-4' => [
                'Foo\Bar' => 'bar',
                'Foo\\' => '',
            ],
        ];
        $this->package->setAutoload($autoload);
        $ns = $this->plugin->getPrimaryNamespace($this->package);
        $this->assertEquals('Foo', $ns);

        $autoload = [
            'psr-4' => [
                'Foo\Bar' => 'bar',
                'Foo' => '.',
            ],
        ];
        $this->package->setAutoload($autoload);
        $ns = $this->plugin->getPrimaryNamespace($this->package);
        $this->assertEquals('Foo', $ns);

        $autoload = [
            'psr-4' => [
                'Acme\Foo\Bar' => 'bar',
                'Acme\Foo\\' => '',
            ],
        ];
        $this->package->setAutoload($autoload);
        $ns = $this->plugin->getPrimaryNamespace($this->package);
        $this->assertEquals('Acme\Foo', $ns);

        $autoload = [
            'psr-4' => [
                'Acme\Foo\Bar' => '',
                'Acme\Foo' => 'src',
            ],
        ];
        $this->package->setAutoload($autoload);
        $name = $this->plugin->getPrimaryNamespace($this->package);
        $this->assertEquals('Acme\Foo', $name);
    }

    public function testFindPlugins()
    {
        $plugin1 = new Package('cakephp/the-thing', '1.0', '1.0');
        $plugin1->setType('cakephp-plugin');
        $plugin1->setAutoload([
            'psr-4' => [
                'TheThing' => 'src/',
            ],
        ]);

        $plugin2 = new Package('cakephp/princess', '1.0', '1.0');
        $plugin2->setType('cakephp-plugin');
        $plugin2->setAutoload([
            'psr-4' => [
                'Princess' => 'src/',
            ],
        ]);

        $packages = [
            $plugin1,
            new Package('SomethingElse', '1.0', '1.0'),
            $plugin2,
        ];

        $return = $this->plugin->findPlugins(
            $packages,
            [$this->path . '/doesnt-exist'],
            $this->path . '/vendor'
        );

        $expected = [
            'Princess' => $this->path . '/vendor/cakephp/princess',
            'TheThing' => $this->path . '/vendor/cakephp/the-thing',
        ];
        $this->assertSame($expected, $return, 'Only composer-loaded plugins should be listed');

        $return = $this->plugin->findPlugins(
            $packages,
            [$this->path . '/plugins'],
            $this->path . '/vendor'
        );

        $expected = [
            'Fee' => $this->path . '/plugins/Fee',
            'Foe' => $this->path . '/plugins/Foe',
            'Foo' => $this->path . '/plugins/Foo',
            'Fum' => $this->path . '/plugins/Fum',
            'Princess' => $this->path . '/vendor/cakephp/princess',
            'TheThing' => $this->path . '/vendor/cakephp/the-thing',
        ];
        $this->assertSame($expected, $return, 'Composer and application plugins should be listed');

        $return = $this->plugin->findPlugins(
            $packages,
            [$this->path . '/plugins', $this->path . '/app_plugins'],
            $this->path . '/vendor'
        );

        $expected = [
            'Bar' => $this->path . '/app_plugins/Bar',
            'Fee' => $this->path . '/plugins/Fee',
            'Foe' => $this->path . '/plugins/Foe',
            'Foo' => $this->path . '/plugins/Foo',
            'Fum' => $this->path . '/plugins/Fum',
            'Princess' => $this->path . '/vendor/cakephp/princess',
            'TheThing' => $this->path . '/vendor/cakephp/the-thing',
        ];
        $this->assertSame($expected, $return, 'Composer and application plugins should be listed');
    }

    public function testWriteConfigFile()
    {
        $plugins = [
            'Fee' => $this->path . '/plugins/Fee',
            'Foe' => $this->path . '/plugins/Foe',
            'Foo' => $this->path . '/plugins/Foo',
            'Fum' => $this->path . '/plugins/Fum',
            'OddOneOut' => '/some/other/path',
            'Princess' => $this->path . '/vendor/cakephp/princess',
            'TheThing' => $this->path . '/vendor/cakephp/the-thing',
            'Vendor\Plugin' => $this->path . '/vendor/vendor/plugin',
        ];

        $path = $this->path . '/vendor/cakephp-plugins.php';
        $this->plugin->writeConfigFile($path, $plugins);

        $this->assertFileExists($path);
        $contents = file_get_contents($path);

        $this->assertStringContainsString('<?php', $contents);
        $this->assertStringContainsString('$baseDir = dirname(dirname(__FILE__));', $contents);
        $this->assertStringContainsString(
            "'Fee' => \$baseDir . '/plugins/Fee/'",
            $contents,
            'paths should be relative for app-plugins'
        );
        $this->assertStringContainsString(
            "'Princess' => \$baseDir . '/vendor/cakephp/princess/'",
            $contents,
            'paths should be relative for vendor-plugins'
        );
        $this->assertStringContainsString(
            "'OddOneOut' => '/some/other/path/'",
            $contents,
            'paths should stay absolute if it\'s not under the application root'
        );
        $this->assertStringContainsString(
            "'Vendor/Plugin' => \$baseDir . '/vendor/vendor/plugin/'",
            $contents,
            'Plugin namespaces should use forward slash'
        );

        // Ensure all plugin paths are slash terminated
        foreach ($plugins as &$plugin) {
            $plugin .= '/';
        }
        unset($plugin);

        $result = require $path;
        $expected = [
            'plugins' => $plugins,
        ];
        $expected['plugins']['Vendor/Plugin'] = $expected['plugins']['Vendor\Plugin'];
        unset($expected['plugins']['Vendor\Plugin']);

        $this->assertSame(
            $expected,
            $result,
            'The evaluated result should be the same as the input except for namespaced plugin'
        );
    }
}
