Генерация кода с помощью Bake
#############################

Консоль cake запускается с использованием PHP CLI (интерфейса командной строки).
Если у вас возникли проблемы с запуском скрипта, убедитесь, что:

#. У вас установлен PHP CLI и что у него есть соответствующие включённые модули
   (например: MySQL, intl).
#. У пользователей также могут быть проблемы, если хост базы данных является
   'localhost' вмеcто этого можно попробовать '127.0.0.1', поскольку localhost
   может вызвать проблемы с PHP CLI.
#. В зависимости от того, как настроен ваш компьютер, вам может потребоваться
   установить права выполнения на скрипт bash, чтобы вызвать его, используя
   ``bin/cake bake``.

Перед запуском bake вы должны убедиться, что у вас есть хотя бы одна база данных и
соединение настроено.

При запуске без аргументов ``bin/cake bake`` выводит список доступных
заданий. Вы должны увидеть что-то вроде::

    $ bin/cake bake

    Welcome to CakePHP v3.4.6 Console
    ---------------------------------------------------------------
    App : src
    Path: /var/www/cakephp.dev/src/
    PHP : 5.6.20
    ---------------------------------------------------------------
    The following commands can be used to generate skeleton code for your application.

    Available bake commands:

    - all
    - behavior
    - cell
    - component
    - controller
    - fixture
    - form
    - helper
    - mailer
    - migration
    - migration_diff
    - migration_snapshot
    - model
    - plugin
    - seed
    - task
    - template
    - test

    By using `cake bake [name]` you can invoke a specific bake task.

Вы можете получить больше дополнительной информации о том, что делает каждая задача, и какие параметры
доступны, если используете ключ ``--help``::

    $ bin/cake bake --help

    Welcome to CakePHP v3.4.6 Console
    ---------------------------------------------------------------
    App : src
    Path: /var/www/cakephp.dev/src/
    PHP : 5.6.20
    ---------------------------------------------------------------
    The Bake script generates controllers, models and template files for
    your application. If run with no command line arguments, Bake guides the
    user through the class creation process. You can customize the
    generation process by telling Bake where different parts of your
    application are using command line arguments.

    Usage:
    cake bake.bake [subcommand] [options]

    Subcommands:

    all                 Bake a complete MVC skeleton.
    behavior            Bake a behavior class file.
    cell                Bake a cell class file.
    component           Bake a component class file.
    controller          Bake a controller skeleton.
    fixture             Generate fixtures for use with the test suite. You
                        can use `bake fixture all` to bake all fixtures.
    form                Bake a form class file.
    helper              Bake a helper class file.
    mailer              Bake a mailer class file.
    migration           Bake migration class.
    migration_diff      Bake migration class.
    migration_snapshot  Bake migration snapshot class.
    model               Bake table and entity classes.
    plugin              Create the directory structure, AppController class
                        and testing setup for a new plugin. Can create
                        plugins in any of your bootstrapped plugin paths.
    seed                Bake seed class.
    task                Bake a task class file.
    template            Bake views for a controller, using built-in or
                        custom templates.
    test                Bake test case skeletons for classes.

    To see help on a subcommand use `cake bake.bake [subcommand] --help`

    Options:

    --connection, -c   Database connection to use in conjunction with `bake
                       all`. (default: default)
    --everything       Bake a complete MVC skeleton, using all the available
                       tables. Usage: "bake all --everything"
    --force, -f        Force overwriting existing files without prompting.
    --help, -h         Display this help.
    --plugin, -p       Plugin to bake into.
    --prefix           Prefix to bake controllers and templates into.
    --quiet, -q        Enable quiet output.
    --tablePrefix      Table prefix to be used in models.
    --theme, -t        The theme to use when baking code. (choices:
                       Bake|Migrations)
    --verbose, -v      Enable verbose output.

Темы Bake
=========

Параметр темы является общим для всех команд bake, так же bake позволяет изменять
файлы шаблонов, используемые при 'выпечке'. Чтобы создать свои собственные шаблоны см.
:ref:`документация по созданию темы<creating-a-bake-theme>`.

.. meta::
    :title lang=ru: Генерация кода с помощью Bake
    :keywords lang=en: command line interface,functional application,database,database configuration,bash script,basic ingredients,project,model,path path,code generation,scaffolding,windows users,configuration file,few minutes,config,view,models,running,mysql
