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

use Cake\Console\Arguments;
use Cake\Console\ConsoleIo;
use Cake\Console\ConsoleOptionParser;
use Cake\Controller\Controller;
use Cake\Core\Configure;
use Cake\Core\Exception\CakeException;
use Cake\Core\Plugin;
use Cake\Http\ServerRequest as Request;
use Cake\ORM\Table;
use Cake\Utility\Filesystem;
use Cake\Utility\Inflector;
use ReflectionClass;
use UnexpectedValueException;
use function Cake\Core\namespaceSplit;
use function Cake\Core\pluginSplit;

/**
 * Command class for generating test files.
 */
class TestCommand extends BakeCommand
{
    /**
     * class types that methods can be generated for
     *
     * @var array<string>
     */
    public array $classTypes = [
        'Entity' => 'Model\Entity',
        'Table' => 'Model\Table',
        'Controller' => 'Controller',
        'Component' => 'Controller\Component',
        'Behavior' => 'Model\Behavior',
        'Helper' => 'View\Helper',
        'Cell' => 'View\Cell',
        'Form' => 'Form',
        'Mailer' => 'Mailer',
        'Command' => 'Command',
        'CommandHelper' => 'Command\Helper',
        'Middleware' => 'Middleware',
    ];

    /**
     * class types that methods can be generated for
     *
     * @var array<string>
     */
    public array $classSuffixes = [
        'Entity' => '',
        'Table' => 'Table',
        'Controller' => 'Controller',
        'Component' => 'Component',
        'Behavior' => 'Behavior',
        'Helper' => 'Helper',
        'Cell' => 'Cell',
        'Form' => 'Form',
        'Mailer' => 'Mailer',
        'Command' => 'Command',
        'CommandHelper' => 'Helper',
        'Middleware' => 'Middleware',
    ];

    /**
     * Blacklisted methods for controller test cases.
     *
     * @var array<string>
     */
    protected array $blacklistedMethods = [
        'initialize',
    ];

    /**
     * Internal list of fixtures that have been added so far.
     *
     * @var array<string>
     */
    protected array $_fixtures = [];

    /**
     * Execute test generation
     *
     * @param \Cake\Console\Arguments $args The command arguments.
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return int|null The exit code or null for success
     */
    public function execute(Arguments $args, ConsoleIo $io): ?int
    {
        $this->extractCommonProperties($args);
        if (!$args->hasArgument('type') && !$args->hasArgument('name')) {
            $this->outputTypeChoices($io);

            return null;
        }
        $type = $this->normalize($args->getArgument('type'));

        if ($args->getOption('all')) {
            $this->_bakeAll($type, $args, $io);

            return null;
        }
        if (!$args->hasArgument('name')) {
            $this->outputClassChoices($type, $io);

            return null;
        }
        $name = $args->getArgument('name');
        $name = $this->_getName($name);

        if ($this->bake($type, $name, $args, $io)) {
            $io->out('<success>Done</success>');
        }

        return static::CODE_SUCCESS;
    }

    /**
     * Output a list of class types you can bake a test for.
     *
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return void
     */
    protected function outputTypeChoices(ConsoleIo $io): void
    {
        $io->out(
            'You must provide a class type to bake a test for. The valid types are:',
            2
        );
        $i = 0;
        foreach ($this->classTypes as $option => $package) {
            $io->out(++$i . '. ' . $option);
        }
        $io->out('');
        $io->out('Re-run your command as `cake bake <type> <classname>`');
    }

    /**
     * Output a list of possible classnames you might want to generate a test for.
     *
     * @param string $typeName The typename to get classes for.
     * @param \Cake\Console\ConsoleIo $io The console io
     * @return void
     */
    protected function outputClassChoices(string $typeName, ConsoleIo $io): void
    {
        $type = $this->mapType($typeName);
        $io->out(
            'You must provide a class to bake a test for. Some possible options are:',
            2
        );
        $options = $this->_getClassOptions($type);
        $i = 0;
        foreach ($options as $option) {
            $io->out(++$i . '. ' . $option);
        }
        $io->out('');
        $io->out('Re-run your command as `cake bake ' . $typeName . ' <classname>`');
    }

