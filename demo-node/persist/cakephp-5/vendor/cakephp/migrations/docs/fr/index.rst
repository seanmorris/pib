Migrations
##########

Migrations est un plugin supporté par la core team pour vous aider à gérer les
changements dans la base de données en écrivant des fichiers PHP qui peuvent
être versionnés par votre système de gestion de version.

Il vous permet de faire évoluer vos tables au fil du temps.
Au lieu d'écrire vos modifications de schéma en SQL, ce plugin vous permet
d'utiliser un ensemble intuitif de méthodes qui facilite la mise en œuvre des
modifications au sein de la base de données.

Ce plugin est un wrapper pour la librairie de gestion des migrations de bases de
données `Phinx <https://phinx.org/>`_.

Installation
============

Par défaut Migrations est installé avec le squelette d’application. Si vous le
retirez et voulez le réinstaller, vous pouvez le faire en lançant ce qui suit à
partir du répertoire ROOT de votre application (où le fichier composer.json est
localisé):

.. code-block:: bash

    php composer.phar require cakephp/migrations "@stable"

    # Ou si composer est installé globalement

    composer require cakephp/migrations "@stable"

Pour utiliser le plugin, vous devrez le charger dans le fichier
**config/bootstrap.php** de votre application.
Vous pouvez utiliser `le shell de Plugin de CakePHP
<https://book.cakephp.org/3.0/fr/console-and-shells/plugin-shell.html>`__ pour
charger et décharger les plugins de votre **config/bootstrap.php**:

.. code-block:: bash

    bin/cake plugin load Migrations

Ou vous pouvez charger le plugin en modifiant votre fichier
**config/bootstrap.php**, en ajoutant ce qui suit::

    Plugin::load('Migrations');

De plus, vous devrez configurer la base de données par défaut pour votre
application dans le fichier **config/app.php** comme expliqué dans la section
sur la `configuration des bases de données
<https://book.cakephp.org/3.0/fr/orm/database-basics.html#database-configuration>`__.

Vue d'ensemble
==============

Une migration est simplement un fichier PHP qui décrit les changements à
effectuer sur la base de données. Un fichier de migration peut créer ou
supprimer des tables, ajouter ou supprimer des colonnes, créer des index et même
insérer des données dans votre base de données.

Ci-dessous un exemple de migration::

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

Cette migration va ajouter une table à votre base de données nommée ``products``
avec les définitions de colonne suivantes:

- ``id`` colonne de type ``integer`` comme clé primaire
- ``name`` colonne de type ``string``
- ``description`` colonne de type ``text``
- ``created`` colonne de type ``datetime``

.. tip::

    La colonne avec clé primaire nommée ``id`` sera ajoutée **implicitement**.

.. note::

    Notez que ce fichier décrit ce à quoi la base de données devrait ressembler
    **après** l'application de la migration. À ce stade la table ``products``
    n'existe pas dans votre base de données, nous avons simplement créé un
    fichier qui est à la fois capable de créer la table ``products`` avec les
    bonnes colonnes mais aussi de supprimer la table quand une opération de
    ``rollback`` (retour en arrière) de la migration est effectuée.

Une fois que le fichier a été créé dans le dossier **config/Migrations**, vous
pourrez exécuter la commande ``migrations`` suivante pour créer la table dans
votre base de données:

.. code-block:: bash

    bin/cake migrations migrate

La commande ``migrations`` suivante va effectuer un ``rollback`` (retour en
arrière) et supprimer la table de votre base de données:

.. code-block:: bash

    bin/cake migrations rollback

Création de Migrations
======================

Les fichiers de migrations sont stockés dans le répertoire **config/Migrations**
de votre application. Le nom des fichiers de migration est précédé de la
date/heure du jour de création, dans le format
**YYYYMMDDHHMMSS_MigrationName.php**.
Voici quelques exemples de noms de fichiers de migration:

* 20160121163850_CreateProducts.php
* 20160210133047_AddRatingToProducts.php

La meilleure façon de créer un fichier de migration est d'utiliser la ligne de
commande ``bin/cake bake migration``.

Assurez-vous de bien lire la `documentation officielle de Phinx <https://book.cakephp.org/phinx/0/en/migrations.html>`_ afin de connaître la liste
complète des méthodes que vous pouvez utiliser dans l'écriture des fichiers de
migration.

