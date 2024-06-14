Estendendo o Bake
#################

O Bake fornece uma arquitetura expansível que permite a sua aplicação ou plugin
modificar ou adicionar funcionalidades às suas funções básicas. Bake faz uso de
uma classe view dedicada que usa a ferramenta de templates `Twig
<https://twig.symfony.com/>`_.

Eventos do Bake
===============

Como uma class view , ``BakeView`` emite o mesmo evento como qualquer outra
classe view, mais uma extra que inicializa eventos. No entanto, onde as classes
view padrão usam o prefixo "View.", ``BakeView`` usa o prefixo "Bake.".

O inicializador de eventos pode ser usado para fazer mudanças  quando aplicado
a todas as saídas do Bake, por exemplo, ao adicionar outro helper à classe bake
view este evento pode ser usado::

    <?php
    // config/bootstrap_cli.php

    use Cake\Event\Event;
    use Cake\Event\EventManager;

    EventManager::instance()->on('Bake.initialize', function (Event $event) {
        $view = $event->getSubject();

        // In my bake templates, allow the use of the MySpecial helper
        $view->loadHelper('MySpecial', ['some' => 'config']);

        // And add an $author variable so it's always available
        $view->set('author', 'Andy');

    });

Se você deseja modificar o bake de outro plugin, é recomendável colocar os
eventos do bake do seu plugin no arquivo **config/bootstrap.php**.

