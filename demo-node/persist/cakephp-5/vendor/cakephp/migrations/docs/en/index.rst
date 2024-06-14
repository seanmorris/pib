Migrations
##########

Migrations is a plugin supported by the core team that helps you do schema
changes in your database by writing PHP files that can be tracked using your
version control system.

It allows you to evolve your database tables over time. Instead of writing
schema modifications in SQL, this plugin allows you to use an intuitive set of
methods to implement your database changes.

This plugin is a wrapper for the database migrations library `Phinx <https://phinx.org/>`_.

Installation
============

By default Migrations is installed with the default application skeleton. If
you've removed it and want to re-install it, you can do so by running the
following from your application's ROOT directory (where composer.json file is
located):

.. code-block:: bash

    php composer.phar require cakephp/migrations "@stable"

    # Or if composer is installed globally
    composer require cakephp/migrations "@stable"

To use the plugin you'll need to load it in your application's
**config/bootstrap.php** file. You can use `CakePHP's Plugin shell
<https://book.cakephp.org/3.0/en/console-and-shells/plugin-shell.html>`__ to
load and unload plugins from your **config/bootstrap.php**:

.. code-block:: bash

    bin/cake plugin load Migrations

Or you can load the plugin by editing your **src/Application.php** file and
adding the following statement::

    $this->addPlugin('Migrations');

    // Prior to 3.6.0 you need to use Plugin::load()

Additionally, you will need to configure the default database configuration for
your application in your **config/app.php** file as explained in the `Database
Configuration section
<https://book.cakephp.org/3.0/en/orm/database-basics.html#database-configuration>`__.

Overview
========

A migration is basically a single PHP file that describes the changes to operate
to the database. A migration file can create or drop tables, add or remove
columns, create indexes and even insert data into your database.

Here's an example of a migration::

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

This migration will add a table to your database named ``products`` with the
following column definitions:

- ``id`` column of type ``integer`` as primary key
- ``name`` column of type ``string``
- ``description`` column of type ``text``
- ``created`` column of type ``datetime``
- ``modified`` column of type ``datetime``

.. tip::

    The primary key column named ``id`` will be added **implicitly**.

.. note::

    Note that this file describes how the database will look **after**
    applying the migration. At this point no ``products`` table exists in
    your database, we have merely created a file that is able to both create
    the ``products`` table with the specified columns as well as drop it
    when a ``rollback`` operation of the migration is performed.

Once the file has been created in the **config/Migrations** folder, you will be
able to execute the following ``migrations`` command to create the table in
your database:

.. code-block:: bash

    bin/cake migrations migrate

The following ``migrations`` command will perform a ``rollback`` and drop the
table from your database:

.. code-block:: bash

    bin/cake migrations rollback

Creating Migrations
===================

Migration files are stored in the **config/Migrations** directory of your
application. The name of the migration files are prefixed with the date in
which they were created, in the format **YYYYMMDDHHMMSS_MigrationName.php**.
Here are examples of migration filenames:

* 20160121163850_CreateProducts.php
* 20160210133047_AddRatingToProducts.php

The easiest way to create a migrations file is by using ``bin/cake bake
migration`` CLI command.

Please make sure you read the official
`Phinx documentation <https://book.cakephp.org/phinx/0/en/migrations.html>`_
in order to know the complete list of methods you can use for writing migration
files.

.. note::

    When using the ``bake`` option, you can still modify the migration before
    running them if so desired.

Syntax
------

The ``bake`` command syntax follows the form below:

.. code-block:: bash

    bin/cake bake migration CreateProducts name:string description:text created modified

When using ``bake`` to create tables, add columns and so on, to your
database, you will usually provide two things:

* the name of the migration you will generate (``CreateProducts`` in our
  example)
* the columns of the table that will be added or removed in the migration
  (``name:string description:text created modified`` in our example)

Due to the conventions, not all schema changes can be performed via these shell
commands.

Additionally you can create an empty migrations file if you want full control
over what needs to be executed, by omitting to specify a columns definition:

.. code-block:: bash

    bin/cake migrations create MyCustomMigration

