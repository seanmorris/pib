Chronos
#######

Chronos (クロノス) は、 ``DateTime`` オブジェクトへの拡張の依存関係の無いコレクションを提供します。
便利なメソッドに加えて、Chronos は以下を提供します。

* カレンダー日付のための ``Date`` オブジェクト
* イミュータブルな日付と日時オブジェクト
* プラグインのような翻訳システム。ライブラリーは英語のみの翻訳を含んでいます。
  しかし、全ての言語サポートのために、 ``cakephp/i18n`` を使うことができます。

インストール
------------

Chronos をインストールするためには、 ``composer`` を利用することができます。
アプリケーションの ROOT ディレクトリー（composer.json ファイルのある場所）
で以下のように実行します。 ::

    php composer.phar require cakephp/chronos "@stable"

概要
----

Chronos は PHP が提供する DateTime オブジェクトのいくつかの拡張を提供します。
Chronos は ``DateInterval`` の拡張機能および、ミュータブル（変更可能）と
イミュータブル（変更不可）な 日付/時刻 の派生系をカバーする5つのクラスを提供します。

* ``Cake\Chronos\Chronos`` はイミュータブルな *日付と時刻* オブジェクト。
* ``Cake\Chronos\ChronosDate`` はイミュータブルな *日付* オブジェクト。
* ``Cake\Chronos\MutableDateTime`` はミュータブルな *日付と時刻* オブジェクト。
* ``Cake\Chronos\MutableDate`` はミュータブルな *日付* オブジェクト。
* ``Cake\Chronos\ChronosInterval`` は ``DateInterval`` の拡張機能。

インスタンスの作成
------------------

Chronos または Date のインスタンスを取得するためには、多くの方法があります。
異なる引数セットで動作する多くのファクトリーメソッドがあります。 ::

    use Cake\Chronos\Chronos;

    $now = Chronos::now();
    $today = Chronos::today();
    $yesterday = Chronos::yesterday();
    $tomorrow = Chronos::tomorrow();

    // 相対式のパース
    $date = Chronos::parse('+2 days, +3 hours');

    // 日付と時間の整数値
    $date = Chronos::create(2015, 12, 25, 4, 32, 58);

    // 日付または時間の整数値
    $date = Chronos::createFromDate(2015, 12, 25);
    $date = Chronos::createFromTime(11, 45, 10);

    // 整形した値にパース
    $date = Chronos::createFromFormat('m/d/Y', '06/15/2015');

イミュータブルオブジェクトの動作
--------------------------------

もしあなたが、PHP の ``DateTime`` オブジェクトを使用したことがあるなら、
*ミュータブル* オブジェクトは簡単に使用できます。
Chronos はミュータブルオブジェクトを提供しますが、これは *イミュータブル* オブジェクトにもなります。
イミュータブルオブジェクトはオブジェクトが変更されるたびにオブジェクトのコピーを作ります。
なぜなら、日時周りの変更メソッドは必ずしも透明でないため、データが誤って、
または開発者が知らない内に変更してしまうからです。
イミュータブルオブジェクトはデータが誤って変更されることを防止し、
順序ベースの依存関係の問題の無いコードを作ります。
不変性は、変更時に忘れずに変数を置き換える必要があることを意味しています。 ::

    // このコードはイミュータブルオブジェクトでは動作しません
    $time->addDay(1);
    doSomething($time);
    return $time

    // このコードは期待通りに動作します
    $time = $time->addDay(1);
    $time = doSomething($time);
    return $time

各修正の戻り値をキャプチャーすることによって、コードは期待通りに動作します。
イミュータブルオブジェクトを持っていて、ミュータブルオブジェクトを作りたい場合、
``toMutable()`` が使用できます。 ::

    $inplace = $time->toMutable();

日付オブジェクト
------------------

PHP は単純な DateTime オブジェクトだけを提供します。このクラスのカレンダー日付の表現で、
タイムゾーンおよび、本当に「日」の概念に属していないタイムコンポーネントを含むと、
少し厄介な可能性があります。
Chronos は日時表現のための ``Date`` オブジェクトを提供します。
これらのオブジェクトの時間とタイムゾーンは常に ``00:00:00 UTC`` に固定されており、
全ての書式/差分のメソッドは一日単位で動作します。 ::

    use Cake\Chronos\ChronosDate;

    $today = ChronosDate::today();

    // 時間/タイムゾーンの変更は無視されます
    $today->modify('+1 hours');

    // 出力 '2015-12-20'
    echo $today;

変更メソッド
------------

Chronos オブジェクトは細やかに値を変更できるメソッドを提供します。 ::

    // 日時の値のコンポーネントを設定
    $halloween = Chronos::create()
        ->year(2015)
        ->month(10)
        ->day(31)
        ->hour(20)
        ->minute(30);

また、日時の部分を相対的に変更することもできます。 ::

    $future = Chronos::create()
        ->addYear(1)
        ->subMonth(2)
        ->addDays(15)
        ->addHours(20)
        ->subMinutes(2);

