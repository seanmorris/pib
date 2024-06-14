Extending Bake
##############

Bake features an extensible architecture that allows your application or plugins
to modify or add-to the base functionality. Bake makes use of a dedicated
view class which uses the `Twig <https://twig.symfony.com/>`_ template engine.

Bake Events
===========

As a view class, ``BakeView`` emits the same events as any other view class,
plus one extra initialize event. However, whereas standard view classes use the
event prefix "View.", ``BakeView`` uses the event prefix "Bake.".

The initialize event can be used to make changes which apply to all baked
output, for example to add another helper to the bake view class this event can
be used::

    <?php
    use Cake\Event\EventInterface;
    use Cake\Event\EventManager;

    // in src/Application::bootstrapCli()

    EventManager::instance()->on('Bake.initialize', function (EventInterface $event) {
        $view = $event->getSubject();

        // In my bake templates, allow the use of the MySpecial helper
        $view->loadHelper('MySpecial', ['some' => 'config']);

        // And add an $author variable so it's always available
        $view->set('author', 'Andy');
    });

Bake events can be handy for making small changes to existing templates.
For example, to change the variable names used when baking controller/template
files one can use a function listening for ``Bake.beforeRender`` to modify the
variables used in the bake templates::

    <?php
    use Cake\Event\EventInterface;
    use Cake\Event\EventManager;

    // in src/Application::bootstrapCli()

    EventManager::instance()->on('Bake.beforeRender', function (EventInterface $event) {
        $view = $event->getSubject();

        // Use $rows for the main data variable in indexes
        if ($view->get('pluralName')) {
            $view->set('pluralName', 'rows');
        }
        if ($view->get('pluralVar')) {
            $view->set('pluralVar', 'rows');
        }

        // Use $theOne for the main data variable in view/edit
        if ($view->get('singularName')) {
            $view->set('singularName', 'theOne');
        }
        if ($view->get('singularVar')) {
            $view->set('singularVar', 'theOne');
        }
    });

You may also scope the ``Bake.beforeRender`` and ``Bake.afterRender`` events to
a specific generated file. For instance, if you want to add specific actions to
your UsersController when generating from a **Controller/controller.twig** file,
you can use the following event::

    <?php
    use Cake\Event\EventInterface;
    use Cake\Event\EventManager;
    use Cake\Utility\Hash;

    // in src/Application::bootstrapCli()

    EventManager::instance()->on(
        'Bake.beforeRender.Controller.controller',
        function (EventInterface $event) {
            $view = $event->getSubject();
            if ($view->get('name') === 'Users') {
                // add the login and logout actions to the Users controller
                $view->set('actions', [
                    'login',
                    'logout',
                    'index',
                    'view',
                    'add',
                    'edit',
                    'delete',
                ]);
            }
        }
    );

By scoping event listeners to specific bake templates, you can simplify your
bake related event logic and provide callbacks that are easier to test.

Bake Template Syntax
====================

Bake template files use the `Twig <https://twig.symfony.com/>`__ template syntax.

So, for example, when baking a command like so:

.. code-block:: bash

    bin/cake bake command Foo

The template used (**vendor/cakephp/bake/templates/bake/Command/command.twig**)
looks like this::

    <?php
    declare(strict_types=1);

    namespace {{ namespace }}\Command;

    use Cake\Command\Command;
    use Cake\Console\Arguments;
    use Cake\Console\ConsoleIo;
    use Cake\Console\ConsoleOptionParser;

    /**
    * {{ name }} command.
    */
    class {{ name }}Command extends Command
    {
        /**
        * Hook method for defining this command's option parser.
        *
        * @see https://book.cakephp.org/4/en/console-commands/commands.html#defining-arguments-and-options
        * @param \Cake\Console\ConsoleOptionParser $parser The parser to be defined
        * @return \Cake\Console\ConsoleOptionParser The built parser.
        */
        public function buildOptionParser(ConsoleOptionParser $parser): ConsoleOptionParser
        {
            $parser = parent::buildOptionParser($parser);

            return $parser;
        }

        /**
        * Implement this method with your command's logic.
        *
        * @param \Cake\Console\Arguments $args The command arguments.
        * @param \Cake\Console\ConsoleIo $io The console io
        * @return int|null|void The exit code or null for success
        */
        public function execute(Arguments $args, ConsoleIo $io)
        {
        }
    }

And the resultant baked class (**src/Command/FooCommand.php**) looks like this::

    <?php
    declare(strict_types=1);

    namespace App\Command;

    use Cake\Command\Command;
    use Cake\Console\Arguments;
    use Cake\Console\ConsoleIo;
    use Cake\Console\ConsoleOptionParser;

    /**
    * Foo command.
    */
    class FooCommand extends Command
    {
        /**
        * Hook method for defining this command's option parser.
        *
        * @see https://book.cakephp.org/4/en/console-commands/commands.html#defining-arguments-and-options
        * @param \Cake\Console\ConsoleOptionParser $parser The parser to be defined
        * @return \Cake\Console\ConsoleOptionParser The built parser.
        */
        public function buildOptionParser(ConsoleOptionParser $parser): ConsoleOptionParser
        {
            $parser = parent::buildOptionParser($parser);

            return $parser;
        }

        /**
        * Implement this method with your command's logic.
        *
        * @param \Cake\Console\Arguments $args The command arguments.
        * @param \Cake\Console\ConsoleIo $io The console io
        * @return int|null|void The exit code or null for success
        */
        public function execute(Arguments $args, ConsoleIo $io)
        {
        }
    }

