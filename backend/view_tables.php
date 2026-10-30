
<?php

$db = new PDO('sqlite:' . __DIR__ . '/database/database.sqlite');
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "EQUIPMENT BORROWING REMINDER SYSTEM\n";
echo "Week 13 - Database Tables\n";
echo "----------------------------------\n";

$result = $db->query(
    "SELECT name FROM sqlite_master
     WHERE type = 'table'
     ORDER BY name"
);

foreach ($result as $row) {
    echo $row['name'] . PHP_EOL;
}