.. note::

    Quand vous utilisez l'option ``bake``, vous pouvez toujours modifier la
    migration avant de l'exécuter si besoin.

Syntaxe
-------

La syntaxe de la commande ``bake`` est de la forme suivante:

.. code-block:: bash

    bin/cake bake migration CreateProducts name:string description:text created modified

Quand vous utilisez ``bake`` pour créer des tables, ajouter des colonnes ou
effectuer diverses opérations sur votre base de données, vous devez en général
fournir deux choses:

* le nom de la migration que vous allez générer (``CreateProducts`` dans notre
  exemple)
* les colonnes de la table qui seront ajoutées ou retirées dans la migration
  (``name:string description:text created modified`` dans notre exemple)

Étant données les conventions, tous les changements de schéma ne peuvent pas
être effectuées avec les commandes shell.

De plus, vous pouvez créer un fichier de migration vide si vous voulez un
contrôle total sur ce qui doit être executé, en ne spécifiant pas de définition
de colonnes:

.. code-block:: bash

    bin/cake migrations create MyCustomMigration

Nom de Fichier des Migrations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Les noms des migrations peuvent suivre l'une des structures suivantes:

* (``/^(Create)(.*)/``) Crée la table spécifiée.
* (``/^(Drop)(.*)/``) Supprime la table spécifiée. Ignore les arguments de champ spécifié.
* (``/^(Add).*(?:To)(.*)/``) Ajoute les champs à la table spécifiée.
* (``/^(Remove).*(?:From)(.*)/``) Supprime les champs de la table spécifiée.
* (``/^(Alter)(.*)/``) Modifie la table spécifiée. Un alias pour CreateTable et AddField.
* (``/^(Alter).*(?:On)(.*)/``) Modifie les champs de la table spécifiée.

Vous pouvez aussi utiliser ``la_forme_avec_underscores`` comme nom pour vos
migrations par exemple ``create_products``.

.. versionadded:: cakephp/migrations 1.5.2

    Depuis la version 1.5.2 du `plugin migrations <https://github.com/cakephp/migrations/>`_,
    le nom de fichier de migration sera automatiquement avec des majuscules.
    Cette version du plugin est seulement disponible pour une version de
    CakePHP >= to 3.1. Avant cette version du plugin, le nom des migrations
    serait sous la forme avec des underscores, par exemple
    ``20160121164955_create_products.php``.

.. warning::

    Les noms des migrations sont utilisés comme noms de classe de migration, et
    peuvent donc être en conflit avec d'autres migrations si les noms de classe
    ne sont pas uniques. Dans ce cas, il peut être nécessaire de remplacer
    manuellement le nom plus tard, ou simplement changer le nom
    que vous avez spécifié.

Définition de Colonnes
~~~~~~~~~~~~~~~~~~~~~~

Quand vous définissez des colonnes avec la ligne de commande, il peut être
pratique de se souvenir qu'elles suivent le modèle suivant::

    fieldName:fieldType?[length]:indexType:indexName

Par exemple, les façons suivantes sont toutes des façons valides pour spécifier
un champ d'email:

* ``email:string?``
* ``email:string:unique``
* ``email:string?[50]``
* ``email:string:unique:EMAIL_INDEX``
* ``email:string[120]:unique:EMAIL_INDEX``

Le point d'interrogation qui suit le type du champ entrainera que la colonne
peut être null.

Le paramètre ``length`` pour ``fieldType`` est optionnel et doit toujours être
écrit entre crochets.

Les champs nommés ``created`` et ``modified``, tout comme les champs ayant pour
suffixe ``_at``, vont automatiquement être définis avec le type ``datetime``.

Les types de champ sont ceux qui sont disponibles avec la librairie ``Phinx``.
Ce sont les suivants:

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

Il existe quelques heuristiques pour choisir les types de champ quand ils ne
sont pas spécifiés ou définis avec une valeur invalide. Par défaut, le type est
``string``:

* id: integer
* created, modified, updated: datetime

Créer une Table
---------------

Vous pouvez utiliser ``bake`` pour créer une table:

.. code-block:: bash

    bin/cake bake migration CreateProducts name:string description:text created modified

La ligne de commande ci-dessus va générer un fichier de migration qui ressemble
à::

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

Ajouter des Colonnes à une Table Existante
------------------------------------------

