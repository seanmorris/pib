Migrations
##########

マイグレーションは、バージョン管理システムを使用して追跡することができる PHP ファイルを
記述することによって、あなたのデータベースのスキーマ変更を行うための、コアチームによって
サポートされているプラグインです。

それはあなたが時間をかけてあなたのデータベーステーブルを進化させることができます。
スキーマ変更の SQL を書く代わりに、このプラグインでは、直観的にデータベースの変更を
実現するための手段を使用することができます。

このプラグインは、データベースマイグレーションライブラリーの
`Phinx <https://phinx.org/>`_ のラッパーです。

インストール
============

初期状態で Migrations は、デフォルトのアプリケーションの雛形と一緒にインストールされます。
もしあなたがそれを削除して再インストールしたい場合は、（composer.json ファイルが
配置されている）アプリケーションルートディレクトリーから次のコマンドを実行します。

.. code-block:: bash

    php composer.phar require cakephp/migrations "@stable"

    # また、composer がグローバルにインストールされていた場合は、

    composer require cakephp/migrations "@stable"

このプラグインを使用するためには、あなたは、アプリケーションの **config/bootstrap.php**
ファイルでロードする必要があります。あなたの **config/bootstrap.php** からプラグインを
ロード・アンロードするために `CakePHP の Plugin シェル
<https://book.cakephp.org/3.0/ja/console-and-shells/plugin-shell.html>`__
が利用できます。 :

.. code-block:: bash

    bin/cake plugin load Migrations

もしくは、あなたの **src/Application.php** ファイルを編集し、次の行を追加することで
ロードすることができます。 ::

    $this->addPlugin('Migrations');

    // 3.6.0 より前は Plugin::load() を使用する必要があります

また、 `データベース設定
<https://book.cakephp.org/3.0/en/orm/database-basics.html#database-configuration>`__ の項で説明したように、
あなたの **config/app.php** ファイル内のデフォルトのデータベース構成を設定する必要が
あります。

概要
====

マイグレーションは、基本的にはデータベースの変更の操作を PHP ファイルで表します。
マイグレーションファイルはテーブルを作成し、カラムの追加や削除、インデックスの作成や
データの作成さえ可能です。

ここにマイグレーションの例があります。 ::

    <?php
    use Migrations\AbstractMigration;

    class CreateProducts extends AbstractMigration
    {
        /**
         * Change Method.
         *
         * More information on this method is available here:
         * https://book.cakephp.org/phinx/0/en/migrations.html#the-change-method
         * @return void
         */
        public function change()
        {
            $table = $this->table('products');
            $table->addColumn('name', 'string', [
                'default' => null,
                'limit' => 255,
                'null' => false,
            ]);
            $table->addColumn('description', 'text', [
                'default' => null,
                'null' => false,
            ]);
            $table->addColumn('created', 'datetime', [
                'default' => null,
                'null' => false,
            ]);
            $table->addColumn('modified', 'datetime', [
                'default' => null,
                'null' => false,
            ]);
            $table->create();
        }
    }

マイグレーションは、データベースに ``products`` という名前のテーブルを追加します。
以下のカラムが定義します。

- ``id`` カラムの型は、主キーの ``integer``
- ``name`` カラムの型は ``string``
- ``description`` カラムの型は ``text``
- ``created`` カラムの型は ``datetime``
- ``modified`` カラムの型は ``datetime``

.. tip::

    主キーのカラム名 ``id`` は、 **暗黙のうちに** 追加されます。

.. note::

    このファイルは変更を **適用後** にデータベースがどのようになるかを記述していることに
    注意してください。この時点でデータベースに ``products`` テーブルは存在せず、
    ``products`` テーブルを作って項目を追加することができるのと同様に、マイグレーションを
    ``rollback`` すればテーブルが消えてしまいます。

マイグレーションファイルを **config/Migrations** フォルダーに作成したら、下記の
``migrations`` コマンドを実行することでデータベースにテーブルを作成することがでます。 :

.. code-block:: bash

    bin/cake migrations migrate

以下の ``migrations`` コマンドは、 ``rollback`` を実行するとあなたのデータベースから
テーブルが削除されます。

.. code-block:: bash

    bin/cake migrations rollback

マイグレーションファイルの作成
==============================

マイグレーションファイルは、あなたのアプリケーションの **config/Migration**
ディレクトリーに配置します。マイグレーションファイルの名前には、先頭に
**YYYYMMDDHHMMSS_MigrationName.php** というように作成した日付を付けます。
以下がマイグレーションファイルの例です。

