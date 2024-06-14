Chronos
#######

O Chronos oferece uma coleção independente de extensões para lidar com o objeto
``DateTime``. Além de métodos de conveniência, o Chronos oferece:

* Objetos ``Date`` para representar datas de calendário.
* Objetos *date* e *datetime* imutáveis.
* Um sistema de tradução acoplável. Apenas traduções em inglês estão incluídas
  na biblioteca. Todavia, ``cakephp/i18n`` pode ser usado para suporte completo
  a idiomas.

Instalação
----------

Para instalar o Chronos, você deve usar o ``composer``. A partir do diretório
*ROOT* de sua aplicação (local onde o arquivo composer.json está localizado)
execute o seguinte comando::

    php composer.phar require cakephp/chronos "@stable"

Visão geral
-----------

Chronos oferece extensões para lidar com objetos *DateTime* do PHP. 5 classes
cobrem variantes de data/hora mutáveis e imutáveis e uma extensão do objeto
``DateInterval``.

* ``Cake\Chronos\Chronos`` é um objeto *date & time* imutável.
* ``Cake\Chronos\ChronosDate`` é um objeto *date* imutável.
* ``Cake\Chronos\MutableDateTime`` é um objeto *date and time* mutável.
* ``Cake\Chronos\MutableDate`` é um objeto *date* mutável.
* ``Cake\Chronos\ChronosInterval`` é uma extensão do objeto ``DateInterval``.

Criando instâncias
------------------

Existem várias maneiras de criar instâncias do Chronos ou mesmo, do objeto Date.
Um número considerável de métodos padrão que funcionam com conjuntos diferentes
de argumentos::

    use Cake\Chronos\Chronos;

    $now = Chronos::now();
    $today = Chronos::today();
    $yesterday = Chronos::yesterday();
    $tomorrow = Chronos::tomorrow();

    // Interpreta expressões relativas.
    $date = Chronos::parse('+2 days, +3 hours');

    // Valores inteiros de Date e Time.
    $date = Chronos::create(2015, 12, 25, 4, 32, 58);

    // Valores inteiros de Date ou Time.
    $date = Chronos::createFromDate(2015, 12, 25);
    $date = Chronos::createFromTime(11, 45, 10);

    // Interpreta valores formatados.
    $date = Chronos::createFromFormat('m/d/Y', '06/15/2015');

Trabalhando com objetos imutáveis
---------------------------------

Se você é familiarizado com os objetos ``DateTime`` do PHP, você se sentirá
confortável com objetos *mutáveis*. Além de objetos mutáveis o Chronos também
oferece objetos imutáveis que por sua vez criam cópias de objetos toda vez que
um objeto é modificado. Devido ao fato de que metodos modificadores relativos
a data e hora nem sempre serem transparentes, informações podem ser modificadas
acidentalmente ou sem que o desenvolvedor saiba. Objetos imutáveis previnem
essas alterações acidentais nos dados. Imutabilidade significa que você deverá
lembrar de substituir variáveis usando modificadores::

    // Esse código não funciona com objetos imutáveis
    $time->addDay(1);
    doSomething($time);
    return $time;

    // Esse funciona como o esperado
    $time = $time->addDay(1);
    $time = doSomething($time);
    return $time;

Ao capturar o valor de retorno de cada modificação, seu código funcionará como o
esperado. Se você tem um objeto imutável e quer criar um mutável a partir do
mesmo, use ``toMutable()``::

    $inplace = $time->toMutable();

Objetos Date
------------

O PHP disponibiliza um único objeto DateTime. Representar datas de calendário
pode ser um pouco desconfortável por essa classe, uma vez que ela inclui
*timezones* e componentes de hora que realmente não se encaixam no conceito de
'dia'. O Chronos oferece um objeto ``Date`` para representar datas. A hora e a
zona desse objeto é sempre fixado em ``00:00:00 UTC`` e todos os métodos de
formatação/diferença operam sob a resolução de dia::

    use Cake\Chronos\ChronosDate;

    $today = ChronosDate::today();

    // Mudanças na hora/timezone são ignoradas
    $today->modify('+1 hours');

    // Exibe '2016-08-15'
    echo $today;

Métodos modificadores
---------------------

Objetos Chronos disponibilizam métodos que permitem a modificação de valores de
forma granular::

    // Define componentes do valor datetime
    $halloween = Chronos::create()
        ->year(2015)
        ->month(10)
        ->day(31)
        ->hour(20)
        ->minute(30);

Você também pode modificar partes da data relativamente::

    $future = Chronos::create()
        ->addYear(1)
        ->subMonth(2)
        ->addDays(15)
        ->addHours(20)
        ->subMinutes(2);

Também é possível realizar grandes saltos para períodos definidos no tempo::

    $time = Chronos::create();
    $time->startOfDay();
    $time->startOfMonth();
    $time->endOfMonth();
    $time->endOfYear();
    $time->startOfWeek();
    $time->endOfWeek();