.. _creating-a-bake-theme:

Creating a Bake Theme
=====================

If you wish to modify the output produced by the "bake" command, you can
create your own bake 'theme' which allows you to replace some or all of the
templates that bake uses. To create a bake theme do the following:

#. Bake a new plugin. The name of the plugin is the bake 'theme' name. For
   example ``bin/cake bake plugin custom_bake``.
#. Create a new directory **plugins/CustomBake/templates/bake**.
#. Copy any templates you want to override from
   **vendor/cakephp/bake/templates/bake** to matching files in your
   plugin.
#. When running bake use the ``--theme CustomBake`` option to use your bake
   theme. To avoid having to specify this option in each call, you can also
   set your custom theme to be used as default theme::

        <?php
        // in src/Application::bootstrapCli() before loading the 'Bake' plugin.
        Configure::write('Bake.theme', 'MyTheme');

Application Bake Templates
==============================

If you only need to customize a few bake templates, or need to use application
dependencies in your templates you can include template overrides in your
application templates. These overrides work similar to overriding other plugin
templates.

#. Create a new directory **/templates/plugin/Bake/**.
#. Copy any templates you want to override from
   **vendor/cakephp/bake/templates/bake/** to matching files in your
   application.

You do not need to use the ``--theme`` option when using application templates.

Creating New Bake Command Options
=================================

It's possible to add new bake command options, or override the ones provided by
CakePHP by creating command in your application or plugins. By extending
``Bake\Command\BakeCommand``, bake will find your new command and include it as
part of bake.

As an example, we'll make a command that creates an arbitrary foo class. First,
create the command file **src/Command/Bake/FooCommand.php**. We'll extend the
``SimpleBakeCommand`` for now as our command will be simple. ``SimpleBakeCommand``
is abstract and requires us to define 3 methods that tell bake what the command is
called, where the files it generates should go, and what template to use. Our
FooCommand.php file should look like::

    <?php
    declare(strict_types=1);

    namespace App\Command\Bake;

    use Bake\Command\SimpleBakeCommand;

    class FooCommand extends SimpleBakeCommand
    {
        public $pathFragment = 'FooPath/';

        public function name(): string
        {
            return 'foo';
        }

        public function template(): string
        {
            return 'fooTemplate';
        }

        public function fileName(string $name): string
        {
            return $name . 'FooOut.php';
        }
    }

Once this file has been created, we need to create a template that bake can use
when generating code. Create **templates/bake/foo_template.twig**. In this file we'll
add the following content::

    <?php
    namespace {{ namespace }}\FooPath;

    /**
     * {{ name }} fooOut
     */
    class {{ name }}FooOut
    {
        // Add code.
    }

You should now see your new command in the output of ``bin/cake bake``. You can
run your new task by running ``bin/cake bake foo Example``.
This will generate a new ``ExampleFooOut`` class in **src/FooPath/ExampleFooOut.php**
for your application to use.

If you want the ``bake`` call to also create a test file for your
``ExampleFooOut`` class, you need to overwrite the ``bakeTest()`` method in the
``FooCommand`` class to register the class suffix and namespace for your custom
command name::

    use Cake\Console\Arguments;
    use Cake\Console\ConsoleIo;

    public function bakeTest(string $className, Arguments $args, ConsoleIo $io): void
    {
        if (!isset($this->Test->classSuffixes[$this->name()])) {
            $this->Test->classSuffixes[$this->name()] = 'Foo';
        }

        $name = ucfirst($this->name());
        if (!isset($this->Test->classTypes[$name])) {
            $this->Test->classTypes[$name] = 'Foo';
        }

        return parent::bakeTest($className);
    }

* The **class suffix** will be appened to the name provided in your ``bake``
  call. In the previous example, it would create a ``ExampleFooTest.php`` file.
* The **class type** will be the sub-namespace used that will lead to your
  file (relative to the app or the plugin you are baking into). In the previous
  example, it would create your test with the namespace ``App\Test\TestCase\Foo``.

Configuring the BakeView class
==============================

The bake commands use the ``BakeView`` class to render the templates. You can
access the instance by listening to the ``Bake.initialize`` event. For example, here's
how you can load your own helper so that it can be used in bake templates::

    <?php
    \Cake\Event\EventManager::instance()->on(
        'Bake.initialize',
        function ($event, $view) {
            $view->loadHelper('Foo');
        }
    );

.. meta::
    :title lang=en: Extending Bake
    :keywords lang=en: command line interface, development, bake view, bake template syntax, twig, erb tags, percent tags
