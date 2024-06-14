Migrations
##########

Migrations é um plugin suportado pela equipe oficial do CakePHP que ajuda você a
fazer mudanças no **schema** do banco de dados utilizando arquivos PHP,
que podem ser versionados utilizando um sistema de controle de versão.

Ele permite que você atualize suas tabelas ao longo do tempo. Ao invés de
escrever modificações de **schema** via SQL, este plugin permite que você
utilize um conjunto intuitivo de métodos para fazer mudanças no seu banco de
dados.

Esse plugin é um **wrapper** para a biblioteca `Phinx <https://phinx.org/>`_.

Instalação
==========

Por padrão o plugin é instalado junto com o esqueleto da aplicação.
Se você o removeu e quer reinstalá-lo, execute o comando a seguir a partir do
diretório **ROOT** da sua aplicação
(onde o arquivo composer.json está localizado):

.. code-block:: bash

    $ php composer.phar require cakephp/migrations "@stable"

    # Or if composer is installed globally

    $ composer require cakephp/migrations "@stable"

Para usar o plugin você precisa carregá-lo no arquivo **config/bootstrap.php**
da sua aplicação. Você pode usar o
`shell de plugins do CakePHP
<https://book.cakephp.org/3.0/pt/console-and-shells/plugin-shell.html>`__ para carregar e descarregar
plugins do seu arquivo **config/bootstrap.php**::

    $ bin/cake plugin load Migrations

Ou você pode carregar o plugin editando seu arquivo **config/bootstrap.php** e
adicionando a linha::

    Plugin::load('Migrations');

Adicionalmente, você precisará configurar o banco de dados padrão da sua
aplicação, no arquivo **config/app.php** como explicado na seção
`Configuração de banco de dados <https://book.cakephp.org/3.0/pt/orm/database-basics.html#database-configuration>`__.

Visão Geral
===========

Uma migração é basicamente um arquivo PHP que descreve as mudanças a
serem feitas no banco de dados. Um arquivo de migração pode criar ou excluir
tabelas, adicionar ou remover colunas, criar índices e até mesmo inserir
dados em seu banco de dados.

Aqui segue um exemplo de migração::

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

Essa migração irá adicionar uma tabela chamada ``products`` ao banco de dados
com as seguintes colunas:

- ``id`` coluna do tipo ``integer`` como chave primária
- ``name`` coluna do tipo ``string``
- ``description`` coluna do tipo ``text``
- ``created`` coluna do tipo ``datetime``
- ``modified`` coluna do tipo ``datetime``

.. tip::

    A coluna de chave primária ``id`` será adicionada **implicitamente**.

.. note::

    Note que este arquivo descreve como o banco de dados deve ser **após** a
    aplicação da migração. Neste ponto, a tabela ``products``ainda não existe
    no banco de dados, nós apenas criamos um arquivo que é capaz de criar a
    tabela ``products`` com seus devidos campos ou excluir a tabela caso uma
    operação rollback seja executada.

Com o arquivo criado na pasta **config/MIgrations**, você será capaz de executar
o comando abaixo para executar as migrações no seu banco de dados::

    bin/cake migrations migrate

O comando seguinte irá executar um **rollback** na migração e irá excluir a
tabela recém criada::

    bin/cake migrations rollback

Criando migrations
==================

Arquivos de migração são armazeados no diretório **config/Migrations** da
sua aplicação. O nome dos arquivos de migração têm como prefixo a data
em que foram criados, no formato **YYYYMMDDHHMMSS_MigrationName.php**. Aqui
estão exemplos de arquivos de migração:

* 20160121163850_CreateProducts.php
* 20160210133047_AddRatingToProducts.php

A maneira mais fácil de criar um arquivo de migrações é usando o
``bin/cake bake migration`` a linha de comando.

Por favor, leia a `documentação do Phinx <https://book.cakephp.org/phinx/0/en/migrations.html>`
a fim de conhecer a lista completa dos métodos que você pode usar para escrever
os arquivos de migração.

