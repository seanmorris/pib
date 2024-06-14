Etendre Bake
############

Bake dispose d'une architecture extensible qui permet à votre application ou
à vos plugins de modifier ou ajouter la fonctionnalité de base. Bake utilise une
classe de vue dédiée qui utilise le moteur de template
`Twig <https://twig.symfony.com/>`_.

Events de Bake
==============

Comme une classe de vue, ``BakeView`` envoie les mêmes events que toute autre
classe de vue, ainsi qu'un event initialize supplémentaire. Cependant,
alors que les classes de vue standard utilisent le préfixe d'event
"View.", ``BakeView`` utilise le préfixe d'event "Bake.".

L'event initialize peut être utilisé pour faire des changements qui
s'appliquent à toutes les sorties fabriquées avec bake, par exemple pour ajouter
un autre helper à la classe de vue bake, cet event peut être utilisé::

    <?php
    use Cake\Event\EventInterface;
    use Cake\Event\EventManager;

    // dans src/Application::bootstrapCli()

    EventManager::instance()->on('Bake.initialize', function (EventInterface $event) {
        $view = $event->getSubject();

        // Dans mes templates de bake, permet l'utilisation du helper MySpecial
        $view->loadHelper('MySpecial', ['some' => 'config']);

        // Et ajoute une variable $author pour qu'elle soit toujours disponible
        $view->set('author', 'Andy');

    });

Les events de bake peuvent être pratiques pour faire de petits changements dans
les templates existants. Par exemple, pour changer les noms de variables
utilisés lors de la création avec bake de fichiers de controller/template, on
pourra utiliser une fonction qui écoute ``Bake.beforeRender`` pour modifier les
variables utilisées dans les templates de bake::

    <?php
    use Cake\Event\EventInterface;
    use Cake\Event\EventManager;

    // dans src/Application::bootstrapCli()

    EventManager::instance()->on('Bake.beforeRender', function (EventInterface $event) {
        $view = $event->getSubject();

        // Utilise $rows pour la principale variable de données dans les index
        if ($view->get('pluralName')) {
            $view->set('pluralName', 'rows');
        }
        if ($view->get('pluralVar')) {
            $view->set('pluralVar', 'rows');
        }

        // Utilise $theOne pour la principale variable de données dans les view/edit
        if ($view->get('singularName')) {
            $view->set('singularName', 'theOne');
        }
        if ($view->get('singularVar')) {
            $view->set('singularVar', 'theOne');
        }

    });

Vous pouvez aussi scoper les events ``Bake.beforeRender`` et
``Bake.afterRender`` dans un fichier généré spécifique. Par exemple, si vous
souhaitez ajouter des actions spécifiques à votre UsersController quand vous le
générez à partir d'un fichier **Controller/controller.twig**, vous pouvez
utiliser l'event suivant::

    <?php
    use Cake\Event\EventInterface;
    use Cake\Event\EventManager;
    use Cake\Utility\Hash;

    // dans src/Application::bootstrapCli()

    EventManager::instance()->on(
        'Bake.beforeRender.Controller.controller',
        function (EventInterface $event) {
            $view = $event->getSubject();
            if ($view->get('name') === 'Users') {
                // ajouter les actions login et logout au controller Users
                $view->set('actions', [
                    'login',
                    'logout',
                    'index',
                    'view',
                    'add',
                    'edit',
                    'delete'
                ];
            }
        }
    );

En scopant les écouteurs d'event vers des templates de bake spécifiques, vous
pouvez simplifier votre logique d'event liée à bake et fournir des callbacks
qui sont plus faciles à tester.

Syntaxe de Template de Bake
===========================

Les fichiers de template de Bake utilisent la syntaxe de template de
`Twig <https://twig.symfony.com/>`__.

Ainsi, par exemple, pour créer avec bake un shell comme ceci:

.. code-block:: bash

    bin/cake bake command Foo

Le template utilisé
(***vendor/cakephp/bake/templates/bake/Command/command.twig**)
ressemble à ceci::

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
        * Méthode hook pour définir le parseur d'option de cette commande.
        *
        * @see https://book.cakephp.org/4/fr/console-commands/commands.html#defining-arguments-and-options
        * @param \Cake\Console\ConsoleOptionParser $parser Le parseur à définir
        * @return \Cake\Console\ConsoleOptionParser Le parseur construit.
        */
        public function buildOptionParser(ConsoleOptionParser $parser): ConsoleOptionParser
        {
            $parser = parent::buildOptionParser($parser);

            return $parser;
        }

        /**
        * Implémentez cette méthode avec la logique de votre commande.
        *
        * @param \Cake\Console\Arguments $args Les arguments de la commande.
        * @param \Cake\Console\ConsoleIo $io La console il
        * @return int|null|void Le code de sortie ou null pour un succès
        */
        public function execute(Arguments $args, ConsoleIo $io)
        {
        }
    }

