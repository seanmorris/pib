Расширение возможностей Bake
############################

Bake имеет расширяемую архитектуру, которая позволяет вашему приложению или плагинам
измененять или добавления его базовую функциональность. Bake использует специальный
класс, который использует механизм шаблонизатора `Twig <https://twig.symfony.com/>`_.

События Bake
============

В качестве класса представления ``BakeView`` генерирует те же события, что и любой другой класс представления,
плюс одно дополнительное событие инициализации. Однако, в то время как классы стандартного представления используют
префикс события "View.", ``BakeView`` использует префикс события "Bake.".

Событие initialize можно использовать для внесения изменений, которые применяются ко всем 'испеченным'
выводам, например, чтобы добавить другого помощника в класс вида bake, это событие может
использовать следующее::

    <?php
    // config/bootstrap_cli.php

    use Cake\Event\Event;
    use Cake\Event\EventManager;

    EventManager::instance()->on('Bake.initialize', function (Event $event) {
        $view = $event->getSubject();

        // В моих шаблонах bake, разрешить использование MySpecial helper
        $view->loadHelper('MySpecial', ['some' => 'config']);

        // И добавьте переменную $author, чтобы она всегда была доступна
        $view->set('author', 'Andy');

    });

Если вы хотите изменить выпечку из другого плагина, хорошей идеей будет - поместить
события своего плагина в файл ``config/bootstrap.php``.

События Bake могут быть полезны для внесения небольших изменений в существующие шаблоны.
Например, чтобы изменить имена переменных, используемых для выпечки файлов контроллеров/шаблонов,
можно использовать прослушивающую функцию ``Bake.beforeRender``::

    <?php
    // config/bootstrap_cli.php

    use Cake\Event\Event;
    use Cake\Event\EventManager;

    EventManager::instance()->on('Bake.beforeRender', function (Event $event) {
        $view = $event->getSubject();

        // Использовать $rows для основной переменной данных для индекса (index)
        if ($view->get('pluralName')) {
            $view->set('pluralName', 'rows');
        }
        if ($view->get('pluralVar')) {
            $view->set('pluralVar', 'rows');
        }

        // Используйте $theOne для основной переменной данных для просмотра/редактирования (view/edit)
        if ($view->get('singularName')) {
            $view->set('singularName', 'theOne');
        }
        if ($view->get('singularVar')) {
            $view->set('singularVar', 'theOne');
        }

    });