* 20160121163850_CreateProducts.php
* 20160210133047_AddRatingToProducts.php

マイグレーションファイルを作成する最も簡単な方法は ``bake`` CLI
コマンドを使用することです。

マイグレーションファイルに記述可能なメソッドの一覧については、オフィシャルの
`Phinx ドキュメント <https://book.cakephp.org/phinx/0/en/migrations.html>`_
をご覧ください。

.. note::

    ``bake`` オプションを使用する場合、もし望むなら実行する前にマイグレーションを修正できます。

シンタックス
------------

以下の ``bake`` コマンドは、 ``products`` テーブルを追加するためのマイグレーションファイルを
作成します。 :

.. code-block:: bash

    bin/cake bake migration CreateProducts name:string description:text created modified

あなたのデータベースにテーブルの作成、カラムの追加などをするために ``bake`` を使用する場合、
一般に以下の２点を指定します。

* あなたが生成するマイグレーションの名前 (例えば、 ``CreateProducts``)
* マイグレーションで追加や削除を行うテーブルのカラム
  (例えば、 ``name:string description:text created modified``)

規約のために、すべてのスキーマの変更がこれらのシェルコマンドで動作するわけではありません。

さらに、実行内容を完全に制御したいのであれば、空のマイグレーションファイルを
作る事ができます。

.. code-block:: bash

    bin/cake migrations create MyCustomMigration

マイグレーションファイル名
~~~~~~~~~~~~~~~~~~~~~~~~~~

マイグレーション名は下記のパターンに従うことができます。

* (``/^(Create)(.*)/``) 指定したテーブルを作成します。
* (``/^(Drop)(.*)/``) 指定したテーブルを削除します。フィールドの指定は無視されます。
* (``/^(Add).*(?:To)(.*)/``) 指定したテーブルにカラム追加します。
* (``/^(Remove).*(?:From)(.*)/``) 指定のテーブルのカラムを削除します。
* (``/^(Alter)(.*)/``) 指定したテーブルを変更します。 CreateTable と AddField の別名。
* (``/^(Alter).*(?:On)(.*)/``) 指定されたテーブルのフィールドを変更します。

マイグレーションの名前に ``アンダースコアー_形式`` を使用できます。例: create_products

.. versionadded:: cakephp/migrations 1.5.2

    マイグレーションファイル名のキャメルケースへの変換は `migrations プラグイン
    <https://github.com/cakephp/migrations/>`_ の v1.5.2 に含まれます。
    このプラグインのバージョンは、 CakePHP 3.1 以上のリリースで利用できます。
    このプラグインのバージョン以前では、マイグレーション名はアンダースコアー形式です。
    例: 20160121164955_create_products.php

.. warning::

    マイグレーション名は、マイグレーションのクラス名として使われます。そして、
    クラス名はユニークでない場合、他のマイグレーションと衝突するかもしれません。この場合、後日、
    名前を手動で上書きするか、単純にあなたが指定した名前に変更する必要があるかもしれません。

カラムの定義
~~~~~~~~~~~~

コマンドラインでカラムを使用する場合には、次のようなパターンに従っている事を
覚えておくと便利です。 ::

    fieldName:fieldType?[length]:indexType:indexName

例えば、以下はメールアドレスのカラムを指定する方法です。

* ``email:string?``
* ``email:string:unique``
* ``email:string?[50]``
* ``email:string:unique:EMAIL_INDEX``
* ``email:string[120]:unique:EMAIL_INDEX``

fieldType の後のクエスチョンマークは、ヌルを許可するカラムを作成します。

``fieldType`` のための ``length`` パラメーターは任意です。カッコの中に記述します。

フィールド名が ``created`` と ``modified`` 、それに ``_at`` サフィックス付きの
任意のフィールドなら、自動的に ``datetime`` 型が設定されます。

``Phinx`` で一般的に利用可能なフィールドの型は次の通り:

* string
* text
* integer
* biginteger
* float
* decimal
* datetime
* timestamp
* time
* date
* binary
* boolean
* uuid

未確定で無効な値のままのフィールド型を選ぶためのいくつかの発見的手法があります。
デフォルトのフィールド型は ``string`` です。

* id: integer
* created, modified, updated: datetime

テーブルの作成
--------------

テーブルを作成するために ``bake`` が使えます。 :

.. code-block:: bash

    bin/cake bake migration CreateProducts name:string description:text created modified