.. note::

    Ao gerar as migrações através do ``bake`` você ainda pode alterá-las antes
    da sua execução, caso seja necessário.

Sintaxe
-------

A sintaxe do ``bake`` para a geração de migrações segue o formato abaixo::

    $ bin/cake bake migration CreateProducts name:string description:text created modified

Quando utilizar o ``bake`` para criar as migrações, você normalmente precisará
informar os seguintes dados::

  * o nome da migração que você irá gerar (``CreateProducts`` por exemplo)
  * as colunas da tabela que serão adicionadas ou removidas na migração
  (``name:string description:text created modified`` no nosso caso)

Devido às convenções, nem todas as alterações de schema podem ser realizadas
através destes comandos.

Além disso, você pode criar um arquivo de migração vazio caso deseje ter um
controle total do que precisa ser executado. Para isto, apenas omita a definição
das colunas::

    $ bin/cake migrations create MyCustomMigration

Nomenclatura de migrations
~~~~~~~~~~~~~~~~~~~~~~~~~~

A nomenclatura das migrações pode seguir qualquer um dos padrões apresentados a
seguir:

* (``/^(Create)(.*)/``) Cria a tabela especificada.
* (``/^(Drop)(.*)/``) Exclui a tabela especificada.
  Ignora campos especificados nos argumentos
* (``/^(Add).*(?:To)(.*)/``) Adiciona campos a
  tabela especificada
* (``/^(Remove).*(?:From)(.*)/``) Remove campos de uma
  tabela específica
* (``/^(Alter)(.*)/``) Altera a tabela especificada. Um apelido para
  um CreateTable seguido de um AlterTable
* (``/^(Alter).*(?:On)(.*)/``) Alterar os campos da tabela especificada

Você também pode usar  ``underscore_form`` como nome das suas **migrations**.
Ex.: ``create_products``.

.. versionadded:: cakephp/migrations 1.5.2

    A partir da versão 1.5.2 do `plugin migrations <https://github.com/cakephp/migrations/>`_,
    o nome dos arquivos de migrações são colocados automaticamente no padrão
    **camel case**.
    Esta versão do plugin está disponível apenas a partir da versão 3.1 do
    CakePHP.
    Antes disto, o padrão de nomes do plugin migrations utilizava a nomenclatura
    baseada em **underlines**, ex.:  ``20160121164955_create_products.php``.

.. warning::

    O nome das migrações são usados como nomes de classe, e podem colidir com
    outras migrações se o nome das classes não forem únicos. Neste caso, pode
    ser necessário sobreescrever manualmente os nomes mais tarde ou simplesmente
    mudar os nomes que você está especificando.

Definição de colunas
~~~~~~~~~~~~~~~~~~~~

Quando utilizar colunas na linha de comando, pode ser útil lembrar que eles seguem o
seguinte padrão::

    fieldName:fieldType[length]:indexType:indexName

Por exemplo, veja formas válidas de especificar um campo de e-mail:

* ``email:string:unique``
* ``email:string:unique:EMAIL_INDEX``
* ``email:string[120]:unique:EMAIL_INDEX``

O parâmetro ``length`` para o ``fieldType`` é opcional e deve sempre ser
escrito entre colchetes

Os campos  ``created`` e ``modified`` serão automaticamente definidos
como ``datetime``.

Os tipos de campos são genericamente disponibilizados pela biblioteca ``Phinx``.
Eles podem ser:

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

Há algumas heurísticas para a escolha de tipos de campos que não são especificados
ou são definidos com valor inválido. O tipo de campo padrão é ``string``;

* id: integer
* created, modified, updated: datetime

Criando uma tabela
------------------

Você pode utilizar o ``bake`` para criar uma tabela::

    $ bin/cake bake migration CreateProducts name:string description:text created modified

A linha de comando acima irá gerar um arquivo de migração parecido com este::

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