    /**
     * Bake all tests for one class type.
     *
     * @param string $type The typename to get bake all classes for.
     * @param \Cake\Console\Arguments $args Arguments
     * @param \Cake\Console\ConsoleIo $io ConsoleIo instance
     * @return void
     */
    protected function _bakeAll(string $type, Arguments $args, ConsoleIo $io): void
    {
        $mappedType = $this->mapType($type);
        $classes = $this->_getClassOptions($mappedType);

        foreach ($classes as $class) {
            if ($this->bake($type, $class, $args, $io)) {
                $io->out('<success>Done - ' . $class . '</success>');
            } else {
                $io->out('<error>Failed - ' . $class . '</error>');
            }
        }

        $io->out('<info>Bake finished</info>');
    }

    /**
     * Get the possible classes for a given type.
     *
     * @param string $namespace The namespace fragment to look for classes in.
     * @return array<string>
     */
    protected function _getClassOptions(string $namespace): array
    {
        $classes = [];
        $base = APP;
        if ($this->plugin) {
            $base = Plugin::classPath($this->plugin);
        }

        $path = $base . str_replace('\\', DS, $namespace);
        $files = (new Filesystem())->find($path);
        foreach ($files as $fileObj) {
            if ($fileObj->isFile()) {
                $classes[] = substr($fileObj->getFileName(), 0, -4) ?: '';
            }
        }
        sort($classes);

        return $classes;
    }

    /**
     * Completes final steps for generating data to create test case.
     *
     * @param string $type Type of object to bake test case for ie. Model, Controller
     * @param string $className the 'cake name' for the class ie. Posts for the PostsController
     * @param \Cake\Console\Arguments $args Arguments
     * @param \Cake\Console\ConsoleIo $io ConsoleIo instance
     * @return string|bool
     */
    public function bake(string $type, string $className, Arguments $args, ConsoleIo $io): string|bool
    {
        $type = $this->normalize($type);
        if (!isset($this->classSuffixes[$type]) || !isset($this->classTypes[$type])) {
            return false;
        }

        $prefix = $this->getPrefix($args);
        $fullClassName = $this->getRealClassName($type, $className, $prefix);

        if (!$args->getOption('no-fixture')) {
            if ($args->getOption('fixtures')) {
                $fixtures = array_map('trim', explode(',', $args->getOption('fixtures')));
                $this->_fixtures = array_filter($fixtures);
            } elseif ($this->typeCanDetectFixtures($type) && class_exists($fullClassName)) {
                $io->out('Bake is detecting possible fixtures...');
                $testSubject = $this->buildTestSubject($type, $fullClassName);
                $this->generateFixtureList($testSubject);
            }
        }

        $methods = [];
        if (class_exists($fullClassName)) {
            $methods = $this->getTestableMethods($fullClassName);
        }
        $mock = $this->hasMockClass($type);
        [$preConstruct, $construction, $postConstruct] = $this->generateConstructor($type, $fullClassName);
        $uses = $this->generateUses($type, $fullClassName);

        $subject = $className;
        [$namespace, $className] = namespaceSplit($fullClassName);

        $baseNamespace = Configure::read('App.namespace');
        if ($this->plugin) {
            $baseNamespace = $this->_pluginNamespace($this->plugin);
        }
        $subNamespace = substr($namespace, strlen($baseNamespace) + 1);

        $properties = $this->generateProperties($type, $subject, $fullClassName);

        $io->out("\n" . sprintf('Baking test case for %s ...', $fullClassName), 1, ConsoleIo::QUIET);

        $contents = $this->createTemplateRenderer()
            ->set('fixtures', $this->_fixtures)
            ->set('plugin', $this->plugin)
            ->set(compact(
                'subject',
                'className',
                'properties',
                'methods',
                'type',
                'fullClassName',
                'mock',
                'preConstruct',
                'postConstruct',
                'construction',
                'uses',
                'baseNamespace',
                'subNamespace',
                'namespace'
            ))
            ->generate('Bake.tests/test_case');

        $filename = $this->testCaseFileName($type, $fullClassName);
        $emptyFile = dirname($filename) . DS . '.gitkeep';
        $this->deleteEmptyFile($emptyFile, $io);
        if ($io->createFile($filename, $contents, $this->force)) {
            return $contents;
        }

        return false;
    }

    /**
     * Checks whether the chosen type can find its own fixtures.
     * Currently only model, and controller are supported
     *
     * @param string $type The Type of object you are generating tests for eg. controller
     * @return bool
     */
    public function typeCanDetectFixtures(string $type): bool
    {
        return in_array($type, ['Controller', 'Table'], true);
    }