上記のコマンドラインは、よく似たマイグレーションファイルを生成します。 ::

    <?php
    use Migrations\AbstractMigration;

    class CreateProducts extends AbstractMigration
    {
        /**
         * Change Method.
         *
         * More information on this method is available here:
         * https://book.cakephp.org/phinx/0/en/migrations.html#the-change-method
         * @return void
         */
        public function change()
        {
            $table = $this->table('products');
            $table->addColumn('name', 'string', [
                'default' => null,
                'limit' => 255,
                'null' => false,
            ]);
            $table->addColumn('description', 'text', [
                'default' => null,
                'null' => false,
            ]);
            $table->addColumn('created', 'datetime', [
                'default' => null,
                'null' => false,
            ]);
            $table->addColumn('modified', 'datetime', [
                'default' => null,
                'null' => false,
            ]);
            $table->create();
        }
    }

既存のテーブルにカラムを追加
----------------------------

もしコマンドラインのマイグレーション名が "AddXXXToYYY" といった
書式で、その後にカラム名と型が続けば、カラムの追加を行うコードを含んだ
マイグレーションファイルが生成されます。 :

.. code-block:: bash

    bin/cake bake migration AddPriceToProducts price:decimal

コマンドラインを実行すると下記のようなファイルが生成されます。 ::

    <?php
    use Migrations\AbstractMigration;

    class AddPriceToProducts extends AbstractMigration
    {
        public function change()
        {
            $table = $this->table('products');
            $table->addColumn('price', 'decimal')
                  ->update();
        }
    }

テーブルにインデックスとしてカラムを追加
----------------------------------------

カラムにインデックスを追加することも可能です。 :

.. code-block:: bash

    bin/cake bake migration AddNameIndexToProducts name:string:index

このようなファイルが生成されます。 ::

    <?php
    use Migrations\AbstractMigration;

    class AddNameIndexToProducts extends AbstractMigration
    {
        public function change()
        {
            $table = $this->table('products');
            $table->addColumn('name', 'string')
                  ->addIndex(['name'])
                  ->update();
        }
    }

フィールド長を指定
------------------

.. versionadded:: cakephp/migrations 1.4

もし、フィールド長を指定する必要がある場合、フィールドタイプにカギ括弧の中で指定できます。例:

.. code-block:: bash

    bin/cake bake migration AddFullDescriptionToProducts full_description:string[60]

上記のコマンドラインを実行すると生成されます。 ::

    <?php
    use Migrations\AbstractMigration;

    class AddFullDescriptionToProducts extends AbstractMigration
    {
        public function change()
        {
            $table = $this->table('products');
            $table->addColumn('full_description', 'string', [
                'default' => null,
                'limit' => 60,
                'null' => false,
            ])
            ->update();
        }
    }

長さが未指定の場合、いくつかのカラム型の長さは初期値が設定されます。

* string: 255
* integer: 11
* biginteger: 20

テーブルから列を変更する
-----------------------------------

同様に、移行名が「AlterXXXOnYYY」の形式の場合、コマンドラインを使用して、列を変更する移行を生成できます。

.. code-block:: bash

    bin/cake bake migration AlterPriceOnProducts name:float

生成されます::

    <?php
    use Migrations\AbstractMigration;

    class AlterPriceFromProducts extends AbstractMigration
    {
        public function change()
        {
            $table = $this->table('products');
            $table->changeColumn('name', 'float');
            $table->update();
        }
    }

テーブルからカラムを削除
------------------------

もしマイグレーション名が "RemoveXXXFromYYY" であるなら、同様にコマンドラインを使用して、
カラム削除のマイグレーションファイルを生成することができます。  :

.. code-block:: bash

    bin/cake bake migration RemovePriceFromProducts price

このようなファイルが生成されます。 ::

    <?php
    use Migrations\AbstractMigration;

    class RemovePriceFromProducts extends AbstractMigration
    {
        public function up()
        {
            $table = $this->table('products');
            $table->removeColumn('price')
                  ->save();
        }
    }

.. note::

    `removeColumn` は不可逆ですので、 `up` メソッドの中で呼び出してください。
    それに対する `addColumn` の呼び出しは、 `down` メソッドに追加してください。

既存のデータベースからマイグレーションファイルを作成する
--------------------------------------------------------

もしあなたが既存のデータベースで、マイグレーションの使用を始めたい場合や、
あなたのアプリケーションのデータベースで初期状態のスキーマのバージョン管理を
行いたい場合、 ``migration_snapshot`` コマンドを実行します。 :