Adicionando colunas a uma tabela existente
------------------------------------------

Se o nome da migração na linha de comando estiver na forma "AddXXXToYYY" e
for seguido por uma lista de nomes de colunas e tipos, então o arquivo de
migração com o código para criar as colunas será gerado::

    $ bin/cake bake migration AddPriceToProducts price:decimal

A linha de comando acima irá gerar um arquivo com o seguinte conteúdo::

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

Adicionando uma coluna como indice a uma tabela
-----------------------------------------------

Também é possível adicionar índices a colunas::

    $ bin/cake bake migration AddNameIndexToProducts name:string:index

irá gerar::

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

Especificando o tamanho do campo
--------------------------------

.. versionadded:: cakephp/migrations 1.4

Se você precisar especificar o tamanho do campo, você pode fazer isto entre
colchetes logo após o tipo do campo, ex.::

    $ bin/cake bake migration AddFullDescriptionToProducts full_description:string[60]

Executar o comando acima irá gerar::

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

Se o tamanho não for especificado, os seguintes padrões serão utilizados:

* string: 255
* integer: 11
* biginteger: 20

Alterar uma coluna de uma tabela
-----------------------------------

Da mesma maneira, você pode gerar uma migração para alterar uma coluna usando a
linha de comando, se o nome da migração estiver no formato "X""AlterXXXOnYYY":

.. code-block:: bash

    bin/cake bake migration AlterPriceOnProducts name:float

Cria o arquivo::

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

Removendo uma coluna de uma tabela
----------------------------------

Da mesma forma, você pode gerar uma migração para remover uma coluna
utilizando a linha de comando, se o nome da migração estiver na forma
"RemoveXXXFromYYY"::

    $ bin/cake bake migration RemovePriceFromProducts price

Cria o arquivo::

    <?php
    use Migrations\AbstractMigration;

    class RemovePriceFromProducts extends AbstractMigration
    {
        public function change()
        {
            $table = $this->table('products');
            $table->removeColumn('price');
        }
    }

Gerando migrações a partir de uma base de dados existente
=========================================================

Se você está trabalhando com um banco de dados pré-existente e quer começar
a usar migrações, ou para versionar o schema inicial da base de dados da sua
aplicação, você pode executar o comando ``migration_snapshot``::

    $ bin/cake bake migration_snapshot Initial

Isto irá gerar um arquivo de migração chamado **YYYYMMDDHHMMSS_Initial.php**
contendo todas as instruções CREATE para todas as tabelas no seu banco de dados.

Por padrão, o snapshot será criado a partir da conexão ``default`` definida na
configuração.
Se você precisar fazer o bake de um snapshot de uma fonte de dados diferente,
você pode utilizar a opção ``--connection``::

    $ bin/cake bake migration_snapshot Initial --connection my_other_connection

Você também pode definir que o snapshot inclua apenas as tabelas para as quais
você tenha definido models correspendentes, utilizando a flag
``require-table``::

    $ bin/cake bake migration_snapshot Initial --require-table

Quando utilizar a flag ``--require-table``, o shell irá olhar através das
classes do diretório ``Table`` da sua aplicação e apenas irá adicionar no
snapshot as tabelas lá definidas.

A mesma lógica será aplicada implicitamente se você quiser fazer o bake de um
snapshot para um plugin. Para fazer isso, você precisa usar a opção
``--plugin``, veja a seguir::

    $ bin/cake bake migration_snapshot Initial --plugin MyPlugin

Apenas as tabelas que tiverem um objeto ``Table`` definido serão adicionadas
ao snapshot do seu plugin.

.. note::

    Quando fizer o bake de um snapshot para um plugin, os arquivos de migrações
    serão criados no diretório **config/Migrations** do seu plugin.

Fique atento que quando você faz o bake de um snapshot, ele é automaticamente
 adicionado ao log do phinx como migrado.

Gerando um *diff* entre dois estados da base de dados
=====================================================

