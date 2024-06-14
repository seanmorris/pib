<?php
declare(strict_types=1);

/**
 * CakePHP(tm) : Rapid Development Framework (https://cakephp.org)
 * Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright (c) Cake Software Foundation, Inc. (https://cakefoundation.org)
 * @link          https://cakephp.org CakePHP(tm) Project
 * @since         0.1.0
 * @license       https://www.opensource.org/licenses/mit-license.php MIT License
 */
namespace Bake\Command;

use Bake\Utility\Model\AssociationFilter;
use Bake\Utility\TableScanner;
use Cake\Console\Arguments;
use Cake\Console\ConsoleIo;
use Cake\Console\ConsoleOptionParser;
use Cake\Core\App;
use Cake\Core\Configure;
use Cake\Datasource\ConnectionManager;
use Cake\Datasource\EntityInterface;
use Cake\ORM\Table;
use Cake\Utility\Inflector;
use Cake\View\Exception\MissingTemplateException;
use Exception;
use RuntimeException;
use function Cake\Core\namespaceSplit;

/**
 * Task class for creating view template files.
 */
class TemplateCommand extends BakeCommand
{
    /**
     * Name of the controller being used
     *
     * @var string
     */
    public string $controllerName;

    /**
     * Classname of the controller being used
     *
     * @var string
     */
    public string $controllerClass;

    /**
     * Name with plugin of the model being used
     *
     * @var string
     */
    public string $modelName;

    /**
     * Actions to use for scaffolding
     *
     * @var array<string>
     */
    public array $scaffoldActions = ['index', 'view', 'add', 'edit'];

    /**
     * Actions that exclude hidden fields
     *
     * @var array<string>
     */
    public array $excludeHiddenActions = ['index', 'view'];

    /**
     * AssociationFilter utility
     *
     * @var \Bake\Utility\Model\AssociationFilter|null
     */
    protected ?AssociationFilter $_associationFilter = null;

    /**
     * Template path.
     *
     * @var string
     */
    public string $path;

    /**
     * Output extension
     *
     * @var string
     */
    public string $ext = 'php';

    /**
     * Override initialize
     *
     * @return void
     */
    public function initialize(): void
    {
        $this->path = current(App::path('templates'));
    }

    /**
     * Execute the command.
     *
     * @param \Cake\Console\Arguments $args The command arguments.
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return int|null The exit code or null for success
     */
    public function execute(Arguments $args, ConsoleIo $io): ?int
    {
        $this->extractCommonProperties($args);
        $name = $args->getArgument('name') ?? '';
        $name = $this->_getName($name);

        if (empty($name)) {
            $io->out('Possible tables to bake view templates for based on your current database:');
            /** @var \Cake\Database\Connection $connection */
            $connection = ConnectionManager::get($this->connection);
            $scanner = new TableScanner($connection);
            foreach ($scanner->listUnskipped() as $table) {
                $io->out('- ' . $this->_camelize($table));
            }

            return static::CODE_SUCCESS;
        }
        $template = $args->getArgument('template');
        $action = $args->getArgument('action');

        $controller = $args->getOption('controller');
        $this->controller($args, $name, $controller);
        $this->model($name);

        if ($template && $action === null) {
            $action = $template;
        }
        if ($template) {
            $this->bake($args, $io, $template, true, $action);

            return static::CODE_SUCCESS;
        }

        $vars = $this->_loadController($io);
        $methods = $this->_methodsToBake();

        foreach ($methods as $method) {
            try {
                $content = $this->getContent($args, $io, $method, $vars);
                $this->bake($args, $io, $method, $content);
            } catch (MissingTemplateException $e) {
                $io->verbose($e->getMessage());
            } catch (RuntimeException $e) {
                $io->error($e->getMessage());
            }
        }

        return static::CODE_SUCCESS;
    }

    /**
     * Set the model class for the table.
     *
     * @param string $table The table/model that is being baked.
     * @return void
     */
    public function model(string $table): void
    {
        $tableName = $this->_camelize($table);
        $plugin = $this->plugin;
        if ($plugin) {
            $plugin = $plugin . '.';
        }
        $this->modelName = $plugin . $tableName;
    }

