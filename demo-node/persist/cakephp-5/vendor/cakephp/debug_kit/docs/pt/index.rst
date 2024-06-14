Debug Kit
#########

DebugKit é um plugin suportado pelo time principal do CakePHP que oferece uma
barra de ferramentas para auxiliar na depuração de aplicações do CakePHP.

Instalação
==========

Por padrão o DebugKit é instalado com o esqueleto padrão da aplicação. Se
você o removeu e gostaria de reinstalá-lo, você pode executar o seguinte comando
a partir do diretório raiz da aplicação
(onde o arquivo composer.json está localizado)::

    php composer.phar require --dev cakephp/debug_kit "~4.0"

Então, você precisará habilitar o plugin ao executar o seguinte comando::

    bin/cake plugin load DebugKit

Armazenamento do DebugKit
=========================

Por padrão, o DebugKit usa um pequeno banco de dados SQLite no diretório
``/tmp`` de sua aplicação para armazenar os dados referentes ao painel
de informações. Se você quiser que o DebugKit armazene seus dados em outro
lugar, é necessário configurar uma nova conexão com o nome ``debug_kit`` .

Configuração do banco de dados
------------------------------

Como informado anteriormente, por padrão, o DebugKit armazenará os dados do
painel em um banco de dados SQLite no diretório ``/tmp`` de sua aplicação. Se
você não puder instalar a extensão pdo_sqlite do PHP, você pode configurar o
DebugKit para usar um banco de dados diferente ao definir uma conexão
``debug_kit`` em seu arquivo **config/app.php**. Por exemplo::

        /**
         * A conexão debug_kit armazena meta-dados do DebugKit.
         */
        'debug_kit' => [
            'className' => 'Cake\Database\Connection',
            'driver' => 'Cake\Database\Driver\Mysql',
            'persistent' => false,
            'host' => 'localhost',
            //'port' => 'nonstandard_port_number',
            'username' => 'dbusername',    // Your DB username here
            'password' => 'dbpassword',    // Your DB password here
            'database' => 'debug_kit',
            'encoding' => 'utf8',
            'timezone' => 'UTC',
            'cacheMetadata' => true,
            'quoteIdentifiers' => false,
            //'init' => ['SET GLOBAL innodb_stats_on_metadata = 0'],
        ],

Uso da barra de ferramentas
===========================

A barra de ferramentas do DebugKit é composta por vários painéis, que são
exibidos ao clicar no ícone do CakePHP no canto inferior direito da janela do
seu navegador. Uma vez que a barra de ferramentas é aberta, você deverá ver uma
série de botões. Cada um desses botões se expande em um painel de informações
relacionadas.

Cada painel permite a você observar aspectos diferentes da sua aplicação:

* **Cache** Exibe o uso de cache durante uma solicitação e limpa caches.
* **Environment** Exibe variáveis de ambiente relacionadas com PHP + CakePHP.
* **History** Exibe uma lista de requisições anteriores, e permite que você
  carregue e veja dados da barra de ferramentas a partir de solicitações
  anteriores.
* **Include** Exibe os arquivos inclusos divididos por grupo.
* **Log** Exibe todas as entradas feitas nos arquivos de log este pedido.
* **Request** Exibe informações sobre a requisição atual, GET, POST, informações
  sobre a rota atual do Cake e Cookies.
* **Session** Exibe a informação atual da sessão.
* **Sql Logs** Exibe logs SQL para cada conexão com o banco de dados.
* **Timer** Exibe qualquer temporizador que fora definido durante a requisição
  com ``DebugKit\DebugTimer``, e memória utilizada coletada com
  ``DebugKit\DebugMemory``.
* **Variables** Exibe variáveis de View definidas em um Controller.

Tipicamente, um painel manipula a recolha e apresentação de um único tipo
de informações como logs ou informações de requisições. Você pode optar por
visualizar os painéis padrões da barra de ferramentas ou adicionar seus próprios
painéis personalizados.

Usando o painel History
=======================

O painel History é uma das características mais frequentemente confundidas do
DebugKit. Ele oferece uma forma de visualizar os dados de requisições
anteriores na barra de ferramentas, incluindo erros e redirecionamentos.

.. figure:: ../_static/history-panel.png
    :alt: Screenshot do painel History no DebugKit.