.. versionadded:: cakephp/migrations 1.6.0

Você pode gerar um arquivo de migração que agrupará todas as diferenças entre
dois estados de uma base de dados usando ``migration_diff``. Para fazê-lo,
você pode usar o seguinte comando::

    $ bin/cake bake migration_diff NomeDasMigrações

De forma a ter um ponto de comparação do estado atual da sua base de dados, a
*shell* de ``migrations`` gerará um arquivo de *dump* após cada chamada de
``migrate`` ou ``rollback``. O arquivo de *dump* é um arquivo contendo o
estado completo do esquema da sua base de dados em um determinado instante no
tempo.

Uma vez gerado o arquivo de *dump*, cada modificação que você fizer
diretamente no seu sistema de gerenciamento da base de dados será adicionada
quando você chamar o comando ``bake migration_diff``.

Por padrão, o *diff* será criado através de uma conexão com a base de dados
definida na configuração de conexão ``default``.
Se você precisar criar um *diff* de uma fonte de dados diferente, você pode
usar a opção ``--connection``::

    $ bin/cake bake migration_diff NomeDasMigrações --connection minha_outra_conexão

Se você quiser usar a funcionalidade de *diff* em uma aplicação que já possui
um histórico de migrações, você precisará criar manualmente o arquivo de
*dump* a ser usado como base da comparação::

    $ bin/cake migrations dump

O estado da base de dados deve ser o mesmo que você teria caso você tivesse
migrado todas as suas migrações antes de criar o arquivo de *dump*.
Uma vez que o arquivo de *dump* for gerado, você pode começar a fazer
modificações na sua base de dados e usar o comando ``bake migration_diff``
sempre que desejar.

.. note::

    A *shell* de migrações não é capaz de detectar colunas renomeadas.

Os Comandos
===========

``migrate`` : Aplicando migrações
---------------------------------

Depois de ter gerado ou escrito seu arquivo de migração, você precisa executar
o seguinte comando para aplicar as mudanças a sua base de dados::

    # Executa todas as migrações
    $ bin/cake migrations migrate

    # Execute uma migração específica utilizando a opção ``--target`` ou ``-t``
    # O valor é um timestamp que serve como prefixo para cada migração::
    $ bin/cake migrations migrate -t 20150103081132

    # Por padrão, as migrações ficam no diretório **config/Migrations**. Você
    # pode especificar um diretório utilizando a opção ``--source`` ou ``-s``.
    # O comando abaixo executa as migrações no diretório **config/Alternate**
    $ bin/cake migrations migrate -s Alternate

    # Você pode executar as migrações de uma conexão diferente da ``default``
    # utilizando a opção ``--connection`` ou ``-c``.
    $ bin/cake migrations migrate -c my_custom_connection

    # Migrações também podem ser executadas para plugins. Simplesmente utilize
    # a opção ``--plugin`` ou ``-p``
    $ bin/cake migrations migrate -p MyAwesomePlugin

``rollback`` : Revertendo migrações
-----------------------------------

O comando rollback é utilizado para desfazer migrações realizadas anteriormente
pelo plugin Migrations. É o inverso do comando ``migrate``::

    # Você pode desfazer uma migração anterior utilizando o
    # comando ``rollback``::
    $ bin/cake migrations rollback

    # Você também pode passar a versão da migração para voltar
    # para uma versão específica::
    $ bin/cake migrations rollback -t 20150103081132

Você também pode utilizar as opções ``--source``, ``--connection`` e
``--plugin`` exatamente como no comando ``migrate``.

``status`` : Status da migração
-------------------------------

O comando status exibe uma lista de todas as migrações juntamente com seu
status. Você pode utilizar este comando para ver quais migrações foram
executadas::

    $ bin/cake migrations status

Você também pode ver os resultados como JSON utilizando a opção
``--format`` (ou ``-f``)::

    $ bin/cake migrations status --format json