Ou ainda para dias específicos da semana::

    $time->next(Chronos::TUESDAY);
    $time->previous(Chronos::MONDAY);

Métodos de comparação
---------------------

Uma vez que você possui 2 instâncias de objetos data/hora do Chronos, é possível
compará-los de várias maneiras::

    // Coleção completa de comparadores
    // ne, gt, lt, lte.
    $first->eq($second);
    $first->gte($second);

    // Veja se o objeto atual está entre outros
    $now->between($start, $end);

    // Encontre qual argumento está mais perto ou mais longe
    $now->closest($june, $november);
    $now->farthest($june, $november);

Você também pode arguir sobre quando um determinado valor cai no calendário::

    $now->isToday();
    $now->isYesterday();
    $now->isFuture();
    $now->isPast();

    // Verifica se o dia é no final de semana
    $now->isWeekend();

    // Todos os métodos para outros dias da semana existem também
    $now->isMonday();

Você também pode verificar se um determinado valor está dentro de um período de
tempo relativo::

    $time->wasWithinLast('3 days');
    $time->isWithinNext('3 hours');

Gerando diferenças
------------------

Em adição à comparação de *datetimes*, calcular diferenças ou deltas entre
valores é uma tarefa simples::

    // Recebe um DateInterval representando a diferença
    $first->diff($second);

    // Recebe a diferença como um contador de unidades específicas
    $first->diffInHours($second);
    $first->diffInDays($second);
    $first->diffInWeeks($second);
    $first->diffInYears($second);

Você pode gerar diferenças de fácil leitura para humanos para usar em um *feed*
ou *timeline*::

    // Diferença em relação ao momento atual
    echo $date->diffForHumans();

    // Diferença em relação a outro período no tempo
    echo $date->diffForHumans($other); // 1 hora atrás;

Formatando strings
------------------

O Chronos disponibiliza métodos para exibir nossos objetos *datetime*::

    // Usa o formato controlado por setToStringFormat()
    echo $date;

    // Diferentes padrões de formato
    echo $time->toAtomString();      // 1975-12-25T14:15:16-05:00
    echo $time->toCookieString();    // Thursday, 25-Dec-1975 14:15:16 EST
    echo $time->toIso8601String();   // 1975-12-25T14:15:16-05:00
    echo $time->toRfc822String();    // Thu, 25 Dec 75 14:15:16 -0500
    echo $time->toRfc850String();    // Thursday, 25-Dec-75 14:15:16 EST
    echo $time->toRfc1036String();   // Thu, 25 Dec 75 14:15:16 -0500
    echo $time->toRfc1123String();   // Thu, 25 Dec 1975 14:15:16 -0500
    echo $time->toRfc2822String();   // Thu, 25 Dec 1975 14:15:16 -0500
    echo $time->toRfc3339String();   // 1975-12-25T14:15:16-05:00
    echo $time->toRssString();       // Thu, 25 Dec 1975 14:15:16 -0500
    echo $time->toW3cString();       // 1975-12-25T14:15:16-05:00

    // Recebe o trimestre
    echo $time->toQuarter();         // 4;

Extraindo componentes de data
-----------------------------

Podemos receber partes de um objeto *date* acessando propriedades::

    $time = new Chronos('2015-12-31 23:59:58');
    $time->year;    // 2015
    $time->month;   // 12
    $time->day;     // 31
    $time->hour     // 23
    $time->minute   // 59
    $time->second   // 58

Outras propriedades que podem ser acessadas são:

- timezone
- timezoneName
- micro
- dayOfWeek
- dayOfMonth
- dayOfYear
- daysInMonth
- timestamp
- quarter
- half

Auxílio para testes
-------------------

Ao escrever testes unitários, fixar a hora atual é bastante útil. O Chronos
lhe permite fixar a hora atual para cada classe. Como parte das suas ferramentas
de testes, você pode incluir o seguinte::

    Chronos::setTestNow(Chronos::now());
    MutableDateTime::setTestNow(MutableDateTime::now());
    ChronosDate::setTestNow(ChronosDate::parse(Chronos::now()));
    MutableDate::setTestNow(MutableDate::now());

Isso irá corrigir a hora atual de todos os objetos para o momento em que o
processo de testes foi iniciado.

Por exemplo, se você fixar o ``Chronos`` em algum momento no passado, qualquer
nova instância do ``Chronos`` criada com ``now`` ou uma *string* de tempo
relativa, teremos um retorno referente ao tempo fixado::

    Chronos::setTestNow(new Chronos('1975-12-25 00:00:00'));

    $time = new Chronos(); // 1975-12-25 00:00:00
    $time = new Chronos('1 hour ago'); // 1975-12-24 23:00:00