.. code-block:: bash

    bin/cake bake migration_snapshot Initial

これはデータベース内のすべてのテーブルの create 文を含んだ **YYYYMMDDHHMMSS_Initial.php**
と呼ばれるマイグレーションファイルを生成します。

デフォルトで、スナップショットは、 ``default`` 接続設定で定義されたデータベースに
接続することによって作成されます。
もし、異なるデータベースからスナップショットを bake する必要があるなら、
``--connection`` オプションが使用できます。 :

.. code-block:: bash

    bin/cake bake migration_snapshot Initial --connection my_other_connection

``--require-table`` フラグを使用することによって対応するモデルクラスを定義したテーブルだけを
含まれることを確認することができます。 :

.. code-block:: bash

    bin/cake bake migration_snapshot Initial --require-table

``--require-table`` フラグを使用した時、シェルは、あなたのアプリケーションを通して
``Table`` クラスを見つけて、スナップショットのモデルテーブルのみ追加します。

プラグインのためのスナップショットを bake したい場合、同じロジックが暗黙的に適用されます。
そうするために、 ``--plugin`` オプションを使用する必要があります。 :

.. code-block:: bash

    bin/cake bake migration_snapshot Initial --plugin MyPlugin

定義された ``Table`` オブジェクトモデルを持つテーブルだけプラグインのスナップショットに
追加されます。

.. note::

    プラグインのためのスナップショットを bake した時、マイグレーションファイルは、
    あなたのプラグインの **config/Migrations** ディレクトリーに作成されます。

スナップショットを bake した時、phinx のログテーブルに自動的に追加されることに注意してください。

２つのデータベース間の状態の差分を生成する
=============================================

.. versionadded:: cakephp/migrations 1.6.0

``migration_diff`` の bake テンプレートを使用して２つのデータベースの状態の
すべての差分をまとめたマイグレーションファイルを生成することができます。
そのためには、以下のコマンドを使用します。 :

.. code-block:: bash

    bin/cake bake migration_diff NameOfTheMigrations

現在のデータベースの状態からの比較のポイントを保持するために、migrations シェルは、
``migrate`` もしくは ``rollback`` が呼ばれた後に "dump" ファイルを生成します。
ダンプファイルは、取得した時点でのあなたのデータベースの全スキーマの状態を含むファイルです。

一度ダンプファイルが生成されると、あなたのデータベース管理システムに直接行ったすべての変更は、
``bake migration_diff`` コマンドが呼ばれた時に生成されたマイグレーションファイルに追加されます。

デフォルトでは、 ``default`` 接続設定に定義されたデータベースに接続することによって
差分が作成されます。もし、あなたが異なるデータソースから差分を bake する必要がある場合、
``--connection`` オプションを使用できます。 :

.. code-block:: bash

    bin/cake bake migration_diff NameOfTheMigrations --connection my_other_connection

もし、すでにマイグレーションの履歴を持つアプリケーション上で diff 機能を使用したい場合、
マニュアルで比較に使用するダンプファイルを作成する必要があります。 :

.. code-block:: bash

    bin/cake migrations dump

データベースの状態は、あなたがダンプファイルを作成する前にマイグレーションを全て実行した状態と
同じでなければなりません。一度ダンプファイルが生成されると、あなたのデータベースの変更を始めて、
都合の良い時に ``bake migration_diff`` コマンドを使用することができます。

.. note::

    migrations シェルは、カラム名の変更は検知できません。

コマンド
========

``migrate`` : マイグレーションを適用する
----------------------------------------

マイグレーションファイルを生成したり記述したら、以下のコマンドを実行して
変更をデータベースに適用しましょう。 :

.. code-block:: bash

    # マイグレーションをすべて実行
    bin/cake migrations migrate

    # 特定のバージョンに移行するためには、 ``--target`` オプション
    # （省略形は ``-t`` ）を使用します。
    # これはマイグレーションファイル名の前に付加されるタイムスタンプに対応しています。
    bin/cake migrations migrate -t 20150103081132

    # デフォルトで、マイグレーションファイルは、 **config/Migrations** ディレクトリーに
    # あります。 ``--source`` オプション (省略形は ``-s``) を使用することで、
    # ディレクトリーを指定できます。
    # 次の例は、 **config/Alternate** ディレクトリー内でマイグレーションを実行します。
    bin/cake migrations migrate -s Alternate

    # ``--connection`` オプション (省略形は ``-c``) を使用することで
    # ``default`` とは異なる接続でマイグレーションを実行できます。
    bin/cake migrations migrate -c my_custom_connection

    # マイグレーションは、プラグインのためにも実行できます。 ``--plugin`` オプション
    # (省略形は ``-p``) を使用します。
    bin/cake migrations migrate -p MyAwesomePlugin

