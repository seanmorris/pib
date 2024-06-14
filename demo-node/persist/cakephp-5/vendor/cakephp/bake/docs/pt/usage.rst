Geração de Código com Bake
##########################

O console do **Bake** é executado usando o PHP CLI (interface da linha de comando).
Se você tiver problemas para executar o script, assegure-se de que:

#. Você instalou o PHP CLI e possui os módulos apropriados habilitados (por
   exemplo: MySQL, intl).
#. Os usuários também podem ter problemas se o host do banco de dados for
   'localhost' e devem tentar '127.0.0.1', em vez disso, como localhost pode
   causar problemas no PHP CLI.
#. Dependendo de como o seu computador está configurado, você pode ter que
   definir direitos de execução no script cake bash para chamá-lo usando
   ``bin/cake bake``.

Antes de executar o Bake você deve certificar-se de ter pelo menos um banco de dados com a conexão configurada.

Para ver as opções disponíveis no Bake digite::

    $ bin/cake bake --help

    Current Paths:

    * app:  src
    * root: .
    * core: .\vendor\cakephp\cakephp

    Available Commands:

    Bake:
     - bake all
     - bake behavior
     - bake cell
     - bake command
     - bake component
     - bake controller
     - bake controller all
     - bake fixture
     - bake fixture all
     - bake form
     - bake helper
     - bake mailer
     - bake middleware
     - bake model
     - bake model all
     - bake plugin
     - bake task
     - bake template
     - bake template all
     - bake test

    To run a command, type `cake command_name [args|options]`
    To get help on a specific command, type `cake command_name --help`


Você pode obter mais informações sobre o que cada tarefa faz e quais são suas opções
disponíveis usando a opção ``--help``::

    $ bin/cake bake model --help

    Bake table and entity classes.

    Usage:
    cake bake model [options] [<name>]

    Options:

    --connection, -c       The datasource connection to get data from.
                           (default: default)
    --display-field        The displayField if you would like to choose one.
    --fields               A comma separated list of fields to make
                           accessible.
    --force, -f            Force overwriting existing files without
                           prompting.
    --help, -h             Display this help.
    --hidden               A comma separated list of fields to hide.
    --no-associations      Disable generating associations.
    --no-entity            Disable generating an entity class.
    --no-fields            Disable generating accessible fields in the
                           entity.
    --no-fixture           Do not generate a test fixture skeleton.
    --no-hidden            Disable generating hidden fields in the entity.
    --no-rules             Disable generating a rules checker.
    --no-table             Disable generating a table class.
    --no-test              Do not generate a test case skeleton.
    --no-validation        Disable generating validation rules.
    --plugin, -p           Plugin to bake into.
    --primary-key          The primary key if you would like to manually set
                           one. Can be a comma separated list if you are
                           using a composite primary key.
    --quiet, -q            Enable quiet output.
    --table                The table name to use if you have
                           non-conventional table names.
    --theme, -t            The theme to use when baking code.
    --verbose, -v          Enable verbose output.

    Arguments:

    name  Name of the model to bake (without the Table suffix). You can use
          Plugin.name to bake plugin models. (optional)

    Omitting all arguments and options will list the table names you can
    generate models for.



Temas para o Bake
=================

A opção de tema é comum a todos os comandos do Bake e permite mudar os arquivos de modelo usados por ele. Para criar seus próprios modelos, veja a
:ref:`documentação de criação de temas para o Bake <creating-a-bake-theme>`.

.. meta::
    :title lang=pt: Geração de código com bake
    :keywords lang=pt: command line interface,functional application,database,database configuration,bash script,basic ingredients,project,model,path path,code generation,scaffolding,windows users,configuration file,few minutes,config,iew,shell,models,running,mysql