Como você pode ver, o painel contém uma lista de requisições. Na esquerda você
pode ver um ponto marcando a requisição ativa. Clicar em qualquer requisição vai
carregar os dados referentes a mesma no painel. Quando os dados são carregados,
os títulos do painel vão sofrer uma transição para indicar que informações
alternativos foram carregados.

.. only:: html or epub

    .. video:: ../_static/history-panel-use.mp4
        :alt: Video do painel History em ação.

Desenvolvendo seus próprios painéis
===================================

Você pode criar seus próprios painéis customizados do DebugKit para ajudar
na depuração de suas aplicações.

Criando uma Panel Class
-----------------------

Panel Classes precisam ser colocadas no diretório **src/Panel**. O
nome do arquivo deve combinar com o nome da classe, então a classe
``MyCustomPanel`` deveria remeter ao nome de arquivo
**src/Panel/MyCustomPanel.php**::

    namespace App\Panel;

    use DebugKit\DebugPanel;

    /**
     * My Custom Panel
     */
    class MyCustomPanel extends DebugPanel
    {
        ...
    }

Perceba que painéis customizados são necessários para extender a classe
``DebugPanel``.

Callbacks
---------

Por padrão objetos do painel possuem dois callbacks, permitindo-lhes acoplar-se
na requisição atual. Painéis inscrevem-se aos eventos ``Controller.initialize``
e ``Controller.shutdown``. Se o seu painel precisa inscrever-se a eventos
adicionais, você pode usar o método ``implementedEvents`` para definir todos os
eventos aos quais o seu painel possa precisar estar inscrito.

Você deveria estudar os painéis nativos para absorver alguns exemplos de como
construir painéis.

Elementos do painel
-------------------

Cada painel deve ter um elemento view que renderiza o conteúdo do mesmo.
O nome do elemento deve ser sublinhado e flexionado a partir do nome da classe.
Por exemplo ``SessionPanel`` deve possuir um elemento nomeado
**session_panel.ctp**, e SqllogPanel deve possuir um elemento nomeado
**sqllog_panel.ctp**. Estes elementos devem estar localizados na raiz do seu
diretório **src/Template/Element**.

Títulos personalizados e Elementos
----------------------------------

Os painéis devem relacionar o seu título e o nome do elemento por convenção. No
entanto, se você precisa escolher um nome de elemento personalizado ou título,
você pode definir métodos para customizar o comportamento do seu painel:

- ``title()`` - Configure o título que é exibido na barra de ferramentas.
- ``elementName()`` - Configure qual elemento deve ser utilizada para um
  determinado painel.

Métodos de captura
------------------

Você também pode implementar os seguintes métodos para customizar como o seu
painel se comporta e se aparenta:

* ``shutdown(Event $event)`` Esse método coleta e prepara os dados para o
  painel. Os dados são geralmente armazenados em ``$this->_data``.
* ``summary()`` Este método retorna uma *string* de dados resumidos para serem
  exibidos na *toolbar*, mesmo quando um painel está minimizado. Frequentemente,
  é um contador ou um pequeno resumo de informações.
* ``data()`` Este método retorna os dados do painel que serão usados como
  contexto para o elemento. Você pode manipular os dados coletados no método
  ``shutdown()``. Esse método **deve** retornar dados que podem ser
  serializados.

Painéis em outros plugins
-------------------------

Painéis disponibilizados por  `plugins
<https://book.cakephp.org/3.0/pt/plugins.html>`_ funcionam quase que totalmente
como outros plugins, com uma pequena diferença: Você deve definir ``public
$plugin`` como o nome do diretório do plugin, com isso os elementos do painel
poderão ser encontrados no momento de renderização::

    namespace MyPlugin\Panel;

    use DebugKit\DebugPanel;

    class MyCustomPanel extends DebugPanel
    {
        public $plugin = 'MyPlugin';
            ...
    }

Para usar um plugin ou painel da aplicação, atualize a configuração do DebugKit
de sua aplicação para incluir o painel::

    Configure::write(
        'DebugKit.panels',
        array_merge(Configure::read('DebugKit.panels'), ['MyCustomPanel'])
    );

O código acima deve carregar todos os painéis padrão tanto como os outros
painéis customizados do ``MyPlugin``.