Você também pode utilizar as opções ``--source``, ``--connection`` e
``--plugin`` exatamente como no comando ``migrate``.

``mark_migrated`` : Marcando uma migração como migrada
------------------------------------------------------

.. versionadded:: 1.4.0

Algumas vezes pode ser útil marcar uma lista de migrações como migrada sem
efetivamente executá-las.
Para fazer isto, você pode usar o comando ``mark_migrated``. O comando é
bastante semelhante aos outros comandos.

Você pode marcar todas as migrações como migradas utilizando este comando::

    $ bin/cake migrations mark_migrated

Você também pode marcar todas as migrações de uma versão específica
utilizando a opção ``--target``::

    $ bin/cake migrations mark_migrated --target=20151016204000

Se você não quer marcar a migração alvo como migrada durante o processo, você
pode utilizar a opção ``--exclude``::

    $ bin/cake migrations mark_migrated --target=20151016204000 --exclude

Finalmente, se você deseja marcar somente a migração alvo como migrada,
você pode utilizar a opção ``--only``::

    $ bin/cake migrations mark_migrated --target=20151016204000 --only

Você também pode utilizar as opções ``--source``, ``--connection`` e
``--plugin`` exatamente como no comando ``migrate``.

.. note::

    Quando você criar um snapshot utilizando o bake com o comando
    ``cake bake migration_snapshot``, a migração criada será automaticamente
    marcada como migrada.

.. deprecated:: 1.4.0

    A seguinte maneira de utilizar o comando foi depreciada. Use somente se
    você estiver utilizando uma versão do plugin inferior a 1.4.0.

Este comando espera um número de versão de migração como argumento::

    $ bin/cake migrations mark_migrated

Se você deseja marcar todas as migrações como migradas, você pode utilizar
o valor especial ``all``. Se você o utilizar, ele irá marcar todas as migrações
como migradas::

    $ bin/cake migrations mark_migrated all

``seed`` : Populando seu banco de dados
---------------------------------------

A partir da versão 1.5.5, você pode usar a **shell** de ``migrations`` para
popular seu banco de dados. Essa função é oferecida graças ao
`recurso de seed da biblioteca Phinx <https://book.cakephp.org/phinx/0/en/seeding.html>`_.
Por padrão, arquivos **seed** ficarão no diretório ``config/Seeds`` de sua
aplicação. Por favor, tenha certeza de seguir as
`instruções do Phinx para construir seus arquivos de seed <https://book.cakephp.org/phinx/0/en/seeding.html#creating-a-new-seed-class>`_.