Si le nom de la migration dans la ligne de commande est de la forme
"AddXXXToYYY" et est suivie d'une liste de noms de colonnes et de types alors
un fichier de migration contenant le code pour la création des colonnes sera
généré:

.. code-block:: bash

    bin/cake bake migration AddPriceToProducts price:decimal

L'exécution de la ligne de commande ci-dessus va générer::

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

Ajouter un Index de Colonne à une Table
---------------------------------------

Il est également possible d'ajouter des indexes de colonnes:

.. code-block:: bash

    bin/cake bake migration AddNameIndexToProducts name:string:index

va générer::

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

Spécifier la Longueur d'un Champ
--------------------------------

.. versionadded:: cakephp/migrations 1.4

Si vous voulez spécifier une longueur de champ, vous pouvez le faire entre
crochets dans le type du champ, par exemple:

.. code-block:: bash

    bin/cake bake migration AddFullDescriptionToProducts full_description:string[60]

L'exécution de la ligne de commande ci-dessus va générer::

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

Si aucune longueur n'est spécifiée, les longueurs pour certain types de
colonnes sont par défaut:

* string: 255
* integer: 11
* biginteger: 20

Modifier une colonne d'une table
-----------------------------------

De la même manière, vous pouvez générer une migration pour modifier une colonne à l'aide de la commande
ligne de commande, si le nom de la migration est de la forme "AlterXXXOnYYY":

.. code-block:: bash

    bin/cake bake migration AlterPriceOnProducts name:float

créé le fichier::

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

Retirer une Colonne d'une Table
-------------------------------

De la même façon, vous pouvez générer une migration pour retirer une colonne
en utilisant la ligne de commande, si le nom de la migration est de la forme
"RemoveXXXFromYYY":

.. code-block:: bash

    bin/cake bake migration RemovePriceFromProducts price

créé le fichier::

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

    La commande `removeColumn` n'est pas réversible, donc elle doit être appelée
    dans la méthode `up`. Un appel correspondant au `addColumn` doit être
    ajouté à la méthode `down`.

Générer une Migration à partir d'une Base de Données Existante
==============================================================

Si vous avez affaire à une base de données pré-existante et que vous voulez
commencer à utiliser migrations, ou que vous souhaitez versionner le schéma
initial de votre base de données, vous pouvez exécuter la commande
``migration_snapshot``:

.. code-block:: bash

    bin/cake bake migration_snapshot Initial

Elle va générer un fichier de migration appelé **Initial** contenant toutes les
déclarations pour toutes les tables de votre base de données.

Par défaut, le snapshot va être créé en se connectant à la base de données
définie dans la configuration de la connection ``default``.
Si vous devez créer un snapshot à partir d'une autre source de données, vous
pouvez utiliser l'option ``--connection``:

.. code-block:: bash

    bin/cake bake migration_snapshot Initial --connection my_other_connection

Vous pouvez aussi vous assurer que le snapshot inclut seulement les tables pour
lesquelles vous avez défini les classes de model correspondantes en utilisant
le flag ``--require-table``:

.. code-block:: bash

    bin/cake bake migration_snapshot Initial --require-table

Quand vous utilisez le flag ``--require-table``, le shell va chercher les
classes ``Table`` de votre application et va seulement ajouter les tables de
model dans le snapshot.

La même logique sera appliquée implicitement si vous souhaitez créer un
snapshot pour un plugin. Pour ce faire, vous devez utiliser l'option
``--plugin``:

.. code-block:: bash

    bin/cake bake migration_snapshot Initial --plugin MyPlugin

Seules les tables ayant une classe d'un objet model ``Table`` définie seront
ajoutées au snapshot de votre plugin.

.. note::

    Quand vous créez un snapshot pour un plugin, les fichiers de migration sont
    créés dans le répertoire **config/Migrations** de votre plugin.

Notez que quand vous créez un snapshot, il est automatiquement marqué dans la
table de log de phinx comme migré.

Générer un diff entre deux états de base de données
===================================================

.. versionadded:: cakephp/migrations 1.6.0

Vous pouvez générer un fichier de migrations qui regroupera toutes les
différences entre deux états de base de données en utilisant le template bake
``migration_diff``. Pour cela, vous pouvez utiliser la commande suivante:

.. code-block:: bash

    bin/cake bake migration_diff NameOfTheMigrations