    /**
     * Construct an instance of the class to be tested.
     * So that fixtures can be detected
     *
     * @param string $type The type of object you are generating tests for eg. controller
     * @param string $class The classname of the class the test is being generated for.
     * @return object And instance of the class that is going to be tested.
     */
    public function buildTestSubject(string $type, string $class): object
    {
        if ($type === 'Table') {
            [, $name] = namespaceSplit($class);
            $name = str_replace('Table', '', $name);
            if ($this->plugin) {
                $name = $this->plugin . '.' . $name;
            }
            if ($this->getTableLocator()->exists($name)) {
                $instance = $this->getTableLocator()->get($name);
            } else {
                $instance = $this->getTableLocator()->get($name, [
                    'connectionName' => $this->connection,
                ]);
            }
        } elseif ($type === 'Controller') {
            $instance = new $class(new Request());
        } else {
            $instance = new $class();
        }

        return $instance;
    }

    /**
     * Gets the real class name from the cake short form. If the class name is already
     * suffixed with the type, the type will not be duplicated.
     *
     * @param string $type The Type of object you are generating tests for eg. controller.
     * @param string $class the Classname of the class the test is being generated for.
     * @param string|null $prefix The namespace prefix if any
     * @return string Real class name
     */
    public function getRealClassName(string $type, string $class, ?string $prefix = null): string
    {
        $namespace = Configure::read('App.namespace');
        if ($this->plugin) {
            $namespace = str_replace('/', '\\', $this->plugin);
        }
        $suffix = $this->classSuffixes[$type];
        $subSpace = $this->mapType($type);
        if ($suffix && strpos($class, $suffix) === false) {
            $class .= $suffix;
        }
        if (in_array($type, ['Controller', 'Cell'], true) && $prefix) {
            $subSpace .= '\\' . str_replace('/', '\\', $prefix);
        }

        return $namespace . '\\' . $subSpace . '\\' . $class;
    }

    /**
     * Gets the subspace path for a test.
     *
     * @param string $type The Type of object you are generating tests for eg. controller.
     * @return string Path of the subspace.
     */
    public function getSubspacePath(string $type): string
    {
        $subspace = $this->mapType($type);

        return str_replace('\\', DS, $subspace);
    }

    /**
     * Map the types that TestTask uses to concrete types that App::className can use.
     *
     * @param string $type The type of thing having a test generated.
     * @return string
     * @throws \Cake\Core\Exception\CakeException When invalid object types are requested.
     */
    public function mapType(string $type): string
    {
        if (empty($this->classTypes[$type])) {
            throw new CakeException('Invalid object type: ' . $type);
        }

        return $this->classTypes[$type];
    }

    /**
     * Get methods declared in the class given.
     * No parent methods will be returned
     *
     * @param string $className Name of class to look at.
     * @return array<string> Array of method names.
     * @throws \ReflectionException
     */
    public function getTestableMethods(string $className): array
    {
        $class = new ReflectionClass($className);
        $out = [];
        foreach ($class->getMethods() as $method) {
            if ($method->getDeclaringClass()->getName() !== $className) {
                continue;
            }
            if (!$method->isPublic() || in_array($method->getName(), $this->blacklistedMethods, true)) {
                continue;
            }
            $out[] = $method->getName();
        }

        return $out;
    }

    /**
     * Generate the list of fixtures that will be required to run this test based on
     * loaded models.
     *
     * @param \Cake\ORM\Table|\Cake\Controller\Controller $subject The object you want to generate fixtures for.
     * @return array<string> Array of fixtures to be included in the test.
     */
    public function generateFixtureList(Table|Controller $subject): array
    {
        $this->_fixtures = [];
        if ($subject instanceof Table) {
            $this->_processModel($subject);
        } else {
            $this->_processController($subject);
        }

        /** @psalm-suppress RedundantFunctionCall */
        return array_values($this->_fixtures);
    }

    /**
     * Process a model, pull out model name + associations converted to fixture names.
     *
     * @param \Cake\ORM\Table $subject A Model class to scan for associations and pull fixtures off of.
     * @return void
     */
    protected function _processModel(Table $subject): void
    {
        $this->_addFixture($subject->getAlias());
        foreach ($subject->associations()->keys() as $alias) {
            $assoc = $subject->getAssociation($alias);
            $target = $assoc->getTarget();
            $name = $target->getAlias();
            $subjectClass = get_class($subject);

            if ($subjectClass !== Table::class && $subjectClass === get_class($target)) {
                continue;
            }
            if (!isset($this->_fixtures[$name])) {
                $this->_addFixture($target->getAlias());
            }
        }
    }