Migrations file name
~~~~~~~~~~~~~~~~~~~~

Migration names can follow any of the following patterns:

* (``/^(Create)(.*)/``) Creates the specified table.
* (``/^(Drop)(.*)/``) Drops the specified table.
  Ignores specified field arguments
* (``/^(Add).*(?:To)(.*)/``) Adds fields to the specified
  table
* (``/^(Remove).*(?:From)(.*)/``) Removes fields from the
  specified table
* (``/^(Alter)(.*)/``) Alters the specified table. An alias
  for CreateTable and AddField.
* (``/^(Alter).*(?:On)(.*)/``) Alters fields from the specified table.

You can also use the ``underscore_form`` as the name for your migrations i.e.
``create_products``.

.. versionadded:: cakephp/migrations 1.5.2

    As of v1.5.2 of the `migrations plugin <https://github.com/cakephp/migrations/>`_,
    the migration filename will be automatically camelized. This version of the
    plugin is only available with a release of CakePHP >= to 3.1. Prior to this
    version of the plugin the migration name would be in the underscore form,
    i.e. ``20160121164955_create_products.php``.

.. warning::

    Migration names are used as migration class names, and thus may collide with
    other migrations if the class names are not unique. In this case, it may be
    necessary to manually override the name at a later date, or simply change
    the name you are specifying.

Columns definition
~~~~~~~~~~~~~~~~~~

When using columns in the command line, it may be handy to remember that they
follow the following pattern::

    fieldName:fieldType?[length]:indexType:indexName

For instance, the following are all valid ways of specifying an email field:

* ``email:string?``
* ``email:string:unique``
* ``email:string?[50]``
* ``email:string:unique:EMAIL_INDEX``
* ``email:string[120]:unique:EMAIL_INDEX``

While defining decimal, the ``length`` can be defined to have precision and scale, separated by a comma.

* ``amount:decimal[5,2]``
* ``amount:decimal?[5,2]``

The question mark following the fieldType will make the column nullable.

The ``length`` parameter for the ``fieldType`` is optional and should always be
written between bracket.

Fields named ``created`` and ``modified``, as well as any field with a ``_at``
suffix, will automatically be set to the type ``datetime``.

Field types are those generically made available by the ``Phinx`` library. Those
can be:

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

There are some heuristics to choosing fieldtypes when left unspecified or set to
an invalid value. Default field type is ``string``:

* id: integer
* created, modified, updated: datetime
* latitude, longitude (or short forms lat, lng): decimal

Creating a table
----------------

You can use ``bake`` to create a table:

.. code-block:: bash

    bin/cake bake migration CreateProducts name:string description:text created modified

The command line above will generate a migration file that resembles::

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

Adding columns to an existing table
-----------------------------------

If the migration name in the command line is of the form "AddXXXToYYY" and is
followed by a list of column names and types then a migration file containing
the code for creating the columns will be generated:

.. code-block:: bash

    bin/cake bake migration AddPriceToProducts price:decimal[5,2]

Executing the command line above will generate::

    <?php
    use Migrations\AbstractMigration;

    class AddPriceToProducts extends AbstractMigration
    {
        public function change()
        {
            $table = $this->table('products');
            $table->addColumn('price', 'decimal', [
                'default' => null,
                'null' => false,
                'precision' => 5,
                'scale' => 2,
            ]);
            $table->update();
        }
    }

Adding a column as index to a table
-----------------------------------

It is also possible to add indexes to columns:

.. code-block:: bash

    bin/cake bake migration AddNameIndexToProducts name:string:index

will generate::

    <?php
    use Migrations\AbstractMigration;

    class AddNameIndexToProducts extends AbstractMigration
    {
        public function change()
        {
            $table = $this->table('products');
            $table->addColumn('name', 'string')
                  ->addColumn('email', 'string')
                  ->addIndex(['name'])
                  // add a unique index:
                  ->addIndex('email', ['unique' => true])
                  ->update();
        }
    }

Specifying field length
-----------------------

.. versionadded:: cakephp/migrations 1.4

If you need to specify a field length, you can do it within brackets in the
field type, ie:

.. code-block:: bash

    bin/cake bake migration AddFullDescriptionToProducts full_description:string[60]

Executing the command line above will generate::

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

If no length is specified, lengths for certain type of columns are defaulted:

* string: 255
* integer: 11
* biginteger: 20

Alter a column from a table
-----------------------------------

In the same way, you can generate a migration to alter a column by using the
command line, if the migration name is of the form "AlterXXXOnYYY":

.. code-block:: bash

    bin/cake bake migration AlterPriceOnProducts name:float

will generate::

    <?php
    use Migrations\AbstractMigration;

    class AlterPriceOnProducts extends AbstractMigration
    {
        public function change()
        {
            $table = $this->table('products');
            $table->changeColumn('name', 'float');
            $table->update();
        }
    }

Removing a column from a table
------------------------------

In the same way, you can generate a migration to remove a column by using the
command line, if the migration name is of the form "RemoveXXXFromYYY":

.. code-block:: bash

    bin/cake bake migration RemovePriceFromProducts price

creates the file::

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

    The `removeColumn` command is not reversible, so must be called in the
    `up` method. A corresponding `addColumn` call should be added to the
    `down` method.

Generating migrations from an existing database
===============================================

If you are dealing with a pre-existing database and want to start using
migrations, or to version control the initial schema of your application's
database, you can run the ``migration_snapshot`` command:

.. code-block:: bash

    bin/cake bake migration_snapshot Initial

It will generate a migration file called **YYYYMMDDHHMMSS_Initial.php**
containing all the create statements for all tables in your database.

By default, the snapshot will be created by connecting to the database defined
in the ``default`` connection configuration.
If you need to bake a snapshot from a different datasource, you can use the
``--connection`` option:

.. code-block:: bash

    bin/cake bake migration_snapshot Initial --connection my_other_connection

You can also make sure the snapshot includes only the tables for which you have
defined the corresponding model classes by using the ``--require-table`` flag:

.. code-block:: bash

    bin/cake bake migration_snapshot Initial --require-table

When using the ``--require-table`` flag, the shell will look through your
application ``Table`` classes and will only add the model tables in the snapshot
.

The same logic will be applied implicitly if you wish to bake a snapshot for a
plugin. To do so, you need to use the ``--plugin`` option:

.. code-block:: bash

    bin/cake bake migration_snapshot Initial --plugin MyPlugin

Only the tables which have a ``Table`` object model class defined will be added
to the snapshot of your plugin.

.. note::

    When baking a snapshot for a plugin, the migration files will be created
    in your plugin's **config/Migrations** directory.

Be aware that when you bake a snapshot, it is automatically added to the phinx
log table as migrated.

Generating a diff between two database states
=============================================

.. versionadded:: cakephp/migrations 1.6.0

You can generate a migrations file that will group all the differences between
two database states using the ``migration_diff`` bake template. To do so, you
can use the following command:

.. code-block:: bash

    bin/cake bake migration_diff NameOfTheMigrations

In order to have a point of comparison from your current database state, the
migrations shell will generate a "dump" file after each ``migrate`` or
``rollback`` call. The dump file is a file containing the full schema state of
your database at a given point in time.

Once a dump file is generated, every modifications you do directly in your
database management system will be added to the migration file generated when
you call the ``bake migration_diff`` command.

By default, the diff will be created by connecting to the database defined
in the ``default`` connection configuration.
If you need to bake a diff from a different datasource, you can use the
``--connection`` option:

.. code-block:: bash

    bin/cake bake migration_diff NameOfTheMigrations --connection my_other_connection

If you want to use the diff feature on an application that already has a
migrations history, you need to manually create the dump file that will be used
as comparison:

.. code-block:: bash

    bin/cake migrations dump

The database state must be the same as it would be if you just migrated all
your migrations before you create a dump file.
Once the dump file is generated, you can start doing changes in your database
and use the ``bake migration_diff`` command whenever you see fit.

.. note::

    The migrations shell can not detect column renamings.

The commands
============

``migrate`` : Applying Migrations
---------------------------------

Once you have generated or written your migration file, you need to execute the
following command to apply the changes to your database:

.. code-block:: bash

    # Run all the migrations
    bin/cake migrations migrate

    # Migrate to a specific version using the ``--target`` option
    # or ``-t`` for short.
    # The value is the timestamp that is prefixed to the migrations file name::
    bin/cake migrations migrate -t 20150103081132

    # By default, migration files are looked for in the **config/Migrations**
    # directory. You can specify the directory using the ``--source`` option
    # or ``-s`` for short.
    # The following example will run migrations in the **config/Alternate**
    # directory
    bin/cake migrations migrate -s Alternate

    # You can run migrations to a different connection than the ``default`` one
    # using the ``--connection`` option or ``-c`` for short
    bin/cake migrations migrate -c my_custom_connection

    # Migrations can also be run for plugins. Simply use the ``--plugin`` option
    # or ``-p`` for short
    bin/cake migrations migrate -p MyAwesomePlugin

``rollback`` : Reverting Migrations
-----------------------------------

The Rollback command is used to undo previous migrations executed by this
plugin. It is the reverse action of the ``migrate`` command:

.. code-block:: bash

    # You can rollback to the previous migration by using the
    # ``rollback`` command::
    bin/cake migrations rollback

    # You can also pass a migration version number to rollback
    # to a specific version::
    bin/cake migrations rollback -t 20150103081132

You can also use the ``--source``, ``--connection`` and ``--plugin`` options
just like for the ``migrate`` command.

``status`` : Migrations Status
------------------------------

The Status command prints a list of all migrations, along with their current
status. You can use this command to determine which migrations have been run:

.. code-block:: bash

    bin/cake migrations status

You can also output the results as a JSON formatted string using the
``--format`` option (or ``-f`` for short):

.. code-block:: bash

     bin/cake migrations status --format json

You can also use the ``--source``, ``--connection`` and ``--plugin`` options
just like for the ``migrate`` command.

``mark_migrated`` : Marking a migration as migrated
---------------------------------------------------

.. versionadded:: 1.4.0

It can sometimes be useful to mark a set of migrations as migrated without
actually running them.
In order to do this, you can use the ``mark_migrated`` command.
The command works seamlessly as the other commands.

You can mark all migrations as migrated using this command:

.. code-block:: bash

    bin/cake migrations mark_migrated

You can also mark all migrations up to a specific version as migrated using
the ``--target`` option:

.. code-block:: bash

    bin/cake migrations mark_migrated --target=20151016204000

If you do not want the targeted migration to be marked as migrated during the
process, you can use the ``--exclude`` flag with it:

.. code-block:: bash

    bin/cake migrations mark_migrated --target=20151016204000 --exclude

Finally, if you wish to mark only the targeted migration as migrated, you can
use the ``--only`` flag:

.. code-block:: bash

    bin/cake migrations mark_migrated --target=20151016204000 --only

You can also use the ``--source``, ``--connection`` and ``--plugin`` options
just like for the ``migrate`` command.

.. note::

    When you bake a snapshot with the ``cake bake migration_snapshot``
    command, the created migration will automatically be marked as migrated.

.. deprecated:: 1.4.0

    The following way of using the command has been deprecated. Use it only
    if you are using a version of the plugin < 1.4.0.

This command expects the migration version number as argument:

.. code-block:: bash

    bin/cake migrations mark_migrated 20150420082532

If you wish to mark all migrations as migrated, you can use the ``all`` special
value. If you use it, it will mark all found migrations as migrated:

.. code-block:: bash

    bin/cake migrations mark_migrated all

``seed`` : Seeding your database
--------------------------------

As of 1.5.5, you can use the ``migrations`` shell to seed your database. This
leverages the `Phinx library seed feature <https://book.cakephp.org/phinx/0/en/seeding.html>`_.
By default, seed files will be looked for in the ``config/Seeds`` directory of
your application. Please make sure you follow
`Phinx instructions to build your seed files <https://book.cakephp.org/phinx/0/en/seeding.html#creating-a-new-seed-class>`_.

As for migrations, a ``bake`` interface is provided for seed files:

.. code-block:: bash

    # This will create a ArticlesSeed.php file in the directory config/Seeds of your application
    # By default, the table the seed will try to alter is the "tableized" version of the seed filename
    bin/cake bake seed Articles

    # You specify the name of the table the seed files will alter by using the ``--table`` option
    bin/cake bake seed Articles --table my_articles_table

    # You can specify a plugin to bake into
    bin/cake bake seed Articles --plugin PluginName

    # You can specify an alternative connection when generating a seeder.
    bin/cake bake seed Articles --connection connection

.. versionadded:: cakephp/migrations 1.6.4

    Options ``--data``, ``--limit`` and ``--fields`` were added to export
    data from your database.

As of 1.6.4, the ``bake seed`` command allows you to create a seed file with
data exported from your database by using the ``--data`` flag:

.. code-block:: bash

    bin/cake bake seed --data Articles

By default, it will export all the rows found in your table. You can limit the
number of rows exported by using the ``--limit`` option:

.. code-block:: bash

    # Will only export the first 10 rows found
    bin/cake bake seed --data --limit 10 Articles

If you only want to include a selection of fields from the table in your seed
file, you can use the ``--fields`` option. It takes the list of fields to
include as a comma separated value string:

.. code-block:: bash

    # Will only export the fields `id`, `title` and `excerpt`
    bin/cake bake seed --data --fields id,title,excerpt Articles

.. tip::

    Of course you can use both the ``--limit`` and ``--fields`` options in the
    same command call.

To seed your database, you can use the ``seed`` subcommand:

.. code-block:: bash

    # Without parameters, the seed subcommand will run all available seeders
    # in the target directory, in alphabetical order.
    bin/cake migrations seed

    # You can specify only one seeder to be run using the `--seed` option
    bin/cake migrations seed --seed ArticlesSeed

    # You can run seeders from an alternative directory, relative to config
    bin/cake migrations seed --source AlternativeSeeds

    # You can run seeders from a plugin
    bin/cake migrations seed --plugin PluginName

    # You can run seeders from a specific connection
    bin/cake migrations seed --connection connection

Be aware that, as opposed to migrations, seeders are not tracked, which means
that the same seeder can be applied multiple times.

Calling a Seeder from another Seeder
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: cakephp/migrations 1.6.2

Usually when seeding, the order in which to insert the data must be respected
to not encounter constraints violations. Since Seeders are executed in the
alphabetical order by default, you can use the ``\Migrations\AbstractSeed::call()``
method to define your own sequence of seeders execution::

    use Migrations\AbstractSeed;

    class DatabaseSeed extends AbstractSeed
    {
        public function run(): void
        {
            $this->call('AnotherSeed');
            $this->call('YetAnotherSeed');

            // You can use the plugin dot syntax to call seeders from a plugin
            $this->call('PluginName.FromPluginSeed');
        }
    }

.. note::

    Make sure to extend the Migrations plugin ``AbstractSeed`` class if you want
    to be able to use the ``call()`` method. This class was added with release
    1.6.2.

``dump`` : Generating a dump file for the diff baking feature
-------------------------------------------------------------

The Dump command creates a file to be used with the ``migration_diff`` bake
template:

.. code-block:: bash

    bin/cake migrations dump

Each generated dump file is specific to the Connection it is generated from (and
is suffixed as such). This allows the ``bake migration_diff`` command to
properly compute diff in case your application is dealing with multiple database
possibly from different database vendors.

Dump files are created in the same directory as your migrations files.

You can also use the ``--source``, ``--connection`` and ``--plugin`` options
just like for the ``migrate`` command.


Using Migrations for Tests
==========================

If you are using migrations for your application schema you can also use those
same migrations to build schema in your tests. In your application's
``tests/bootstrap.php`` file you can use the ``Migrator`` class to build schema
when tests are run. The ``Migrator`` will use existing schema if it is current,
and if the migration history that is in the database differs from what is in the
filesystem, all tables will be dropped and migrations will be rerun from the
beginning::

    // in tests/bootstrap.php
    use Migrations\TestSuite\Migrator;

    $migrator = new Migrator();

    // Simple setup for with no plugins
    $migrator->run();

    // Run a non 'test' database
    $migrator->run(['connection' => 'test_other']);

    // Run migrations for plugins
    $migrator->run(['plugin' => 'Contacts']);

    // Run the Documents migrations on the test_docs connection.
    $migrator->run(['plugin' => 'Documents', 'connection' => 'test_docs']);