Pour avoir un point de comparaison avec l'état actuel de votre base de données,
le shell migrations va générer, après chaque appel de ``migrate`` ou
``rollback`` un fichier "dump". Ce fichier dump est un fichier qui contient
l'ensemble de l'état de votre base de données à un point précis dans le temps.

Quand un fichier dump a été généré, toutes les modifications que vous ferez
directement dans votre SGBD seront ajoutées au fichier de migration qui sera
généré quand vous appelerez la commande ``bake migration_diff``.

Par défaut, le diff sera fait en se connectant à la base de données définie
dans votre configuration de Connection ``default``.
Si vous avez besoin de faire un diff depuis une source différente, vous pouvez
utiliser l'option ``--connection``:

.. code-block:: bash

    bin/cake bake migration_diff NameOfTheMigrations --connection my_other_connection

Si vous souhaitez utiliser la fonctionnalité de diff sur une application qui
possède déjà un historique de migrations, vous allez avoir besoin de créer le
fichier dump manuellement pour qu'il puisse être utilisé comme point de
comparaison:

.. code-block:: bash

    bin/cake migrations dump

L'état de votre base de données devra être le même que si vous aviez migré tous
vos fichiers de migrations avant de créer le fichier dump.
Une fois que le fichier dump est créé, vous pouvez opérer des changements dans
votre base de données et utiliser la commande ``bake migration_diff`` quand
vous voulez

.. note::

    Veuillez noter que le système n'est pas capable de détecter les colonnes
    renommées.

Les Commandes
=============

``migrate`` : Appliquer les Migrations
--------------------------------------

Une fois que vous avez généré ou écrit votre fichier de migration, vous devez
exécuter la commande suivante pour appliquer les modifications à votre base de
données:

.. code-block:: bash

    # Exécuter toutes les migrations
    bin/cake migrations migrate

    # Pour migrer vers une version spécifique, utilisez
    # le paramètre ``--target`` ou -t (version courte)
    # Cela correspond à l'horodatage qui est ajouté au début
    # du nom de fichier des migrations.
    bin/cake migrations migrate -t 20150103081132

    # Par défaut, les fichiers de migration se trouvent dans
    # le répertoire **config/Migrations**. Vous pouvez spécifier le répertoire
    # en utilisant l'option ``--source`` ou ``-s`` (version courte).
    # L'exemple suivant va exécuter les migrations
    # du répertoire **config/Alternate**
    bin/cake migrations migrate -s Alternate

    # Vous pouvez exécuter les migrations avec une connection différente
    # de celle par défaut ``default`` en utilisant l'option ``--connection``
    # ou ``-c`` (version courte)
    bin/cake migrations migrate -c my_custom_connection

    # Les migrations peuvent aussi être exécutées pour les plugins. Utilisez
    # simplement l'option ``--plugin`` ou ``-p`` (version courte)
    bin/cake migrations migrate -p MyAwesomePlugin

``rollback`` : Annuler les Migrations
-------------------------------------

La commande de restauration est utilisée pour annuler les précédentes migrations
réalisées par ce plugin. C'est l'inverse de la commande ``migrate``.:

.. code-block:: bash

    # Vous pouvez annuler la migration précédente en utilisant
    # la commande ``rollback``::
    bin/cake migrations rollback

    # Vous pouvez également passer un numéro de version de migration
    # pour revenir à une version spécifique::
    bin/cake migrations rollback -t 20150103081132

Vous pouvez aussi utilisez les options ``--source``, ``--connection`` et
``--plugin`` comme pour la commande ``migrate``.

``status`` : Statuts de Migrations
----------------------------------

La commande ``status`` affiche une liste de toutes les migrations, ainsi que
leur état actuel. Vous pouvez utiliser cette commande pour déterminer les
migrations qui ont été exécutées:

.. code-block:: bash

    bin/cake migrations status

Vous pouvez aussi afficher les résultats avec le format JSON en utilisant
l'option ``--format`` (ou ``-f`` en raccourci):

.. code-block:: bash

    bin/cake migrations status --format json

Vous pouvez aussi utiliser les options ``--source``, ``--connection`` et
``--plugin`` comme pour la commande ``migrate``.

``mark_migrated`` : Marquer une Migration en Migrée
---------------------------------------------------

.. versionadded:: 1.4.0