``rollback`` : マイグレーションを戻す
-------------------------------------

ロールバックコマンドは、このプラグインを実行する前の状態に戻すために使われます。
これは ``migrate`` コマンドの逆向きの動作をします。 :

.. code-block:: bash

    # あなたは ``rollback`` コマンドを使って以前のマイグレーション状態に戻すことができます。
    bin/cake migrations rollback

    # また、特定のバージョンに戻すために、マイグレーションバージョン番号を引き渡すこともできます。
    bin/cake migrations rollback -t 20150103081132

``migrate`` コマンドのように ``--source`` 、 ``--connection`` そして ``--plugin``
オプションが使用できます。

``status`` : マイグレーションのステータス
-----------------------------------------

Status コマンドは、現在の状況とすべてのマイグレーションのリストを出力します。
あなたはマイグレーションが実行されたかを判断するために、このコマンドを使用することができます。 :

.. code-block:: bash

    bin/cake migrations status

``--format`` (省略形は ``-f``) オプションを使用することで
JSON 形式の文字列として結果を出力できます。 :

.. code-block:: bash

    bin/cake migrations status --format json

``migrate`` コマンドのように ``--source`` 、 ``--connection`` そして ``--plugin``
オプションが使用できます。

``mark_migrated`` : マイグレーション済みとしてマーキングする
------------------------------------------------------------

.. versionadded:: 1.4.0

時には、実際にはマイグレーションを実行せずにマークだけすることが便利な事もあります。
これを実行するためには、 ``mark_migrated`` コマンドを使用します。
コマンドは、他のコマンドとしてシームレスに動作します。

このコマンドを使用して、すべてのマイグレーションをマイグレーション済みとして
マークすることができます。 :

.. code-block:: bash

    bin/cake migrations mark_migrated

また、 ``--target`` オプションを使用して、指定したバージョンに対して、
すべてマイグレーション済みとしてマークすることができます。 :

.. code-block:: bash

    bin/cake migrations mark_migrated --target=20151016204000

もし、指定したマイグレーションを処理中にマーク済みにしたくない場合、
``--exclude`` フラグをつけて使用することができます。 :

.. code-block:: bash

    bin/cake migrations mark_migrated --target=20151016204000 --exclude

最後に、指定したマイグレーションだけをマイグレーション済みとしてマークしたい場合、
``--only`` フラグを使用できます。 :

.. code-block:: bash

    bin/cake migrations mark_migrated --target=20151016204000 --only

``migrate`` コマンドのように ``--source`` 、 ``--connection`` そして ``--plugin``
オプションが使用できます。

.. note::

    あなたが ``cake bake migration_snapshot`` コマンドでスナップショットを作成したとき、
    自動的にマイグレーション済みとしてマーキングされてマイグレーションが作成されます。

.. deprecated:: 1.4.0

    以下のコマンドの使用方法は非推奨になりました。もし、あなたが 1.4.0 より前のバージョンの
    プラグインの場合のみに使用してください。

このコマンドは、引数としてマイグレーションバージョン番号を想定しています。 :

.. code-block:: bash

    bin/cake migrations mark_migrated 20150420082532

もし、すべてのマイグレーションをマイグレーション済みとしてマークしたい場合、
特別な値 ``all`` を使用できます。もし使用した場合、すべての見つかったマイグレーションを
マイグレーション済みとしてマークします。 :

.. code-block:: bash

    bin/cake migrations mark_migrated all

``seed`` : データベースの初期データ投入
----------------------------------------

1.5.5 より、データベースの初期データ投入のために ``migrations`` シェルが使用できます。
これは、 `Phinx ライブラリーの seed 機能 <https://book.cakephp.org/phinx/0/en/seeding.html>`_
を利用しています。デフォルトで、seed ファイルは、あなたのアプリケーションの ``config/Seeds``
ディレクトリーの中に置かれます。 `seed ファイル作成のための Phinx の命令
<https://book.cakephp.org/phinx/0/en/seeding.html#creating-a-new-seed-class>`_
を確認してください。

マイグレーションに関して、 seed ファイルのための ``bake`` インターフェースが提供されます。 :

