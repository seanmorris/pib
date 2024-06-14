Chronos
#######

Chronos fournit une collection d'extensions sans aucune dépendance pour l'objet
``DateTime``. En plus de méthodes pratiques, Chronos fournit:

* Des objets ``Date`` pour représenter les dates du calendrier.
* Des objets immutables pour les dates et les datetimes.
* Un système de traduction intégrable. Seules les traductions anglaises sont
  incluses dans la librairie. Cependant, ``cakephp/i18n`` peut être utilisé
  pour un support complet d'autres langues.

Installation
------------

Pour installer Chronos, vous devez utiliser ``composer``. À partir du répertoire
ROOT de votre application (celui où se trouve le fichier composer.json),
exécutez ce qui suit::

    php composer.phar require "cakephp/chronos:^2.0"

Vue d'Ensemble
--------------

Chronos fournit un certain nombre d'extensions pour les objets DateTime fournis
par PHP. Chronos fournit 5 classes qui gèrent les variantes mutables et
immutables de date/time et les extensions de ``DateInterval``.

* ``Cake\Chronos\Chronos`` est un objet de *date et heure* immutable.
* ``Cake\Chronos\ChronosDate`` est un objet de *date* immutable.
* ``Cake\Chronos\MutableDateTime`` est un objet de *date et heure* mutable.
* ``Cake\Chronos\MutableDate`` est un objet de *date* mutable.
* ``Cake\Chronos\ChronosInterval`` est une extension pour l'objet
  ``DateInterval``.

Créer des Instances
-------------------

Il y a plusieurs façons d'obtenir une instance de Chronos ou de Date. Il y a
un certain nombre de méthodes factory qui fonctionnent avec différents ensembles
d'arguments::

    use Cake\Chronos\Chronos;

    $now = Chronos::now();
    $today = Chronos::today();
    $yesterday = Chronos::yesterday();
    $tomorrow = Chronos::tomorrow();

    // Parse les expressions relatives
    $date = Chronos::parse('+2 days, +3 hours');

    // Des entiers indiquant la date et l'heure.
    $date = Chronos::create(2015, 12, 25, 4, 32, 58);

    // Des entiers indiquant la date ou l'heure.
    $date = Chronos::createFromDate(2015, 12, 25);
    $date = Chronos::createFromTime(11, 45, 10);

    // Parse les valeurs formatées.
    $date = Chronos::createFromFormat('m/d/Y', '06/15/2015');

Travailler avec les Objets Immutables
-------------------------------------

Si vous avez utilisé les objets ``DateTime`` de PHP, vous êtes à l'aise avec
les objets *mutable*. Chronos offre des objets mutables, mais elle fournit
également des objets *immutables*. Les objets Immutables créent des copies des
objets à chaque fois qu'un objet est modifié. Puisque les méthodes de
modification autour des datetimes ne sont pas toujours transparentes, les
données peuvent être modifiées accidentellement ou sans que le développeur ne
le sache. Les objets immutables évitent les changements accidentels des
données et permettent de s'affranchir de tout problème lié à l'ordre d'appel
des fonctions ou des dépendances. L'immutabilité signifie que vous devez vous
souvenir de remplacer les variables quand vous utilisez les modificateurs::

    // Ce code ne fonctionne pas avec les objets immutables
    $time->addDay(1);
    doSomething($time);
    return $time;

    // Ceci fonctionne comme vous le souhaitez
    $time = $time->addDay(1);
    $time = doSomething($time);
    return $time;

En capturant la valeur de retour pour chaque modification, votre code
fonctionnera comme souhaité. Si vous avez déjà créé un objet immutable, et que
vous souhaitez un objet mutable, vous pouvez utiliser ``toMutable()``::

    $inplace = $time->toMutable();

Objets Date
-----------

PHP fournit seulement un unique objet DateTime. Représenter les dates de
calendrier peut être un peu gênant avec cette classe puisqu'elle inclut les
timezones, et les composants de time qui n'appartiennent pas vraiment
au concept d'un 'jour'. Chronos fournit un objet ``Date`` qui vous permet
de représenter les dates. Les time et timezone pour ces objets sont toujours
fixés à ``00:00:00 UTC`` et toutes les méthodes de formatage/différence
fonctionnent au niveau du jour::

    use Cake\Chronos\ChronosDate;

    $today = ChronosDate::today();

    // Les changements selon le time/timezone sont ignorés.
    $today->modify('+1 hours');

    // Affiche '2015-12-20'
    echo $today;

Bien que ``Date`` utilise en interne un fuseau horaire fixe, vous pouvez
spécifier le fuseau à utiliser pour l'heure courante telle que ``now()`` ou
``today()``::

    use Cake\Chronos\ChronosDate:

    // Prend l'heure courante pour le fuseau horaire de Tokyo
    $today = ChronosDate::today('Asia/Tokyo');


Méthodes de Modification
------------------------

Les objets Chronos fournissent des méthodes de modification qui vous laissent
modifier la valeur d'une façon assez précise::

    // Définit les composants de la valeur du datetime.
    $halloween = Chronos::create()
        ->year(2015)
        ->month(10)
        ->day(31)
        ->hour(20)
        ->minute(30);

Vous pouvez aussi modifier les parties de la date de façon relative::

    $future = Chronos::create()
        ->addYear(1)
        ->subMonth(2)
        ->addDays(15)
        ->addHours(20)
        ->subMinutes(2);