また、ある時間の中で、定義された時点に飛ぶことも可能です。 ::

    $time = Chronos::create();
    $time->startOfDay();
    $time->endOfDay();
    $time->startOfMonth();
    $time->endOfMonth();
    $time->startOfYear();
    $time->endOfYear();
    $time->startOfWeek();
    $time->endOfWeek();

また、1週間中の特定の日にも飛べます。 ::

    $time->next(Chronos::TUESDAY);
    $time->previous(Chronos::MONDAY);

:abbr:`DST (夏時間)` の遷移の前後で日付/時間を変更すると、
あなたの操作で時間が増減するかもしれませんが、その結果、意図しない時間の値になります。
これらの問題を回避するには、最初にタイムゾーンを ``UTC`` に変更し、時間を変更します。 ::

    // 余分な時間が追加されました
    $time = new Chronos('2014-03-30 00:00:00', 'Europe/London');
    debug($time->modify('+24 hours')); // 2014-03-31 01:00:00

    // 最初に UTC に切り替え、そして更新
    $time = $time->setTimezone('UTC')
        ->modify('+24 hours');

時間を変更すると、元のタイムゾーンを追加してローカライズされた時間を取得することができます。

比較メソッド
------------

Chronos の日付/時間オブジェクトの2つのインスタンスを様々な方法で比較することができます。 ::

    // 比較のフルセットが存在します
    // ne, gt, lt, lte.
    $first->eq($second);
    $first->gte($second);

    // カレントオブジェクトが2つのオブジェクトの間にあるかどうかを確認します。
    $now->between($start, $end);

    // どちらの引数が最も近い (closest) か、または最も遠い (farthest) かを見つけます。
    $now->closest($june, $november);
    $now->farthest($june, $november);

また、与えられた値のカレンダーに当たる場所について問い合わせできます。 ::

    $now->isToday();
    $now->isYesterday();
    $now->isFuture();
    $now->isPast();

    // 曜日をチェック
    $now->isWeekend();

    // 他の曜日のメソッドも全て存在します。
    $now->isMonday();

また、値が相対的な期間内にあったかどうかを見つけることができます。 ::

    $time->wasWithinLast('3 days');
    $time->isWithinNext('3 hours');

差の生成
--------

日時比較に加えて、2つの値の差や変化の計算は一般的なタスクです。 ::

    // 差をあらわす DateInterval を取得
    $first->diff($second);

    // 特定の単位での差を取得
    $first->diffInHours($second);
    $first->diffInDays($second);
    $first->diffInWeeks($second);
    $first->diffInYears($second);

フィードやタイムラインで使用するのに適した、人が読める形式の差を生成することができます。 ::

    // 現在からの差
    echo $date->diffForHumans();

    // 別の時点からの差
    echo $date->diffForHumans($other); // 1時間前;

フォーマットの設定
------------------

Chronos は、出力した日時オブジェクトを表示するための多くのメソッドを提供します。 ::

    // setToStringFormat() が制御するフォーマットを使用します
    echo $date;

    // 別の標準フォーマット
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

    // クォーター/週数を取得
    echo $time->toQuarter();         // 4;
    echo $time->toWeek();            // 52

    // 一般的なフォーマット
    echo $time->toTimeString();           // 14:15:16
    echo $time->toDateString();           // 1975-12-25
    echo $time->toDateTimeString();       // 1975-12-25 14:15:16
    echo $time->toFormattedDateString();  // Dec 25, 1975
    echo $time->toDayDateTimeString();    // Thu, Dec 25, 1975 2:15 PM

日付要素の抽出
--------------

日付オブジェクトのプロパティーに直接アクセスして要素を取得することができます。 ::

    $time = new Chronos('2015-12-31 23:59:58');
    $time->year;    // 2015
    $time->month;   // 12
    $time->day;     // 31
    $time->hour     // 23
    $time->minute   // 59
    $time->second   // 58

以下のプロパティーにもアクセスできます。 :

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

テストの支援
------------

単体テストを書いている時、現在時刻を固定すると便利です。Chronos は、
各クラスの現在時刻を修正することができます。
テストスイートの bootstrap 処理に以下を含めることができます。 ::

    Chronos::setTestNow(Chronos::now());
    MutableDateTime::setTestNow(MutableDateTime::now());
    ChronosDate::setTestNow(ChronosDate::parse(Chronos::now()));
    MutableDate::setTestNow(MutableDate::now());

これでテストスイートが開始された時点で全てのオブジェクトの現在時刻を修正します。

例えば、 ``Chronos`` を過去のある瞬間に固定した場合、新たな ``Chronos``
のインスタンスが生成する ``now`` または相対時刻の文字列は、
固定された時刻の相対を返却します。 ::

    Chronos::setTestNow(new Chronos('1975-12-25 00:00:00'));

    $time = new Chronos(); // 1975-12-25 00:00:00
    $time = new Chronos('1 hour ago'); // 1975-12-24 23:00:00

固定をリセットするには、 ``setTestNow()`` をパラメーター無し、または ``null`` を設定して
再び呼び出してください。