    /**
     * Set the controller related properties.
     *
     * @param \Cake\Console\Arguments $args The arguments
     * @param string $table The table/model that is being baked.
     * @param string|null $controller The controller name if specified.
     * @return void
     */
    public function controller(Arguments $args, string $table, ?string $controller = null): void
    {
        $tableName = $this->_camelize($table);
        if (empty($controller)) {
            $controller = $tableName;
        }
        $this->controllerName = $controller;

        $plugin = $this->plugin;
        if ($plugin) {
            $plugin .= '.';
        }
        $prefix = $this->getPrefix($args);
        if ($prefix) {
            $prefix .= '/';
        }
        $this->controllerClass = (string)App::className($plugin . $prefix . $controller, 'Controller', 'Controller');
    }

    /**
     * Get the path base for view templates.
     *
     * @param \Cake\Console\Arguments $args The arguments
     * @param string|null $container Unused.
     * @return string
     */
    public function getTemplatePath(Arguments $args, ?string $container = null): string
    {
        $path = parent::getTemplatePath($args, $container);
        $path .= $this->controllerName . DS;

        return $path;
    }

    /**
     * Get a list of actions that can / should have view templates baked for them.
     *
     * @return array<string> Array of action names that should be baked
     */
    protected function _methodsToBake(): array
    {
        $base = Configure::read('App.namespace');

        $methods = [];
        if (class_exists($this->controllerClass)) {
            $methods = array_diff(
                array_map(
                    'Cake\Utility\Inflector::underscore',
                    get_class_methods($this->controllerClass)
                ),
                array_map(
                    'Cake\Utility\Inflector::underscore',
                    get_class_methods($base . '\Controller\AppController')
                )
            );
        }
        if (empty($methods)) {
            $methods = $this->scaffoldActions;
        }
        foreach ($methods as $i => $method) {
            if ($method[0] === '_') {
                unset($methods[$i]);
            }
        }

        return $methods;
    }

    /**
     * Loads Controller and sets variables for the template
     * Available template variables:
     *
     * - 'modelObject'
     * - 'modelClass'
     * - 'entityClass'
     * - 'primaryKey'
     * - 'displayField'
     * - 'singularVar'
     * - 'pluralVar'
     * - 'singularHumanName'
     * - 'pluralHumanName'
     * - 'fields'
     * - 'keyFields'
     * - 'schema'
     *
     * @param \Cake\Console\ConsoleIo $io Instance of the ConsoleIO
     * @return array Returns variables to be made available to a view template
     */
    protected function _loadController(ConsoleIo $io): array
    {
        if ($this->getTableLocator()->exists($this->modelName)) {
            $modelObject = $this->getTableLocator()->get($this->modelName);
        } else {
            $modelObject = $this->getTableLocator()->get($this->modelName, [
                'connectionName' => $this->connection,
            ]);
        }

        $namespace = Configure::read('App.namespace');

        $primaryKey = $displayField = $singularVar = $singularHumanName = null;
        $schema = $fields = $hidden = $modelClass = null;
        try {
            $primaryKey = (array)$modelObject->getPrimaryKey();
            $displayField = $modelObject->getDisplayField();
            $singularVar = $this->_singularName($this->controllerName);
            $singularHumanName = $this->_singularHumanName($this->controllerName);
            $schema = $modelObject->getSchema();
            $fields = $schema->columns();
            $hidden = $modelObject->newEmptyEntity()->getHidden() ?: ['token', 'password', 'passwd'];
            $modelClass = $this->modelName;
        } catch (Exception $exception) {
            $io->error($exception->getMessage());
            $this->abort();
        }

        [, $entityClass] = namespaceSplit($this->_entityName($this->modelName));
        $entityClass = sprintf('%s\Model\Entity\%s', $namespace, $entityClass);
        if (!class_exists($entityClass)) {
            $entityClass = EntityInterface::class;
        }
        $associations = $this->_filteredAssociations($modelObject);
        $keyFields = [];
        if (!empty($associations['BelongsTo'])) {
            foreach ($associations['BelongsTo'] as $assoc) {
                $keyFields[$assoc['foreignKey']] = $assoc['variable'];
            }
        }

        $pluralVar = Inflector::variable($this->controllerName);
        $pluralHumanName = $this->_pluralHumanName($this->controllerName);

        return compact(
            'modelObject',
            'modelClass',
            'entityClass',
            'schema',
            'primaryKey',
            'displayField',
            'singularVar',
            'pluralVar',
            'singularHumanName',
            'pluralHumanName',
            'fields',
            'hidden',
            'associations',
            'keyFields',
            'namespace'
        );
    }