Вы также можете использовать события ``Bake.beforeRender`` и ``Bake.afterRender`` для
генерирования специфичного файла. Например, если вы хотите добавить определенные действия для
вашего UserController при генерации из файла **Controller/controller.twig**,
вы можете использовать следующее событие::

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
                // добавим действия входа и выхода из системы в контроллер пользователей
                $view->viewVars['actions'] = [
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

При просмотре прослушивателей событий для конкретных шаблонов выпечки вы можете упростить
выпечку связанной логики событий и обеспечить обратные вызовы, которые легче тестировать.

Синтаксис шаблона выпечки
=========================

Файлы шаблонов Bake используют синтаксис шаблонизатора `Twig <https://twig.symfony.com/doc/2.x/>`__.

Так, например, при выпечке такой оболочки:

.. code-block:: bash

    bin/cake bake shell Foo

Используемый шаблон (**vendor/cakephp/bake/src/Template/Bake/Shell/shell.twig**)
будет выглядеть так::

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

И итоговый испеченный класс (**src/Shell/FooShell.php**) будет выглядеть так::

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

    До версии 1.5.0 bake использовал пользовательские теги erb-стиля внутри файлов шаблонов .ctp

    * ``<%`` Bake шаблон открывающего тега php
    * ``%>`` Bake шаблон закрывающего тега php
    * ``<%=`` Bake шаблон php короткого php тега echo
    * ``<%-`` Bake шаблон php открытия тега, удаляющего любые введённые пробелы перед тегом
    * ``-%>`` Bake шаблон php закрытия тега, любые введённые пробелы после тега

.. _creating-a-bake-theme:

Создание темы Bake
==================

Если вы хотите изменить результат, полученный командой "bake", вы можете
создать свою собственную тему('theme') для "bake", которая позволит вам заменить некоторые или все
шаблоны, которые испекает bake. Лучше всего сделать это так:

#. Выпечь новый плагин. Имя плагина - это название темы 'bake'
#. Создать новую диреткорию **plugins/[name]/src/Template/Bake/Template/**.
#. Скопируйте любые шаблоны, которые вы хотите переопределить
   **vendor/cakephp/bake/src/Template/Bake/Template** для сопоставления файлов с вашим плагином.
#. При запуске выпечки используйте параметр ``--theme``, чтобы указать тему выпечки которую вы
   хотите использовать. Чтобы избежать необходимости указывать этот параметр в каждом вызове, вы также можете
   настроить свою тему в качестве темы по умолчанию::

        <?php
        // В config/bootstrap.php или config/bootstrap_cli.php
        Configure::write('Bake.theme', 'MyTheme');

Настройка шаблонов Bake
=======================

Если вы хотите изменить вывод по умолчанию, созданный командой "bake", вы можете
создать свои собственные шаблоны выпечки в своём приложении. Этот способ не использует
``--theme`` в командной строке при выпечке. Лучше всего сделать это так:

#. Создайте новую директорию(папку) **/src/Template/Bake/**.
#. Скопируйте шаблоны которые вы хотите изменить в вашем приложении в
   **vendor/cakephp/bake/src/Template/Bake/**.

Создание новых параметров команды Bake
======================================

Можно добавить новые параметры команды bake или переопределить те, которые предоставлены
CakePHP, создавая задачи в своём приложении или плагинах. Расширение
``Bake\Shell\Task\BakeTask`` найдёт вашу новую задачу и включит ее как часть выпечки.

В качестве примера мы создадим задачу, которая создает произвольный класс foo. Первым делом,
создайте сам файл задачи **src/Shell/Task/FooTask.php**. Мы расширим
``SimpleBakeTask``, поскольку наша задача для оболочки будет простой. ``SimpleBakeTask``
является абстрактным и требует, чтобы мы определили 3 метода, которые подсказывают ему, какова задача
которую должен генерировать файл, и какой шаблон при этом использовать. Наш файл FooTask.php должен выглядеть так::

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

Как только этот файл будет создан, нам нужно создать шаблон, который bake может использовать
для генерации кода. Создайте файл **src/Template/Bake/foo.twig**. В этом файле добавим
следующее содержание::

    <?php
    namespace {{ namespace }}\Foo;

    /**
     * {{ $name }} foo
     */
    class {{ name }}Foo
    {
        // Добавить код.
    }

Теперь вы должны увидеть свою новую задачу в выводе ``bin/cake bake``. Теперь можете
запустить новую задачу, прописав в командной строке: ``bin/cake bake foo Example``.
Это создаст новый класс ``ExampleFoo`` в **src/Foo/ExampleFoo.php** для вашего приложения.

Если вы хотите, чтобы вызов ``bake`` ищё и создавал тестовый файл для вашего
``ExampleFoo``, вам нужно перезаписать метод ``bakeTest()`` в
``FooTask`` для регистрации команды суффикса класса и пространства имен для вашего
пользовательского интерфейса::

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

* **Суффикс класса** будет добавлен к имени, указанному в вашем вызове ``bake``.
  В предыдущем примере он создал бы файл ``ExampleFooTest.php``.

* **Тип файла** будет использовать пространство под-пространство имён(sub-namespace), которое приведёт к файлу (относительно приложения или подключаемого модуля). В предыдущем примере, он создаст ваш тест с пространством имен ``App\Test\TestCase\Foo``.

.. meta::
    :title lang=ru: Расширение возможностей Bake
    :keywords lang=ru: интерфейс командной строки, разработка, выпечка, синтаксис шаблона выпечки, твинг, метки erb, процентные теги