.. code-block:: bash

    # これは、あなたのアプリケーションの config/Seeds ディレクトリー内に ArticlesSeed.php を作成します。
    # デフォルトでは、変換対象の seed は、 "tableized" バージョンの seed ファイル名です。
    bin/cake bake seed Articles

    # ``--table`` オプションを使用することで seed ファイルに変換するテーブル名を指定します。
    bin/cake bake seed Articles --table my_articles_table

    # bake するプラグインを指定できます。
    bin/cake bake seed Articles --plugin PluginName

    # シーダーの生成時に別の接続を指定できます。
    bin/cake bake seed Articles --connection connection

.. versionadded:: cakephp/migrations 1.6.4

    オプションの ``--data``, ``--limit`` そして ``--fields`` は、
    データベースからデータをエクスポートするために追加されました。

1.6.4 から、 ``bake seed`` コマンドは、 ``--data`` フラグを使用することによって、
データベースからエクスポートされたデータを元に seed ファイルを作成することができます。 :

.. code-block:: bash

    bin/cake bake seed --data Articles

デフォルトでは、テーブル内にある行を全てエクスポートします。 ``--limit`` オプションを
使用することによって、エクスポートされる行の数を制限できます。 :

.. code-block:: bash

    # 10 行のみエクスポート
    bin/cake bake seed --data --limit 10 Articles

もし、seed ファイルの中にテーブルから選択したフィールドのみを含めたい場合、
``--fields`` オプションが使用できます。そのオプションは、
フィールドのリストをカンマ区切りの値の文字列として含めます。 :

.. code-block:: bash

    # `id`, `title` そして `excerpt` フィールドのみをエクスポート
    bin/cake bake seed --data --fields id,title,excerpt Articles

.. tip::

    もちろん、同じコマンド呼び出し中に ``--limit`` と ``--fields``
    オプションの両方が利用できます。

データベースの初期データ投入のために、 ``seed`` サブコマンドが使用できます。 :

.. code-block:: bash

    # パラメーターなしの seed サブコマンドは、対象のディレクトリーのアルファベット順で、
    # すべての利用可能なシーダーを実行します。
    bin/cake migrations seed

    # `--seed` オプションを使用して実行するための一つだけシーダーを指定できます。
    bin/cake migrations seed --seed ArticlesSeed

    # 別のディレクトリーでシーダーを実行できます。
    bin/cake migrations seed --source AlternativeSeeds

    # プラグインのシーダーを実行できます
    bin/cake migrations seed --plugin PluginName

    # 指定したコネクションでシーダーを実行できます
    bin/cake migrations seed --connection connection

マイグレーションとは対照的にシーダーは追跡されないことに注意してください。
それは、同じシーダーは、複数回適用することができることを意味します。

シーダーから別のシーダーの呼び出し
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: cakephp/migrations 1.6.2

たいてい初期データ投入時は、データの挿入する順番は、規約違反しないように遵守しなければなりません。
デフォルトでは、アルファベット順でシーダーが実行されますが、独自にシーダーの実行順を定義するために
``\Migrations\AbstractSeed::call()`` メソッドが利用できます。 ::

    use Migrations\AbstractSeed;

    class DatabaseSeed extends AbstractSeed
    {
        public function run(): void
        {
            $this->call('AnotherSeed');
            $this->call('YetAnotherSeed');

            // プラグインからシーダーを呼ぶためにプラグインドット記法が使えます
            $this->call('PluginName.FromPluginSeed');
        }
    }

.. note::

    もし、 ``call()`` メソッドを使いたい場合、Migrations プラグインの ``AbstractSeed``
    クラスを継承していることを確認してください。このクラスは、リリース 1.6.2 で追加されました。

``dump`` : 差分を bake する機能のためのダンプファイルの生成
-------------------------------------------------------------

dump コマンドは、 ``migration_diff`` の bake テンプレートで使用するファイルを作成します。 :

.. code-block:: bash

    bin/cake migrations dump

各生成されたダンプファイルは、生成元の接続固有のものです（そして、そのようにサフィックスされます）。
これは、アプリケーションが、異なるデータベースベンダーの複数のデータベースを扱う場合、
``bake migration_diff`` コマンドで正しく差分を算出することができます。

ダンプファイルは、マイグレーションファイルと同じディレクトリーに作成されます。

``migrate`` コマンドのように ``--source`` 、 ``--connection`` そして ``--plugin``
オプションが使用できます。

プラグイン内のマイグレーションファイルを使う
============================================