If you need to run multiple sets of migrations, those can be run as follows::

    // Run migrations for plugin Contacts on the ``test`` connection, and Documents on the ``test_docs`` connection
    $migrator->runMany([
        ['plugin' => 'Contacts'],
        ['plugin' => 'Documents', 'connection' => 'test_docs']
    ]);

If your database also contains tables that are not managed by your application
like those created by PostGIS, then you can exclude those tables from the drop
& truncate behavior using the ``skip`` option::

    $migrator->run(['connection' => 'test', 'skip' => ['postgis*']]);

The ``skip`` option accepts a ``fnmatch()`` compatible pattern to exclude tables
from drop & truncate operations.

If you need to see additional debugging output from migrations are being run,
you can enable a ``debug`` level logger.

.. versionadded: 3.2.0
    Migrator was added to complement the new fixtures in CakePHP 4.3.0.

Using Migrations In Plugins
===========================

Plugins can also provide migration files. This makes plugins that are intended
to be distributed much more portable and easy to install. All commands in the
Migrations plugin support the ``--plugin`` or ``-p`` option that will scope the
execution to the migrations relative to that plugin:

.. code-block:: bash

    bin/cake migrations status -p PluginName

    bin/cake migrations migrate -p PluginName

Running Migrations in a non-shell environment
=============================================

.. versionadded:: cakephp/migrations 1.2.0

Since the release of version 1.2 of the migrations plugin, you can run
migrations from a non-shell environment, directly from an app, by using the new
``Migrations`` class. This can be handy in case you are developing a plugin
installer for a CMS for instance.
The ``Migrations`` class allows you to run the following commands from the
migrations shell:

* migrate
* rollback
* markMigrated
* status
* seed

Each of these commands has a method defined in the ``Migrations`` class.

Here is how to use it::

    use Migrations\Migrations;

    $migrations = new Migrations();

    // Will return an array of all migrations and their status
    $status = $migrations->status();

    // Will return true if success. If an error occurred, an exception will be thrown
    $migrate = $migrations->migrate();

    // Will return true if success. If an error occurred, an exception will be thrown
    $rollback = $migrations->rollback();

    // Will return true if success. If an error occurred, an exception will be thrown
    $markMigrated = $migrations->markMigrated(20150804222900);

    // Will return true if success. If an error occurred, an exception will be thrown
    $seeded = $migrations->seed();

The methods can accept an array of parameters that should match options from
the commands::

    use Migrations\Migrations;

    $migrations = new Migrations();

    // Will return an array of all migrations and their status
    $status = $migrations->status(['connection' => 'custom', 'source' => 'MyMigrationsFolder']);

You can pass any options the shell commands would take.
The only exception is the ``markMigrated`` command which is expecting the
version number of the migrations to mark as migrated as first argument. Pass
the array of parameters as the second argument for this method.

Optionally, you can pass these parameters in the constructor of the class.
They will be used as default and this will prevent you from having to pass
them on each method call::

    use Migrations\Migrations;

    $migrations = new Migrations(['connection' => 'custom', 'source' => 'MyMigrationsFolder']);

    // All the following calls will be done with the parameters passed to the Migrations class constructor
    $status = $migrations->status();
    $migrate = $migrations->migrate();

If you need to override one or more default parameters for one call, you can
pass them to the method::

    use Migrations\Migrations;

    $migrations = new Migrations(['connection' => 'custom', 'source' => 'MyMigrationsFolder']);

    // This call will be made with the "custom" connection
    $status = $migrations->status();
    // This one with the "default" connection
    $migrate = $migrations->migrate(['connection' => 'default']);

Feature Flags
=============

Migrations uses Phinx, which has some feature flags that are disabled by default for now, but
can enabled if you want them to:

* ``unsigned_primary_keys``: Should Phinx create primary keys as unsigned integers? (default: ``false``)
* ``column_null_default``: Should Phinx create columns as null by default? (default: ``false``)

Set them via Configure to enable (e.g. in ``config/app.php``)::

    'Migrations' => [
        'unsigned_primary_keys' => true,
        'column_null_default' => true,
    ],

For details see `Phinx documentation <https://book.cakephp.org/phinx/0/en/configuration.html#feature-flags>`_.

Tips and tricks
===============

Creating Custom Primary Keys
----------------------------

If you need to avoid the automatic creation of the ``id`` primary key when
adding new tables to the database, you can use the second argument of the
``table()`` method::

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

The above will create a ``CHAR(36)`` ``id`` column that is also the primary key.

.. note::

    When specifying a custom primary key on the command line, you must note
    it as the primary key in the id field, otherwise you may get an error
    regarding duplicate id fields, i.e.:

    .. code-block:: bash

        bin/cake bake migration CreateProducts id:uuid:primary name:string description:text created modified

Additionally, since Migrations 1.3, a new way to deal with primary key was
introduced. To do so, your migration class should extend the new
``Migrations\AbstractMigration`` class.
You can specify a ``autoId`` property in the Migration class and set it to
``false``, which will turn off the automatic ``id`` column creation. You will
need to manually create the column that will be used as a primary key and add
it to the table declaration::

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

Compared to the previous way of dealing with primary key, this method gives you
the ability to have more control over the primary key column definition:
unsigned or not, limit, comment, etc.

All baked migrations and snapshot will use this new way when necessary.

.. warning::

    Dealing with primary key can only be done on table creation operations.
    This is due to limitations for some database servers the plugin supports.

Collations
----------

If you need to create a table with a different collation than the database
default one, you can define it with the ``table()`` method, as an option::

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

Note however this can only be done on table creation : there is currently
no way of adding a column to an existing table with a different collation than
the table or the database.
Only ``MySQL`` and ``SqlServer`` supports this configuration key for the time
being.

Updating columns name and using Table objects
---------------------------------------------

If you use a CakePHP ORM Table object to manipulate values from your database
along with renaming or removing a column, make sure you create a new instance of
your Table object after the ``update()`` call. The Table object registry is
cleared after an ``update()`` call in order to refresh the schema that is
reflected and stored in the Table object upon instantiation.

Migrations and Deployment
-------------------------

If you use the plugin when deploying your application, be sure to clear the ORM
cache so it renews the column metadata of your tables.  Otherwise, you might end
up having errors about columns not existing when performing operations on those
new columns.  The CakePHP Core includes a `Schema Cache Shell
<https://book.cakephp.org/3.0/en/console-and-shells/schema-cache.html>`__ that
you can use to perform this operation:

.. code-block:: bash

    // Prior to 3.6 use orm_cache
    bin/cake schema_cache clear

Renaming a table
----------------

The plugin gives you the ability to rename a table, using the ``rename()``
method. In your migration file, you can do the following::

    public function up()
    {
        $this->table('old_table_name')
            ->rename('new_table_name')
            ->update();
    }

    public function down()
    {
        $this->table('new_table_name')
            ->rename('old_table_name')
            ->update();
    }


Skipping the ``schema.lock`` file generation
--------------------------------------------

.. versionadded:: cakephp/migrations 1.6.5

In order for the diff feature to work, a **.lock** file is generated everytime
you migrate, rollback or bake a snapshot, to keep track of the state of your
database schema at any given point in time. You can skip this file generation,
for instance when deploying on your production environment, by using the
``--no-lock`` option for the aforementioned command:

.. code-block:: bash

    bin/cake migrations migrate --no-lock

    bin/cake migrations rollback --no-lock

    bin/cake bake migration_snapshot MyMigration --no-lock

IDE autocomplete support
------------------------

The `IdeHelper plugin
<https://github.com/dereuromark/cakephp-ide-helper>`__ can help
you to get more IDE support for the tables, their column names and possible column types.
Specifically PHPStorm understands the meta information and can help you autocomplete those.