Assim como nos **migrations**, uma interface do ```bake`` é oferecida para gerar
arquivos de **seed**::

    # This will create a ArticlesSeed.php file in the directory config/Seeds of your application
    # By default, the table the seed will try to alter is the "tableized" version of the seed filename
    $ bin/cake bake seed Articles

    # You specify the name of the table the seed files will alter by using the ``--table`` option
    $ bin/cake bake seed Articles --table my_articles_table

    # You can specify a plugin to bake into
    $ bin/cake bake seed Articles --plugin PluginName

    # You can specify an alternative connection when generating a seeder.
    $ bin/cake bake seed Articles --connection connection

.. versionadded:: cakephp/migrations 1.6.4

    As opções ``--data``, ``--limit`` e ``--fields`` foram adicionadas para
    exportar dados da sua base de dados.

A partir da versão 16.4, o comando ``bake seed`` permite que você crie um
arquivo de *seed* com dados exportados da sua base de dados com o uso da
*flag* ``--data``::

    $ bin/cake bake seed --data Articles

Por padrão, esse comando exportará todas as linhas encontradas na sua
tabela. Você pode limitar o número de linhas a exportar usando a opção
``--limit``::

    # Exportará apenas as 10 primeiras linhas encontradas
    $ bin/cake bake seed --data --limit 10 Articles

Se você deseja incluir apenas uma seleção dos campos da tabela no seu
arquivo de *seed*, você pode usar a opção ``--fields``. Ela recebe a
lista de campos a incluir na forma de uma *string* separada por
vírgulas::

    # Exportará apenas os campos `id`, `title` e `excerpt`
    $ bin/cake bake seed --data --fields id,title,excerpt Articles

.. tip::

    Você pode utilizar ambas as opções ``--limit`` e ``--fields``
    simultaneamente em uma mesma chamada.

Para popular seu banco de dados, você pode usar o subcomando ``seed``::

    # Without parameters, the seed subcommand will run all available seeders
    # in the target directory, in alphabetical order.
    $ bin/cake migrations seed

    # You can specify only one seeder to be run using the `--seed` option
    $ bin/cake migrations seed --seed ArticlesSeed

    # You can run seeders from an alternative directory
    $ bin/cake migrations seed --source AlternativeSeeds

    # You can run seeders from a plugin
    $ bin/cake migrations seed --plugin PluginName

    # You can run seeders from a specific connection
    $ bin/cake migrations seed --connection connection

Esteja ciente que, ao oposto das **migrations**, **seeders** não são
versionados, o que significa que o mesmo **seeder** pode ser aplicado diversas
vezes.

Usando migrations em plugins
============================

**Plugins** também podem oferecer **migrations**. Isso faz com que **plugins**
que são planejados para serem distribuídos tornem-se muito mais práticos e
fáceis de instalar. Todos os comandos do plugin **Migrations** suportam a opção
``--plugin`` ou ``-p``, que por sua vez vai delegar a execução da tarefa ao
escopo relativo a um determinado **plugin**::

    $ bin/cake migrations status -p PluginName

    $ bin/cake migrations migrate -p PluginName

Executando migrations em ambientes fora da linha de comando
===========================================================

.. versionadded:: cakephp/migrations 1.2.0

Desde o lançamento da versão 1.2 do plugin, você pode executar **migrations**
fora da linha de comando, diretamente de uma aplicação, ao usar a nova classe
``Migrations``. Isso pode ser muito útil caso você esteja desenvolvendo um
instalador de **plugins** para um CMS, para exemplificar.

A classe ``Migrations`` permite que você execute os seguintes comandos
disponíveis na **shell**:

* migrate
* rollback
* markMigrated
* status
* seed

Cada um desses comandos tem um método definido na classe ``Migrations``.

Veja como usá-la::

    use Migrations\Migrations;

    $migrations = new Migrations();

    // Retornará um array de todos migrations e seus status
    $status = $migrations->status();

    // Retornará true se bem sucedido. Se um erro ocorrer, uma exceção será lançada
    $migrate = $migrations->migrate();

    // Retornará true se bem sucedido. Se um erro ocorrer, uma exceção será lançada
    $rollback = $migrations->rollback();

    // Retornará true se bem sucedido. Se um erro ocorrer, uma exceção será lançada
    $markMigrated = $migrations->markMigrated(20150804222900);

    // Retornará true se bem sucedido. Se um erro ocorrer, uma exceção será lançada
    $seeded = $migrations->seed();

Os métodos aceitam um **array** de parâmetros que devem combinar com as opções
dos comandos::

    use Migrations\Migrations;

    $migrations = new Migrations();

    // Retornará um array de todos migrations e seus status
    $status = $migrations->status(['connection' => 'custom', 'source' => 'MyMigrationsFolder']);

Você pode passar qualquer opção que esteja disponível pelos comandos **shell**.
A única exceção é o comando ``markMigrated`` que espera um número de versão a
ser marcado como migrado, como primeiro argumento. Passe o **array** de
parâmetros como segundo argumento nesse caso.

Opcionalmente, você pode passar esses parâmetros pelo construtor da classe.
Eles serão usados como padrão evitando que você tenha que passá-los em cada
chamada do método::

    use Migrations\Migrations;

    $migrations = new Migrations(['connection' => 'custom', 'source' => 'MyMigrationsFolder']);

    // Todas as chamadas de métodos serão executadas usando os parâmetros passados pelo construtor da classe
    $status = $migrations->status();
    $migrate = $migrations->migrate();

Se você precisar sobrescrever um ou mais parâmetros definidos previamente, você
pode passá-los para um método::

    use Migrations\Migrations;

    $migrations = new Migrations(['connection' => 'custom', 'source' => 'MyMigrationsFolder']);

    // Essa chamada será feita com a conexão "custom"
    $status = $migrations->status();
    // Essa chamada será feita com a conexão "default"
    $migrate = $migrations->migrate(['connection' => 'default']);

Dicas e truques
===============

Criando chaves primárias customizadas
-------------------------------------

Se você precisa evitar a criação automática da chave primária ``id`` ao
adicioanr novas tabelas ao banco de dados, é possível usar o segundo argumento
do método ``table()``::

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

O código acima vai criar uma coluna ``CHAR(36)`` ``id`` que também é a chave
primária.

.. note::

    Ao especificar chaves primárias customizadas pela linha de comando, você
    deve apontá-las como chave primária no campo id, caso contrário você pode
    receber um erro apontando campos diplicados, i.e.::

        $ bin/cake bake migration CreateProducts id:uuid:primary name:string description:text created modified

Adicionalmente, desde a versão 1.3, uma novo meio de lidar com chaves primárias
foi introduzido. Para tal, sua classe de migração deve estender a nova classe
``Migrations\AbstractMigration``.

Você pode especificar uma propriedade ``autoId`` na sua classe e defini-la como
``false``, o quê desabilitará a geração automática da coluna ``id``. Você
vai precisar criar manualmente a coluna que será usada como chave primária e
adicioná-la à declaração da tabela::

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

Comparado ao método apresentado anteriormente de lidar com chaves primárias,
nesse método, temos a possibilidade de ter maior controle sobre as definições
da coluna da chave primária:
unsigned, limit, comentários, etc.

Todas as migrations e snapshots criadas pelo bake vão usar essa nova forma
quando necessário.

.. warning::

    Lidar com chaves primárias só é possível no momento de criação de tabelas.
    Isso é devido a algumas limitações de alguns servidores de banco de dados
    que o plugin suporta.

Colações
--------

Se você precisar criar uma tabela com colação diferente do padrão do banco de
dados, você pode defini-la pelo método ``table()``, como uma opção::

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

Note que isso só pode ser feito na criação da tabela : não há atualmente uma
forma de adicionar uma coluna a uma tabela existente com uma colação diferente
do padrão da tabela, ou mesmo do banco de dados.
Apenas ``MySQL`` e ``SqlServer`` suportam essa chave de configuração.

Atualizando nome de colunas e usando objetos de tabela
------------------------------------------------------

Se você usa um objeto ORM Table do CakePHP para manipular valores do seu banco
de dados, renomeando ou removendo uma coluna, certifique-se de criar uma nova
instância do seu objeto depois da chamada do ``update()``. O registro do objeto
é limpo depois da chamada do ``update()`` para atualizar o **schema** que é
refletido e armazenado no objeto ``Table`` paralelo à instanciação.

Migrations e Deployment
-----------------------

Se você usa o plugin ao fazer o **deploy** de sua aplicação, garanta que o cache
ORM seja limpo para renovar os metadados das colunas de suas tabelas.
Caso contrário, você pode acabar recebendo erros relativos a colunas
inexistentes ao criar operações nessas mesmas colunas.
O **core** do CakePHP possui uma
`Schema Cache Shell <https://book.cakephp.org/3.0/en/console-and-shells/schema-cache.html>`__
que você pode usar para realizar essas operação::

    $ bin/cake schema_cache clear

Leia a seção `Schema Cache Shell
<https://book.cakephp.org/3.0/en/console-and-shells/schema-cache.html>`__ do cookbook
se você quiser conhecer mais sobre essa **shell**.