Et la classe résultante construite avec bake (**src/Command/FooCommand.php**)
ressemble à ceci::

    <?php
    declare(strict_types=1);

    namespace App\Command;

    use Cake\Command\Command;
    use Cake\Console\Arguments;
    use Cake\Console\ConsoleIo;
    use Cake\Console\ConsoleOptionParser;

    /**
    * Commande Foo.
    */
    class FooCommand extends Command
    {
        /**
        * Méthode hook pour définir le parseur d'option de cette commande.
        *
        * @see https://book.cakephp.org/4/fr/console-commands/commands.html#defining-arguments-and-options
        * @param \Cake\Console\ConsoleOptionParser $parser Le parseur à définir
        * @return \Cake\Console\ConsoleOptionParser Le parseur construit.
        */
        public function buildOptionParser(ConsoleOptionParser $parser): ConsoleOptionParser
        {
            $parser = parent::buildOptionParser($parser);

            return $parser;
        }

        /**
        * Implémentez cette méthode avec la logique de votre commande.
        *
        * @param \Cake\Console\Arguments $args Les arguments de la commande.
        * @param \Cake\Console\ConsoleIo $io La console io
        * @return int|null|void Le code de sortie ou null pour un succès
        */
        public function execute(Arguments $args, ConsoleIo $io)
        {
        }
    }

.. _creating-a-bake-theme:

Créer un thème de Bake
======================

Si vous souhaitez modifier la sortie du HTML produit par la commande "bake",
vous pouvez créer votre propre 'thème' de bake qui vous permet de remplacer
tout ou partie des templates utilisés par bake. Pour créer un thème de bake,
faites ceci:

#. Créez un nouveau plugin avec Bake. Le nom du plugin est le nom du 'theme' de
   Bake. Par exemple ``bin/cake bake plugin bake_perso``.
#. Créez un nouveau répertoire **plugins/BakePerso/templates/bake**.
#. Copiez tout template que vous souhaitez changer depuis
   ***vendor/cakephp/bake/templates/bake** vers les
   fichiers correspondants dans votre plugin.
#. Quand vous lancez bake, utilisez l'option ``--theme BakePerso`` pour spécifier le
   theme de bake que vous souhaitez utiliser. Pour éviter d'avoir à spécifier
   cette option dans chaque appel, vous pouvez aussi définir votre thème
   personnalisé à utiliser comme thème par défaut::

        <?php
        // dans src/Application::bootstrapCli() avant de charger le plugin 'Bake'.
        Configure::write('Bake.theme', 'MonTheme');


Templates Bake d'Application
============================

Si vous n'avez besoin de personnaliser que quelques templates de Bake, ou si
vous devez utiliser des dépendances de l'application dans vos templates, vous
pouvez inclure des surcharges de template dans les templates de votre
application. Ces surcharges fonctionnent de la même manière que les surcharges
d'autres templates de plugin.

#. Créer un nouveau répertoire **/templates/plugin/Bake/**.
#. Copier tout template que vous souhaitez surcharger de
   ***vendor/cakephp/bake/templates/bake/** vers les fichiers correspondants
   dans votre application.

Vous n'avez pas besoin d'utiliser l'option ``--theme`` quand vous utilisez des
templates d'application.

Créer de Nouvelles Options de Commande pour Bake
================================================

Il est possible d'ajouter de nouvelles options de commandes de bake, ou de
surcharger celles fournies par CakePHP en créant des commandes dans votre
application ou dans vos plugins. En étendant ``Bake\Command\BakeCommand``, bake
va trouver votre nouvelle commande et l'inclure comme faisant partie de bake.

À titre d'exemple, nous allons faire une commande qui créé une classe arbitraire
foo. D'abord, créez le fichier de commande **src/Command/Bake/FooCommand.php**.
Nous étendrons la ``SimpleBakeCommand`` pour l'instant puisque notre commande
sera simple. ``SimpleBakeCommand`` est abstraite et nous impose de définir 3
méthodes qui disent à bake comment la commande est appelée, où devront se
trouver les fichiers qu'il va générer, et quel template utiliser. Notre fichier
FooCommand.php devra ressembler à ceci::

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

Une fois que le fichier a été créé, nous devons créer un template que bake peut
utiliser pour la génération de code. Créez
**templates/bake/foo_template.twig**. Dans ce fichier, nous
ajouterons le contenu suivant::

    <?php
    namespace {{ namespace }}\FooPath;

    /**
     * {{ name }} fooOut
     */
    class {{ name }}FooOut
    {
        // Ajouter le code.
    }

Vous devriez maintenant voir votre nouvelle commande dans l'affichage de
``bin/cake bake``. Vous pouvez lancer votre nouvelle tâche en exécutant
``bin/cake bake foo Exemple``.
Cela va générer une nouvelle classe ``ExempleFoo`` dans
**src/FooPath/ExempleFooOut.php** que votre application va
pouvoir utiliser.

Si vous souhaitez que votre appel à ``bake`` crée également un fichier de test
pour la classe ``ExempleFooOut``, vous devrez surcharger la méthode ``bakeTest()``
dans la classe ``FooCommand`` pour y définir le suffixe et le namespace de la
classe de votre nom de commande personnalisée::

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

* Le **suffixe de classe** sera ajouté après le nom passé à ``bake``. Dans le
  cadre de l'exemple ci-dessus, cela créerait un fichier ``ExempleFooTest.php``.
* Le **type de classe** sera le sous-namespace utilisé pour atteindre votre
  fichier (relatif à l'application ou au plugin dans lequel vous faites le
  ``bake``). Dans le cadre de l'exemple ci-dessus, cela créerait le test avec le
  namespace ``App\Test\TestCase\Foo``.

.. meta::
    :title lang=fr: Etendre Bake
    :keywords lang=fr: interface ligne de commande,development,bake view, bake template syntax,erb tags,asp tags,percent tags