Il peut parfois être utile de marquer une série de migrations comme "migrées"
sans avoir à les exécuter.
Pour ce faire, vous pouvez utiliser la commande ``mark_migrated``.
Cette commande fonctionne de la même manière que les autres commandes.

Vous pouvez marquer toutes les migrations comme migrées en utilisant cette
commande:

.. code-block:: bash

    bin/cake migrations mark_migrated

Vous pouvez également marquer toutes les migrations jusqu'à une version
spécifique en utilisant l'option ``--target``:

.. code-block:: bash

    bin/cake migrations mark_migrated --target=20151016204000

Si vous ne souhaitez pas que la migration "cible" soit marquée, vous pouvez
utiliser le _flag_ ``--exclude``:

.. code-block:: bash

    bin/cake migrations mark_migrated --target=20151016204000 --exclude

Enfin, si vous souhaitez marquer seulement une migration, vous pouvez utiliser
le _flag_ ``--only``:

.. code-block:: bash

    bin/cake migrations mark_migrated --target=20151016204000 --only

Vous pouvez aussi utilisez les options ``--source``, ``--connection`` et
``--plugin`` comme pour la commande ``migrate``.

.. note::

    Lorsque vous créez un snapshot avec la commande
    ``cake bake migration_snapshot``, la migration créée sera automatiquement
    marquée comme "migrée".

.. deprecated:: 1.4.0

    Les instructions suivantes ont été dépréciées. Utilisez les seulement si
    vous utilisez une version du plugin inférieure à 1.4.0.

La commande attend le numéro de version de la migration comme argument:

.. code-block:: bash

    bin/cake migrations mark_migrated 20150420082532

Si vous souhaitez marquer toutes les migrations comme "migrées", vous pouvez
utiliser la valeur spéciale ``all``. Si vous l'utilisez, toutes les migrations
trouvées seront marquées comme "migrées":

.. code-block:: bash

    bin/cake migrations mark_migrated all

``seed`` : Remplir votre Base de Données (Seed)
-----------------------------------------------

Depuis la version 1.5.5, vous pouvez utiliser le shell ``migrations`` pour
remplir votre base de données. Cela vient de la `fonctionnalité de seed
de la librairie Phinx <https://book.cakephp.org/phinx/0/en/seeding.html>`_.
Par défaut, les fichiers de seed vont être recherchés dans le répertoire
``config/Seeds`` de votre application. Assurez-vous de suivre les
`instructions de Phinx pour construire les fichiers de seed <https://book.cakephp.org/phinx/0/en/seeding.html#creating-a-new-seed-class>`_.

En ce qui concerne migrations, une interface ``bake`` est fournie pour les
fichiers de seed:

.. code-block:: bash

    # Ceci va créer un fichier ArticlesSeed.php dans le répertoire config/Seeds
    # de votre application
    # Par défaut, la table que le seed va essayer de modifier est la version
    #  "tableized" du nom de fichier du seed
    bin/cake bake seed Articles

    # Vous spécifiez le nom de la table que les fichiers de seed vont modifier
    # en utilisant l'option ``--table``
    bin/cake bake seed Articles --table my_articles_table

    # Vous pouvez spécifier un plugin dans lequel faire la création
    bin/cake bake seed Articles --plugin PluginName

    # Vous pouvez spécifier une connection alternative quand vous générez un
    # seeder.
    bin/cake bake seed Articles --connection connection

.. versionadded:: cakephp/migrations 1.6.4

    Les options ``--data``, ``--limit`` and ``--fields`` ont été ajoutées pour
    permettre d'exporter des données extraites depuis votre base de données.

A partir de 1.6.4, la commande ``bake seed`` vous permet de créer des fichiers
de seed avec des lignes exportées de votre base de données en utilisant
l'option ``--data``:

.. code-block:: bash

    bin/cake bake seed --data Articles

Par défaut, cela exportera toutes les lignes trouvées dans la table. Vous
pouvez limiter le nombre de lignes exportées avec l'option ``--limit``:

.. code-block:: bash

    # N'exportera que les 10 premières lignes trouvées
    bin/cake bake seed --data --limit 10 Articles

Si vous ne souhaitez inclure qu'une sélection des champs de la table dans votre
fichier de seed, vous pouvez utiliser l'option ``--fields``. Elle prend la
liste des champs séparés par une virgule comme argument:

.. code-block:: bash

    # N'exportera que les champs `id`, `title` et `excerpt`
    bin/cake bake seed --data --fields id,title,excerpt Articles