Os eventos do Bake podem ser úteis para fazer pequenas alterações nos modelos
existentes.  Por exemplo, para alterar os nomes das variáveis usados no
controller/template quando executar o bake, pode-se usar uma função esperando
o ``Bake.beforeRender`` para modificar as variáveis usadas no bake templates::

    <?php
    // config/bootstrap_cli.php

    use Cake\Event\Event;
    use Cake\Event\EventManager;

    EventManager::instance()->on('Bake.beforeRender', function (Event $event) {
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

Você também pode abranger os eventos ``Bake.beforeRender``
e ``Bake.afterRender`` para um arquivo  específico. Por exemplo, se você quiser
adicionar ações específicas para seu UsersController ao gerar a partir de um
arquivo **Controller/controller.twig**, você pode usar o seguinte evento::

    <?php
    // config/bootstrap_cli.php

    use Cake\Event\Event;
    use Cake\Event\EventManager;
    use Cake\Utility\Hash;

    EventManager::instance()->on(
        'Bake.beforeRender.Controller.controller',
        function (Event $event) {
            $view = $event->getSubject();
            if ($view->viewVars['name'] == 'Users') {
                // add the login and logout actions to the Users controller
                $view->set('actions', [
                    'login',
                    'logout',
                    'index',
                    'view',
                    'add',
                    'edit',
                    'delete'
                ]);
            }
        }
    );

Ao adicionar eventos que escutam um bake templates específico, você pode
simplesmente relacionar a sua lógica de eventos com o bake e fornecer callbacks
que são facilmente testáveis.

Sintaxe de Templates do Bake
============================

Os arquivos de templates do Bake usam a sintaxe `Twig <https://twig.symfony.com/doc/2.x/>`__.

Então, por exemplo, quando você executar algo como::

.. code-block:: bash

  $ bin/cake bake shell Foo

O template usado (**vendor/cakephp/bake/src/Template/Bake/Shell/shell.twig**)
parece com algo assim::

    <?php
    namespace {{ namespace }}\Shell;

    use Cake\Console\Shell;

    /**
     * {{ name }} shell command.
     */
    class {{ name }}Shell extends Shell
    {
        /**
         * main() method.
         *
         * @return bool|int Success or error code.
         */
        public function main()
        {
        }

    }

E o resultado baked é uma classe (**src/Shell/FooShell.php**) semelhante a::

    <?php
    namespace App\Shell;

    use Cake\Console\Shell;

    /**
     * Foo shell command.
     */
    class FooShell extends Shell
    {
        /**
         * main() method.
         *
         * @return bool|int Success or error code.
         */
        public function main()
        {
        }

    }

.. note::

    Nas versões anteriores a versão 1.5.0 o bake usava um erb-style tags dentro dos arquivos .ctp

    * ``<%`` Um template bake php abre a tag
    * ``%>`` Um template bake php fecha a tag
    * ``<%=`` Um template bake php short-echo tag
    * ``<%-`` Um template bake php abre a tag, retirando qualquer espaço em branco antes da tag
    * ``-%>`` Um template bake php fecha a tag, retirando qualqualquer espaço em branco após a tag

.. _creating-a-bake-theme:

Criando um Tema Bake
=====================

Se você deseja modificar a saída  produzida com o comando bake, você pode criar
o seu próprio  tema para o bake que permitirá você substituir algum ou todos os
tempaltes que o bake usa. O mmelhor jeito de fazer isto é:

#. Bake um novo plugin. O nome do plugin é o 'nome do tema'
#. Crie uma nova pasta em **plugins/[name]/Template/Bake/Template/**.
#. Copie qualquer template que você queira modificar de
   **vendor/cakephp/bake/src/Template/Bake/Template** para a pasta acima e modificá-los conforme sua necessidade.
#. Quando executar o bake use a opção ``--theme`` para especificar qual o tema
   que o bake deve usar. Para evitar problemas com esta opção, em cada chamada,
   você também pode definir o seu template customizado para ser usado como
   o template padrão::

       <?php
       // no config/bootstrap.php ou no config/bootstrap_cli.php
       Configure::write('Bake.theme', 'MyTheme');

Customizando os Templates do Bake
=================================

Se você deseja modificar a saída produzida pelo comando "bake", você pode
criar o seu próprio tema na sua aplicação. Esta forma não usa a opção
``--theme`` na linha de comando quando executar o base. A melhor forma de fazer isto é:

#. Criar um novo diretório **/Template/Bake/**.
#. Copiar qualquer arquivo que você queira sobrescrever de
   **vendor/cakephp/bake/src/Template/Bake/** e modificá-los conforme sua necessidade.

Criando Novos Comandos Bake
===========================

É possivel adicionar novas opções de comandos, ou sobrescrever alguns providos
pelo CakePHP, criando tarefas na sua aplicação ou no seu plugin. Estendendo
``Bake\Shell\Task\BakeTask``, o Bake encontrará a nova tarefa e o incluirá na
sua própria lista de tarefas.

Como um exemplo, nós vamos criar uma tarefa que cria uma classe foo. Primeiro,
crie um arquivo de tarefa **src/Shell/Task/FooTask.php**. Vamos extender de
``SimpleBakeTask`` por agora como nossa nova shell task será simples.
``SimpleBakeTask`` é abstrata e requer apenas três métodos, que contam
ao nosso bake que a tarefa é chamada, onde os arquivos deverão ser gerados,
e qual template usar. Nosso arquivo FooTask.php deve parecer com::

    <?php
    namespace App\Shell\Task;

    use Bake\Shell\Task\SimpleBakeTask;

    class FooTask extends SimpleBakeTask
    {
        public $pathFragment = 'Foo/';

        public function name()
        {
            return 'foo';
        }

        public function fileName($name)
        {
            return $name . 'Foo.php';
        }

        public function template()
        {
            return 'foo';
        }

    }

Uma vez que o arquivo foi criado, nós precisamos criar um template que o bake
possa usar quando gerar o código. Crie **/Template/Bake/foo.twig** e neste
arquivo nós vamos adicionar o seguinte conteúdo::

    <?php
    namespace {{ namespace }}\Foo;

    /**
     * {{ $name }} foo
     */
    class {{ name }}Foo
    {
        // Adicione código.
    }

Você agora pode ver esta nova tarefa na saída de ``bin/cake bake``. Você pode
executar a sua nova tarefa executando ``bin/cake bake foo Example``.  Isto
gerará uma nova classe ``ExampleFoo`` em **src/Foo/ExampleFoo.php** para sua
aplicação usar.

Se você desejar chame o ``bake`` para criar um arquivo de teste para a sua
classe ``ExampleFoo``, você precisará sobrescrever o método ``bakeTest()`` na
classe ``FooTask`` para registrar a classe sufixo e o namespace para o seu
comando personalizado::

    public function bakeTest($className)
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

* O **sufixo da classe** será anexado ao nome fornecido em sua chamada bake. No
  exemplo anterior, ele criaria um arquivo ExampleFooTest.php.
* O **tipo de classe** será o subdomínio usado que levará ao seu arquivo
  (relativo ao aplicativo ou ao plugin em que você está inserindo). No exemplo
  anterior, ele criaria seu teste com o namespace App\Test\TestCase\Foo.


.. meta::
    :title lang=en: Extending Bake
    :keywords lang=en: command line interface,development,bake view, bake template syntax,twig,erb tags,percent tags