    /**
     * Process all the models attached to a controller
     * and generate a fixture list.
     *
     * @param \Cake\Controller\Controller $subject A controller to pull model names off of.
     * @return void
     */
    protected function _processController(Controller $subject): void
    {
        try {
            $model = $subject->fetchTable();
        } catch (UnexpectedValueException $exception) {
            // No fixtures needed or possible
            return;
        }

        $models = [$model->getAlias()];
        foreach ($models as $model) {
            [, $model] = pluginSplit($model);
            $this->_processModel($subject->{$model});
        }
    }

    /**
     * Add class name to the fixture list.
     * Sets the app. or plugin.plugin_name. prefix.
     *
     * @param string $name Name of the Model class that a fixture might be required for.
     * @return void
     */
    protected function _addFixture(string $name): void
    {
        if ($this->plugin) {
            $prefix = 'plugin.' . $this->plugin . '.';
        } else {
            $prefix = 'app.';
        }
        $fixture = $prefix . $this->_fixtureName($name);
        $this->_fixtures[$name] = $fixture;
    }

    /**
     * Is a mock class required for this type of test?
     * Controllers require a mock class.
     *
     * @param string $type The type of object tests are being generated for eg. controller.
     * @return bool
     */
    public function hasMockClass(string $type): bool
    {
        return $type === 'Controller';
    }

    /**
     * Generate a constructor code snippet for the type and class name
     *
     * @param string $type The Type of object you are generating tests for eg. controller
     * @param string $fullClassName The full classname of the class the test is being generated for.
     * @return array<string> Constructor snippets for the thing you are building.
     */
    public function generateConstructor(string $type, string $fullClassName): array
    {
        [, $className] = namespaceSplit($fullClassName);
        $pre = $construct = $post = '';
        if ($type === 'Table') {
            $tableName = str_replace('Table', '', $className);
            $pre = "\$config = \$this->getTableLocator()->exists('{$tableName}') " .
                "? [] : ['className' => {$className}::class];";
            $construct = "\$this->getTableLocator()->get('{$tableName}', \$config);";
        }
        if ($type === 'Behavior') {
            $pre = '$table = new Table();';
            $construct = "new {$className}(\$table);";
        }
        if ($type === 'Entity' || $type === 'Form') {
            $construct = "new {$className}();";
        }
        if ($type === 'Helper') {
            $pre = '$view = new View();';
            $construct = "new {$className}(\$view);";
        }
        if ($type === 'Component') {
            $pre = '$registry = new ComponentRegistry();';
            $construct = "new {$className}(\$registry);";
        }
        if ($type === 'Cell') {
            $pre = "\$this->request = \$this->getMockBuilder('Cake\Http\ServerRequest')->getMock();\n";
            $pre .= "        \$this->response = \$this->getMockBuilder('Cake\Http\Response')->getMock();";
            $construct = "new {$className}(\$this->request, \$this->response);";
        }
        if ($type === 'CommandHelper') {
            $pre = "\$this->stub = new ConsoleOutput();\n";
            $pre .= '        $this->io = new ConsoleIo($this->stub);';
            $construct = "new {$className}(\$this->io);";
        }

        return [$pre, $construct, $post];
    }

    /**
     * Generate property info for the type and class name
     *
     * The generated property info consists of a set of arrays that hold the following keys:
     *
     * - `description` (the property description)
     * - `type` (the property docblock type)
     * - `name` (the property name)
     * - `value` (optional - the properties initial value)
     *
     * @param string $type The Type of object you are generating tests for eg. controller
     * @param string $subject The name of the test subject.
     * @param string $fullClassName The Classname of the class the test is being generated for.
     * @return array An array containing property info
     */
    public function generateProperties(string $type, string $subject, string $fullClassName): array
    {
        $properties = [];
        switch ($type) {
            case 'Cell':
                $properties[] = [
                    'description' => 'Request mock',
                    'type' => '\Cake\Http\ServerRequest|\PHPUnit\Framework\MockObject\MockObject',
                    'name' => 'request',
                ];
                $properties[] = [
                    'description' => 'Response mock',
                    'type' => '\Cake\Http\Response|\PHPUnit\Framework\MockObject\MockObject',
                    'name' => 'response',
                ];
                break;

            case 'CommandHelper':
                $properties[] = [
                    'description' => 'ConsoleOutput stub',
                    'type' => '\Cake\TestSuite\Stub\ConsoleOutput',
                    'name' => 'stub',
                ];
                $properties[] = [
                    'description' => 'ConsoleIo mock',
                    'type' => '\Cake\Console\ConsoleIo',
                    'name' => 'io',
                ];
                break;
        }

        if (!in_array($type, ['Controller', 'Command'])) {
            $properties[] = [
                'description' => 'Test subject',
                'type' => '\\' . $fullClassName,
                'name' => $subject,
            ];
        }

        return $properties;
    }

