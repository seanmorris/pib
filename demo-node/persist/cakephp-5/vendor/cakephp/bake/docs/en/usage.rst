Code Generation with Bake
#########################

The Bake console is run using the PHP CLI (command line interface).
If you have problems running the script, ensure that:

#. You have the PHP CLI installed and that it has the proper modules enabled
   (eg: MySQL, intl).
#. Users also might have issues if the database host is 'localhost' and should
   try '127.0.0.1' instead, as localhost can cause issues with PHP CLI.
#. Depending on how your computer is configured, you may have to set execute
   rights on the cake bash script to call it using ``bin/cake bake``.

Before running bake you should make sure you have at least one database
connection configured.

You can get the list of available bake command by running ``bin/cake bake --help``
(For Windows usage ``bin\cake bake --help``) ::

    $ bin/cake bake --help
    Current Paths:

    * app:  src/
    * root: /path/to/your/app/
    * core: /path/to/your/app/vendor/cakephp/cakephp/

    Available Commands:

    Bake:
    - bake all
    - bake behavior
    - bake cell
    - bake command
    - bake command_helper
    - bake component
    - bake controller
    - bake controller all
    - bake enum
    - bake fixture
    - bake fixture all
    - bake form
    - bake helper
    - bake mailer
    - bake middleware
    - bake model
    - bake model all
    - bake plugin
    - bake template
    - bake template all
    - bake test

    To run a command, type `cake command_name [args|options]`
    To get help on a specific command, type `cake command_name --help`

Bake Themes
===========

The theme option is common to all bake commands, and allows changing the bake
template files used when baking. To create your own templates, see the
:ref:`bake theme creation documentation <creating-a-bake-theme>`.

.. meta::
    :title lang=en: Code Generation with Bake
    :keywords lang=en: command line interface,functional application,database,database configuration,bash script,basic ingredients,project,model,path path,code generation,scaffolding,windows users,configuration file,few minutes,config,view,models,running,mysql