プラグインはマイグレーションファイルも提供することができます。
これはプラグインの移植性とインストールの容易さを高め、配布しやすくなるように意図されています。
Migrations プラグインの全てのコマンドは、プラグイン関連のマイグレーションを行うための
``--plugin`` か ``-p`` オプションをサポートしています。 :

.. code-block:: bash

    bin/cake migrations status -p PluginName

    bin/cake migrations migrate -p PluginName

非シェルの環境でマイグレーションを実行する
==========================================

.. versionadded:: cakephp/migrations 1.2.0

migrations プラグインのバージョン 1.2 から、非シェル環境でも app から直接
``Migrations`` クラスを使ってマイグレーションを実行できるようになりました。
これは CMS のプラグインインストーラーを作る時などに便利です。
``Migrations`` クラスを使用すると、マイグレーションシェルから下記のコマンドを
実行することができます。:

* migrate
* rollback
* markMigrated
* status
* seed

それぞれのコマンドは ``Migrations`` クラスのメソッドとして実装されています。

使い方は以下の通りです。 ::

    use Migrations\Migrations;

    $migrations = new Migrations();

    // 全てのマイグレーションバージョンとそのステータスの配列を返します。
    $status = $migrations->status();

    // 成功した場合、 true を返し、エラーが発生した場合、例外が投げられます。
    $migrate = $migrations->migrate();

    // 成功した場合、 true を返し、エラーが発生した場合、例外が投げられます。
    $rollback = $migrations->rollback();

    // 成功した場合、 true を返し、エラーが発生した場合、例外が投げられます。
    $markMigrated = $migrations->markMigrated(20150804222900);

    // 成功した場合、 true を返し、エラーが発生した場合、例外が投げられます。
    $seeded = $migrations->seed();

メソッドはコマンドラインのオプションと同じパラメーター配列を受け取ります。 ::

    use Migrations\Migrations;

    $migrations = new Migrations();

    // 全てのマイグレーションバージョンとそのステータスの配列を返す
    $status = $migrations->status(['connection' => 'custom', 'source' => 'MyMigrationsFolder']);

あなたはシェルコマンドのように任意のオプションを引き渡すことができます。
唯一の例外は ``markMigrated`` コマンドで、第１引数にはマイグレーション済みとして
マーキングしたいマイグレーションバージョン番号を渡し、第２引数にパラメーターの配列を
渡します。

必要に応じて、クラスのコンストラクターでこれらのパラメーターを引き渡すことができます。
それはデフォルトとして使用され、それぞれのメソッド呼び出しの時に引き渡されることを
防止します。 ::

    use Migrations\Migrations;

    $migrations = new Migrations(['connection' => 'custom', 'source' => 'MyMigrationsFolder']);

    // 以下のすべての呼び出しは、マイグレーションクラスのコンストラクターに渡されたパラメーターを使用して行われます
    $status = $migrations->status();
    $migrate = $migrations->migrate();

個別の呼び出しでデフォルトのパラメーターを上書きしたい場合は、メソッド呼び出し時に引き渡します。 ::

    use Migrations\Migrations;

    $migrations = new Migrations(['connection' => 'custom', 'source' => 'MyMigrationsFolder']);

    // この呼び出しでは "custom" コネクションを使用します。
    $status = $migrations->status();
    // こちらでは "default" コネクションを使用します。
    $migrate = $migrations->migrate(['connection' => 'default']);

小技と裏技
===============

主キーをカスタマイズする
------------------------

あなたがデータベースに新しいテーブルを作成する時、 ``id`` を主キーとして
自動生成したくない場合、 ``table()`` メソッドの第２引数を使うことができます。 ::

    <?php
    use Migrations\AbstractMigration;

    class CreateProductsTable extends AbstractMigration
    {
        public function change()
        {
            $table = $this->table('products', ['id' => false, 'primary_key' => ['id']]);
            $table
                  ->addColumn('id', 'uuid')
                  ->addColumn('name', 'string')
                  ->addColumn('description', 'text')
                  ->create();
        }
    }

上記の例では、 ``CHAR(36)`` の ``id`` というカラムを主キーとして作成します。

.. note::

    独自の主キーをコマンドラインで指定した時、id フィールドの中の主キーとして注意してください。
    そうしなければ、id フィールドが重複してエラーになります。例:

    .. code-block:: bash

        bin/cake bake migration CreateProducts id:uuid:primary name:string description:text created modified

