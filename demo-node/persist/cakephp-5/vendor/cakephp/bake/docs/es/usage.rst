Crear código con Bake
#####################

La consola de CAKE se ejecuta usando PHP CLI (command line interface).
Si tiene problemas para ejecutar el script, asegurese de:

#. Tener instalado el PHP CLI y que estén los módulos correspondientes
   habilitados (ej: MySQL y intl).
#. Si el host de base de datos es 'localhost', intente realizar la conexión con
   el ip '127.0.0.1'. En algunos casos PHP CLI tiene problemas al referenciar
   por nombre de host (localhost).
#. Dependiendo de como esté configurado su equipo, la ejecución del comando
   CAKE BAKE (cake bash script) puede requerir permisos de ejecución al
   lanzar ``bin/cake bake``.

Antes de comenzar la ejecución, asegúrese de disponer al menos de una conexión
a una base de datos configurada.

Para comenzar con la ejecución del comando debe abrir la consola de windows
y ejecutar "Cake Bake"

#. Ir a Inicio (Start) > Ejecutar (Run)
#. Escribir "cmd" y presionar 'Enter'
#. Navegar hasta llegar a la carpeta de instalación de cake
#. Acceder a la carpeta 'bin'
#. Escribir 'Cake bake' lo cual deberá devolver un listado con todas las
   tareas/actividades disponibles.

El resultado debería ser algo similar a lo siguiente::

    $ bin/cake bake

    Welcome to CakePHP v3.1.6 Console
    ---------------------------------------------------------------
    App : src
    Path: /var/www/cakephp.dev/src/
    PHP: 5.5.8
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
    - migration_snapshot
    - model
    - plugin
    - template
    - test

    By using 'cake bake [name]' you can invoke a specific bake task.

Puede obtener más información sobre lo que realiza cada una de las actividades
y sus opciones usando el parametro '--help' option::

    $ bin/cake bake controller --help

    Welcome to CakePHP v3.1.6 Console
    ---------------------------------------------------------------
    App : src
    Path: /var/www/cakephp.dev/src/
    ---------------------------------------------------------------
    Bake a controller skeleton.

    Usage:
    cake bake controller [subcommand] [options] [<name>]

    Subcommands:

    all  Bake all controllers with CRUD methods.

    To see help on a subcommand use `cake bake controller [subcommand] --help`

    Options:

    --help, -h        Display this help.
    --verbose, -v     Enable verbose output.
    --quiet, -q       Enable quiet output.
    --plugin, -p      Plugin to bake into.
    --force, -f       Force overwriting existing files without prompting.
    --connection, -c  The datasource connection to get data from.
                      (default: default)
    --theme, -t       The theme to use when baking code.
    --components      The comma separated list of components to use.
    --helpers         The comma separated list of helpers to use.
    --prefix          The namespace/routing prefix to use.
    --no-test         Do not generate a test skeleton.
    --no-actions      Do not generate basic CRUD action methods.

    Arguments:

    name  Name of the controller to bake. Can use Plugin.name to bake
        controllers into plugins. (optional)

Temas Bake / Templates
======================

La opción ``theme`` es genérica para todos los comandos bake y permite cambiar los
templates de bake utilizados para generar los archivos finales. Para crear sus
propios templates, ver :ref:`bake theme creation documentation
<creating-a-bake-theme>`.

.. meta::
    :title lang=es: Crear código con Bake
    :keywords lang=es: interfaz de línea de comando, aplicación funcional, base de datos, configuración de base de datos, bash script, ingredientes básicos, proyecto, modelo, path, crear código, generación de código, scaffolding, usuarios windows, archivo de configuración, pocos minutos, configurar, view, modelos, running, mysql
