Bake でコード生成
##################

cake コンソールは、 PHP CLI (command line interface) で実行します。
もしスクリプトの実行に問題があるなら、以下を満たしてください。

#. PHP CLI がインストールされているか適切なモジュールが有効か確認してください (例：MySQL, intl)。
#. データベースのホストが 'localhost' で問題があるなら、代わりに '127.0.0.1' を使って下さい。
   PHP CLI でこの問題がおこる可能性があります。
#. 使っているコンピューターの設定に応じて、 ``bin/cake bake`` で使用する cake bash スクリプトの
   実行権限を設定する必要があります。

bake を実行する前にデータベースとの接続を確認しましょう。

``bin/cake bake`` を引数無しで実行すると可能なタスクを表示できます。

Windows システムの場合、 ``bin\cake bake`` を試してみてください。

それは以下のように表示されます。 ::

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

    By using `cake bake [name]` you can invoke a specific bake task.

より詳しい各コマンドの情報を得るには、 ``--help`` オプションをつけ実行してください。 ::

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

Bake テーマオプション
=====================

テーマオプションは全 bake コマンドで一般的です。また、bake テンプレートファイルを変更することができます。
テーマを作るには、 :ref:`Bake テーマ作成ドキュメント <creating-a-bake-theme>` をご覧ください。

.. meta::
    :title lang=ja: Code Generation with Bake
    :keywords lang=ja: command line interface,functional application,database,database configuration,bash script,basic ingredients,project,model,path path,code generation,scaffolding,windows users,configuration file,few minutes,config,view,models,running,mysql