.. tip::

    Vous pouvez bien sûr utiliser les options ``--limit`` et ``--fields``
    ensemble dans le même appel.

Pour faire un seed de votre base de données, vous pouvez utiliser la
sous-commande ``seed``:

.. code-block:: bash

    # Sans paramètres, la sous-commande seed va exécuter tous les seeders
    # disponibles du répertoire cible, dans l'ordre alphabétique.
    bin/cake migrations seed

    # Vous pouvez spécifier seulement un seeder à exécuter en utilisant
    # l'option `--seed`
    bin/cake migrations seed --seed ArticlesSeed

    # Vous pouvez exécuter les seeders d'un autre répertoire
    bin/cake migrations seed --source AlternativeSeeds

    # Vous pouvez exécuter les seeders d'un plugin
    bin/cake migrations seed --plugin PluginName

    # Vous pouvez exécuter les seeders d'une connection spécifique
    bin/cake migrations seed --connection connection

Notez que, à l'opposé des migrations, les seeders ne sont pas suivies, ce qui
signifie que le même seeder peut être appliqué plusieurs fois.

Appeler un Seeder depuis un autre Seeder
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. versionadded:: cakephp/migrations 1.6.2

Généralement, quand vous remplissez votre base de données avec des *seeders*,
l'ordre dans lequel vous faites les insertions est important pour éviter de
rencontrer des erreurs dûes à des *constraints violations*.
Puisque les *seeders* sont exécutés dans l'ordre alphabétique par défaut, vous
pouvez utiliser la méthode ``\Migrations\AbstractSeed::call()`` pour définir
votre propre séquence d'exécution de *seeders*::

    use Migrations\AbstractSeed;

    class DatabaseSeed extends AbstractSeed
    {
        public function run(): void
        {
            $this->call('AnotherSeed');
            $this->call('YetAnotherSeed');

            // Vous pouvez utiliser la syntaxe "plugin" pour appeler un seeder
            // d'un autre plugin
            $this->call('PluginName.FromPluginSeed');
        }
    }

.. note::

    Assurez vous d'*extend* la classe du plugin Migrations ``AbstractSeed`` si
    vous voulez pouvoir utiliser la méthode ``call()``. Cette classe a été
    ajoutée dans la version 1.6.2.

``dump`` : Générer un fichier dump pour la fonctionnalité de diff
-----------------------------------------------------------------

La commande Dump crée un fichier qui sera utilisé avec le template bake
``migration_diff``:

.. code-block:: bash

    bin/cake migrations dump