    /**
     * Assembles and writes bakes the view file.
     *
     * @param \Cake\Console\Arguments $args CLI arguments
     * @param \Cake\Console\ConsoleIo $io Console io
     * @param string $template Template file to use.
     * @param string|true $content Content to write.
     * @param ?string $outputFile The output file to create. If null will use `$template`
     * @return void
     */
    public function bake(
        Arguments $args,
        ConsoleIo $io,
        string $template,
        string|bool $content = '',
        ?string $outputFile = null
    ): void {
        if ($outputFile === null) {
            $outputFile = $template;
        }
        if ($content === true) {
            $content = $this->getContent($args, $io, $template);
        }
        if (empty($content)) {
            // phpcs:ignore Generic.Files.LineLength
            $io->err("<warning>No generated content for '{$template}.{$this->ext}', not generating template.</warning>");

            return;
        }
        $path = $this->getTemplatePath($args);
        $filename = $path . Inflector::underscore($outputFile) . '.' . $this->ext;

        $io->out("\n" . sprintf('Baking `%s` view template file...', $outputFile), 1, ConsoleIo::NORMAL);
        $io->createFile($filename, $content, $this->force);
    }

    /**
     * Builds content from template and variables
     *
     * @param \Cake\Console\Arguments $args The CLI arguments
     * @param \Cake\Console\ConsoleIo $io The console io
     * @param string $action name to generate content to
     * @param array|null $vars passed for use in templates
     * @return string Content from template
     */
    public function getContent(Arguments $args, ConsoleIo $io, string $action, ?array $vars = null): string
    {
        if (!$vars) {
            $vars = $this->_loadController($io);
        }

        if (empty($vars['primaryKey'])) {
            $io->error('Cannot generate views for models with no primary key');
            $this->abort();
        }

        if (in_array($action, $this->excludeHiddenActions)) {
            $vars['fields'] = array_diff($vars['fields'], $vars['hidden']);
        }

        $renderer = $this->createTemplateRenderer()
            ->set('action', $action)
            ->set('plugin', $this->plugin)
            ->set($vars);

        $indexColumns = 0;
        if ($action === 'index' && $args->getOption('index-columns') !== null) {
            $indexColumns = $args->getOption('index-columns');
        }
        $renderer->set('indexColumns', $indexColumns);

        return $renderer->generate("Bake.Template/$action");
    }

    /**
     * Gets the option parser instance and configures it.
     *
     * @param \Cake\Console\ConsoleOptionParser $parser The option parser to update.
     * @return \Cake\Console\ConsoleOptionParser
     */
    public function buildOptionParser(ConsoleOptionParser $parser): ConsoleOptionParser
    {
        $parser = $this->_setCommonOptions($parser);

        $parser->setDescription(
            'Bake views for a controller, using built-in or custom templates. '
        )->addArgument('name', [
            'help' => 'Name of the controller views to bake. You can use Plugin.name as a shortcut for plugin baking.',
        ])->addArgument('template', [
            'help' => "Will bake a single action's file. core templates are (index, add, edit, view)",
        ])->addArgument('action', [
            'help' => 'Will bake the template in <template> but create the filename named <action>.',
        ])->addOption('controller', [
            'help' => 'The controller name if you have a controller that does not follow conventions.',
        ])->addOption('prefix', [
            'help' => 'The routing prefix to generate views for.',
        ])->addOption('index-columns', [
            'help' => 'Limit for the number of index columns',
            'default' => '0',
        ]);

        return $parser;
    }

    /**
     * Get filtered associations
     * To be mocked...
     *
     * @param \Cake\ORM\Table $model Table
     * @return array associations
     */
    protected function _filteredAssociations(Table $model): array
    {
        if ($this->_associationFilter === null) {
            $this->_associationFilter = new AssociationFilter();
        }

        return $this->_associationFilter->filterAssociations($model);
    }
}