さらに、Migrations 1.3 以降では 主キーに対処するための新しい方法が導入されました。
これを行うには、あなたのマイグレーションクラスは新しい ``Migrations\AbstractMigration``
クラスを継承する必要があります。
あなたは Migration クラスの ``autoId`` プロパティーに ``false`` を設定することで、
自動的な ``id`` カラムの生成をオフにすることができます。
あなたは手動で主キーカラムを作成し、テーブル宣言に追加する必要があります。 ::

    <?php
    use Migrations\AbstractMigration;

    class CreateProductsTable extends AbstractMigration
    {

        public bool $autoId = false;

        public function up()
        {
            $table = $this->table('products');
            $table
                ->addColumn('id', 'integer', [
                    'autoIncrement' => true,
                    'limit' => 11
                ])
                ->addPrimaryKey('id')
                ->addColumn('name', 'string')
                ->addColumn('description', 'text')
                ->create();
        }
    }

主キーを扱うこれまでの方法と比較すると、この方法は、unsigned や not や limit や comment など
さらに多くの主キーの定義を操作することができるようになっています。

Bake で生成されたマイグレーションファイルとスナップショットは、この新しい方法を
必要に応じて使用します。

.. warning::

    主キーの操作ができるのは、テーブル作成時のみです。これはプラグインがサポートしている
    いくつかのデータベースサーバーの制限によるものです。

照合順序
--------

もしデータベースのデフォルトとは別の照合順序を持つテーブルを作成する必要がある場合は、
``table()`` メソッドのオプションとして定義することができます。::

    <?php
    use Migrations\AbstractMigration;

    class CreateCategoriesTable extends AbstractMigration
    {
        public function change()
        {
            $table = $this
                ->table('categories', [
                    'collation' => 'latin1_german1_ci'
                ])
                ->addColumn('title', 'string', [
                    'default' => null,
                    'limit' => 255,
                    'null' => false,
                ])
                ->create();
        }
    }

ですが、これはテーブル作成時にしかできず、既存のテーブルに対してカラムを追加する時に
テーブルやデータベースと異なる照合順序を指定する方法がないことに注意してください。
ただ ``MySQL`` と ``SqlServer`` だけはこの設定キーをサポートしています。

カラム名の更新と Table オブジェクトの使用
-----------------------------------------

カラムのリネームや移動とともに、あなたのデータベースから値を操作するために
CakePHP ORM Table オブジェクトを使用している場合、 ``update()`` を呼んだ後に Table
オブジェクトの新しいインスタンスを作成できることを確かめてください。
インスタンス上の Table オブジェクトに反映し保存されたスキーマをリフレッシュするために
Table オブジェクトのレジストリーは、 ``update()`` が呼ばれた後にクリアされます。

マイグレーションとデプロイメント
--------------------------------

もし、アプリケーションをデプロイする時にプラグインを使用する場合、
テーブルのカラムメタデータを更新するように、必ず ORM キャッシュをクリアしてください。
そうしなければ、それらの新しいカラムの操作を実行する時に、カラムが存在しないエラーになります。
CakePHP コアは、この操作を行うために使用できる `スキーマキャッシュシェル
<https://book.cakephp.org/3.0/ja/console-and-shells/schema-cache.html>`__ を含みます。 :

.. code-block:: bash

    // 3.6.0 より前の場合、orm_cache を使用
    bin/cake schema_cache clear

このシェルについてもっと知りたい場合、クックブックの
`スキーマキャッシュシェル <https://book.cakephp.org/3.0/ja/console-and-shells/schema-cache.html>`__
セクションをご覧ください。

テーブルのリネーム
------------------

プラグインは、 ``rename()`` メソッドを使用することでテーブルのリネームができます。
あなたのマイグレーションファイルの中で、以下のように記述できます。 ::

    public function up()
    {
        $this->table('old_table_name')
            ->rename('new_table_name')
            ->save();
    }

``schema.lock`` ファイル生成のスキップ
--------------------------------------------

.. versionadded:: cakephp/migrations 1.6.5

diff 機能を動作させるために、 **.lock** ファイルは、migrate、rollback または
スナップショットの bake の度に生成され、指定された時点でのデータベーススキーマの状態を追跡します。
例えば本番環境上にデプロイするときなど、前述のコマンドに ``--no-lock``
オプションを使用することによって、このファイルの生成をスキップすることができます。 :

.. code-block:: bash

    bin/cake migrations migrate --no-lock

    bin/cake migrations rollback --no-lock

    bin/cake bake migration_snapshot MyMigration --no-lock

