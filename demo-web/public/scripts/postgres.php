<?php // {"autorun":true, "persist":false, "single-expression": false, "render-as": "text"}
$pdo = new PDO('pgsql:idb-storage');
$stm = $pdo->prepare('SELECT * FROM pg_catalog.pg_tables');

if($stm->execute())
while($row = $stm->fetch()) {
    var_dump($row);
}