Il est  également possible de faire des sauts vers des points définis dans le
temps::

    $time = Chronos::create();
    $time->startOfDay();
    $time->endOfDay();
    $time->startOfMonth();
    $time->endOfMonth();
    $time->startOfYear();
    $time->endOfYear();
    $time->startOfWeek();
    $time->endOfWeek();

Ou de sauter à un jour spécifique de la semaine::

    $time->next(Chronos::TUESDAY);
    $time->previous(Chronos::MONDAY);

Quand vous modifiez des dates/heures au-delà d'un passage à l'heure d'été ou à
l'heure d'hiver, vous opérations peuvent gagner/perdre une heure de plus, de
sorte que les heures seront incorrectes. Vous pouvez éviter ce problème en
définissant d'abord le timezone à ``UTC``, ce qui change l'heure::

    // Une heure de plus de gagnée.
    $time = new Chronos('2014-03-30 00:00:00', 'Europe/London');
    debug($time->modify('+24 hours')); // 2014-03-31 01:00:00

    // Passez d'abord à UTC, et modifiez ensuite
    $time = $time->setTimezone('UTC')
        ->modify('+24 hours');

Une fois que vous avez modifié l'heure, vous pouvez repasser au timezone
d'origine pour obtenir l'heure locale.

Méthodes de Comparaison
-----------------------

Une fois que vous avez 2 instances d'objets date/time de Chronos, vous pouvez
les comparer de plusieurs façons::

    // Il exste une suite complète de comparateurs
    // ne, gt, lt, lte.
    $first->eq($second);
    $first->gte($second);

    // Regarder si l'objet courant est entre deux autres.
    $now->between($start, $end);

    // Trouver l'argument le plus proche ou le plus éloigné.
    $now->closest($june, $november);
    $now->farthest($june, $november);

Vous pouvez aussi vous renseigner sur le moment où une valeur donnée tombe dans
le calendrier::

    $now->isToday();
    $now->isYesterday();
    $now->isFuture();
    $now->isPast();

    // Vérifie le jour de la semaine
    $now->isWeekend();

    // Toutes les autres méthodes des jours de la semaine existent aussi.
    $now->isMonday();

Vous pouvez aussi trouver si une valeur était dans une période de temps relative::

    $time->wasWithinLast('3 days');
    $time->isWithinNext('3 hours');

Générer des Différences
-----------------------

En plus de comparer les datetimes, calculer les différences ou les deltas entre
des valeurs est une tâche courante::

    // Récupère un DateInterval représentant la différence
    $first->diff($second);

    // Récupère la différence en tant que nombre d'unités spécifiques.
    $first->diffInHours($second);
    $first->diffInDays($second);
    $first->diffInWeeks($second);
    $first->diffInYears($second);

Vous pouvez générer des différences lisibles qui peuvent vous servir pour
l'utilisation d'un feed ou d'une timeline::

    // Différence à partir de maintenant.
    echo $date->diffForHumans();

    // Différence à partir d'un autre point du temps.
    echo $date->diffForHumans($other); // 1 hour ago;

Formater les Chaînes
--------------------

Chronos fournit un certain nombre de méthodes pour afficher nos sorties d'objets
datetime::

    // Utilise le format contrôlé par setToStringFormat()
    echo $date;

    // Différents formats standards
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

    // Récupère le trimestre
    echo $time->toQuarter();         // 4;
    // Récupère la semaine
    echo $time->toWeek();            // 52;

    // Formatage générique
    echo $time->toTimeString();           // 14:15:16
    echo $time->toDateString();           // 1975-12-25
    echo $time->toDateTimeString();       // 1975-12-25 14:15:16
    echo $time->toFormattedDateString();  // Dec 25, 1975
    echo $time->toDayDateTimeString();    // Thu, Dec 25, 1975 2:15 PM

Extraire des Fragments de Date
------------------------------

Il est possible de récupérer des parties d'un objet date en accédant directement
à ses propriétés::

    $time = new Chronos('2015-12-31 23:59:58.123');
    $time->year;    // 2015
    $time->month;   // 12
    $time->day;     // 31
    $time->hour     // 23
    $time->minute   // 59
    $time->second   // 58
    $time->micro    // 123

Les autres propriétés accessibles sont:

- timezone
- timezoneName
- dayOfWeek
- dayOfMonth
- dayOfYear
- daysInMonth
- timestamp
- quarter
- half

Aides aux Tests
---------------

Quand vous écrivez des tests unitaires, il peut être utile de fixer le *time*
courant. Chronos vous permet de fixer le time courant pour chaque classe.
Pour l'intégrer dans votre processus de démarrage (bootstrap) de suite de tests,
vous pouvez inclure ce qui suit::

    Chronos::setTestNow(Chronos::now());
    MutableDateTime::setTestNow(MutableDateTime::now());
    ChronosDate::setTestNow(ChronosDate::parse(Chronos::now()));
    MutableDate::setTestNow(MutableDate::now());

Ceci va fixer le time courant de tous les objets selon le moment où la suite de
tests a démarré.

Par exemple, si vous fixez le ``Chronos`` à un moment du passé, chaque nouvelle
instance de ``Chronos`` créée avec ``now`` ou une chaine de temps relative, sera
retournée relativement à la date fixée::

    Chronos::setTestNow(new Chronos('1975-12-25 00:00:00'));

    $time = new Chronos(); // 1975-12-25 00:00:00
    $time = new Chronos('1 hour ago'); // 1975-12-24 23:00:00

Pour réinitialiser la "fixation" du temps, appelez simplement ``setTestNow()``
sans paramètre ou avec ``null`` comme paramètre.