    /**
     * Generate the uses() calls for a type & class name
     *
     * @param string $type The Type of object you are generating tests for eg. controller
     * @param string $fullClassName The Classname of the class the test is being generated for.
     * @return array<string> An array containing used classes
     */
    public function generateUses(string $type, string $fullClassName): array
    {
        $uses = [];
        if ($type === 'Component') {
            $uses[] = 'Cake\Controller\ComponentRegistry';
        }
        if ($type === 'Helper') {
            $uses[] = 'Cake\View\View';
        }
        if ($type === 'CommandHelper') {
            $uses[] = 'Cake\TestSuite\Stub\ConsoleOutput';
            $uses[] = 'Cake\Console\ConsoleIo';
        }
        if ($type === 'Behavior') {
            $uses[] = 'Cake\ORM\Table';
        }
        $uses[] = $fullClassName;

        return $uses;
    }

    /**
     * Get the base path to the plugin/app tests.
     *
     * @return string
     */
    public function getBasePath(): string
    {
        $dir = 'TestCase/';
        $path = defined('TESTS') ? TESTS . $dir : ROOT . DS . 'tests' . DS . $dir;
        if ($this->plugin) {
            $path = $this->_pluginPath($this->plugin) . 'tests/' . $dir;
        }

        return $path;
    }

    /**
     * Make the filename for the test case. resolve the suffixes for controllers
     * and get the plugin path if needed.
     *
     * @param string $type The Type of object you are generating tests for eg. controller
     * @param string $className The fully qualified classname of the class the test is being generated for.
     * @return string filename the test should be created on.
     */
    public function testCaseFileName(string $type, string $className): string
    {
        $path = $this->getBasePath();
        $namespace = Configure::read('App.namespace');
        if ($this->plugin) {
            $namespace = $this->plugin;
        }

        $classTail = substr($className, strlen($namespace) + 1);
        $path = $path . $classTail . 'Test.php';

        return str_replace(['/', '\\'], DS, $path);
    }

    /**
     * Build the option parser
     *
     * @param \Cake\Console\ConsoleOptionParser $parser Option parser to update
     * @return \Cake\Console\ConsoleOptionParser
     */
    public function buildOptionParser(ConsoleOptionParser $parser): ConsoleOptionParser
    {
        $parser = $this->_setCommonOptions($parser);

        $types = array_keys($this->classTypes);
        $types = array_merge($types, array_map([$this, 'underscore'], $types));

        $parser->setDescription(
            'Bake test case skeletons for classes.'
        )->addArgument('type', [
            'help' => 'Type of class to bake, can be any of the following:' .
                ' controller, model, helper, component or behavior.',
            'choices' => $types,
        ])->addArgument('name', [
            'help' => 'An existing class to bake tests for.',
        ])->addOption('fixtures', [
            'help' => 'A comma separated list of fixture names you want to include.',
        ])->addOption('no-fixture', [
            'boolean' => true,
            'default' => false,
            'help' => 'Select if you want to bake without fixture.',
        ])->addOption('prefix', [
            'default' => false,
            'help' => 'Use when baking tests for prefixed controllers.',
        ])->addOption('all', [
            'boolean' => true,
            'help' => 'Bake all classes of the given type',
        ]);

        return $parser;
    }

    /**
     * Normalizes string into CamelCase format.
     *
     * @param string $string String to inflect
     * @return string
     */
    protected function normalize(string $string): string
    {
        return Inflector::camelize(Inflector::underscore($string));
    }

    /**
     * Helper to allow under_score format for CLI env usage.
     *
     * @param string $string String to inflect
     * @return string
     */
    protected function underscore(string $string): string
    {
        return Inflector::underscore($string);
    }
}