Chaque fichier dump généré est spécifique à la _Connection_ par laquelle il a
été générée (le nom du fichier est suffixé par ce nom). Cela permet à la
commande ``bake migration_diff`` de calculer le diff correctement dans le cas
où votre application gérerait plusieurs bases de données (qui pourraient être
basées sur plusieurs SGDB.

Les fichiers de dump sont créés dans le même dossier que vos fichiers de
migrations.

Vous pouvez aussi utiliser les options ``--source``, ``--connection`` et
``--plugin`` comme pour la commande ``migrate``.


Utiliser Migrations dans les Tests
==================================

Si votre application fait usage des migrations, vous pouvez ré-utiliser
celles-ci afin de maintenir le schéma de votre base de données de test. Dans
le fichier ``tests/bootstrap.php``, vous pouvez utiliser la
classe ``Migrator`` pour construire le schéma avant que vos tests ne soient lancés.
La classe ``Migrator`` réutilisera le schéma existant si il correspond à vos migrations.
Si vos migrations ont évolué depuis le dernier lancement de vos tests, toutes les
tables des connections de test concernées seront effacées et les migrations seront relancées
afin d'actualiser le schéma::

    // dans tests/bootstrap.php
    use Migrations\TestSuite\Migrator;

    $migrator = new Migrator();

    // Simple setup sans plugins
    $migrator->run();

    // Setup sur une base de données autre que 'test'
    $migrator->run(['connection' => 'test_other']);

    // Setup pour un plugin
    $migrator->run(['plugin' => 'Contacts']);

    // Lancer les migrations du plugin Documents sur la connection test_docs.
    $migrator->run(['plugin' => 'Documents', 'connection' => 'test_docs']);


Si vos migrations se trouvent à différents endroits, celles-ci doivent être executées ainsi::

    // Migrations du plugin Contacts sur la connection ``test``, et du plugin Documents sur la connection ``test_docs``
    $migrator->runMany([
        ['plugin' => 'Contacts'],
        ['plugin' => 'Documents', 'connection' => 'test_docs']
    ]);

Les informations relatives au status des migrations de test sont rapportées dans les logs de l'application.

.. versionadded: 3.2.0
    Migrator was added to complement the new fixtures in CakePHP 4.3.0.

Utiliser Migrations dans les Plugins
====================================

Les plugins peuvent également contenir des fichiers de migration. Cela rend les
plugins destinés à la communauté beaucoup plus portable et plus facile à
installer. Toutes les commandes du plugin Migrations supportent l'option
``--plugin`` ou ``-p`` afin d'exécuter les commandes par rapport à ce plugin:

.. code-block:: bash

    bin/cake migrations status -p PluginName

    bin/cake migrations migrate -p PluginName

Effectuer des Migrations en dehors d'un environnement Console
=============================================================

.. versionadded:: cakephp/migrations 1.2.0

Depuis la sortie de la version 1.2 du plugin migrations, vous pouvez effectuer
des migrations en dehors d'un environnement Console, directement depuis une
application, en utilisant la nouvelle classe ``Migrations``.
Cela peut être pratique si vous développez un installeur de plugins pour un CMS
par exemple.
La classe ``Migrations`` vous permet de lancer les commandes de la console de
migrations suivantes:

* migrate
* rollback
* markMigrated
* status
* seed

Chacune de ces commandes possède une méthode définie dans la classe
``Migrations``.

Voici comment l'utiliser::

    use Migrations\Migrations;

    $migrations = new Migrations();

    // Va retourner un tableau des migrations et leur statut
    $status = $migrations->status();

    // Va retourner true en cas de succès. Si une erreur se produit, une exception est lancée
    $migrate = $migrations->migrate();

    // Va retourner true en cas de succès. Si une erreur se produit, une exception est lancée
    $rollback = $migrations->rollback();

    // Va retourner true en cas de succès. Si une erreur se produit, une exception est lancée
    $markMigrated = $migrations->markMigrated(20150804222900);

    // Va retourner true en cas de succès. Su une erreur se produit, une exception est lancée
    $seeded = $migrations->seed();

Ces méthodes acceptent un tableau de paramètres qui doivent correspondre aux
options de chacune des commandes::

    use Migrations\Migrations;

    $migrations = new Migrations();

    // Va retourner un tableau des migrations et leur statut
    $status = $migrations->status(['connection' => 'custom', 'source' => 'MyMigrationsFolder']);

Vous pouvez passer n'importe quelle option que la commande de la console
accepterait.
La seule exception étant la commande ``markMigrated`` qui attend le numéro de
version de la migration à marquer comme "migrée" comme premier argument.
Passez le tableau de paramètres en second argument pour cette méthode.

En option, vous pouvez passer ces paramètres au constructeur de la classe.
Ils seront utilisés comme paramètres par défaut et vous éviteront ainsi d'avoir
à les passer à chaque appel de méthode::

    use Migrations\Migrations;

    $migrations = new Migrations(['connection' => 'custom', 'source' => 'MyMigrationsFolder']);

    // Tous les appels suivant seront faits avec les paramètres passés au constructeur de la classe Migrations
    $status = $migrations->status();
    $migrate = $migrations->migrate();

Si vous avez besoin d'écraser un ou plusieurs paramètres pour un appel, vous
pouvez les passer à la méthode::

    use Migrations\Migrations;

    $migrations = new Migrations(['connection' => 'custom', 'source' => 'MyMigrationsFolder']);

    // Cet appel sera fait avec la connexion "custom"
    $status = $migrations->status();
    // Cet appel avec la connexion "default"
    $migrate = $migrations->migrate(['connection' => 'default']);

Trucs et Astuces
================

Créer des Clés Primaires Personnalisées
---------------------------------------

Pour personnaliser la création automatique de la clé primaire ``id`` lors
de l'ajout de nouvelles tables, vous pouvez utiliser le deuxième argument de la
méthode ``table()``::

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

Le code ci-dessus va créer une colonne ``CHAR(36)`` ``id`` également utilisée
comme clé primaire.

.. note::

    Quand vous spécifiez une clé primaire personnalisée avec les lignes de
    commande, vous devez la noter comme clé primaire dans le champ id,
    sinon vous obtiendrez une erreur de champs id dupliqués, par exemple:

    .. code-block:: bash

        bin/cake bake migration CreateProducts id:uuid:primary name:string description:text created modified

Depuis Migrations 1.3, une nouvelle manière de gérer les clés primaires a été
introduite. Pour l'utiliser, votre classe de migration devra étendre la
nouvelle classe ``Migrations\AbstractMigration``.
Vous pouvez définir la propriété ``autoId`` à ``false`` dans la classe de
Migration, ce qui désactivera la création automatique de la colonne ``id``.
Vous aurez cependant besoin de manuellement créer la colonne qui servira de clé
primaire et devrez l'ajouter à la déclaration de la table::

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

Comparée à la méthode précédente de gestion des clés primaires, cette méthode
vous donne un plus grand contrôle sur la définition de la colonne de la clé
primaire : signée ou non, limite, commentaire, etc.

Toutes les migrations et les snapshots créés avec ``bake`` utiliseront cette
nouvelle méthode si nécessaire.

.. warning::

    Gérer les clés primaires ne peut être fait que lors des opérations de
    créations de tables. Ceci est dû à des limitations pour certains serveurs
    de base de données supportés par le plugin.

Collations
----------

Si vous avez besoin de créer une table avec une ``collation`` différente
de celle par défaut de la base de données, vous pouvez la définir comme option
de la méthode ``table()``::

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

Notez cependant que ceci ne peut être fait qu'en cas de création de table :
il n'y a actuellement aucun moyen d'ajouter une colonne avec une ``collation``
différente de celle de la table ou de la base de données.
Seuls ``MySQL`` et ``SqlServer`` supportent cette option de configuration pour
le moment.

Mettre à jour les Noms de Colonne et Utiliser les Objets Table
--------------------------------------------------------------

Si vous utilisez un objet Table de l'ORM de CakePHP pour manipuler des valeurs
de votre base de données, comme renommer ou retirer une colonne, assurez-vous
de créer une nouvelle instance de votre objet Table après l'appel à
``update()``. Le registre de l'objet Table est nettoyé après un appel à
``update()`` afin de rafraîchir le schéma qui est reflèté et stocké dans l'objet
Table lors de l'instanciation.

Migrations et déploiement
-------------------------
Si vous utilisez le plugin dans vos processus de déploiement, assurez-vous de
vider le cache de l'ORM pour qu'il renouvelle les _metadata_ des colonnes de vos
tables.
Autrement, vous pourrez rencontrer des erreurs de colonnes inexistantes quand
vous effectuerez des opérations sur vos nouvelles colonnes.
Le Core de CakePHP inclut un `Shell de Cache du Schéma
<https://book.cakephp.org/3.0/fr/console-and-shells/schema-cache.html>`__ que vous pouvez
utilisez pour vider le cache:

.. code-block:: bash

    // Avant 3.6, utilisez orm_cache
    bin/cake schema_cache clear

Veuillez vous référer à la section du cookbook à propos du `Shell du Cache du Schéma
<https://book.cakephp.org/3.0/fr/console-and-shells/schema-cache.html>`__ si vous voulez
plus de détails à propos de ce shell.

Renommer une table
------------------

Le plugin vous donne la possibilité de renommer une table en utilisant la
méthode ``rename()``.
Dans votre fichier de migration, vous pouvez utiliser la syntaxe suivante::

    public function up()
    {
        $this->table('old_table_name')
            ->rename('new_table_name');
    }

Ne pas générer le fichier ``schema.lock``
-----------------------------------------

.. versionadded:: cakephp/migrations 1.6.5

Pour que la fonctionnalité de "diff" fonctionne, un fichier **.lock** est
généré à chaque que vous faites un migrate, un rollback ou que vous générez un
snapshot via bake pour permettre de suivre l'état de votre base de données à
n'importe quel moment. Vous pouvez empêcher que ce fichier ne soit généré,
comme par exemple lors d'un déploiement sur votre environnement de production,
en utilisant l'option ``--no-lock`` sur les commandes mentionnées ci-dessus:

.. code-block:: bash

    bin/cake migrations migrate --no-lock

    bin/cake migrations rollback --no-lock

    bin/cake bake migration_snapshot MyMigration --no-lock
