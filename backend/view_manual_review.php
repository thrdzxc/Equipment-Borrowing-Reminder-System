
<?php

$db = new PDO(
    'sqlite:' . __DIR__ . '/database/database.sqlite'
);

$db->setAttribute(
    PDO::ATTR_ERRMODE,
    PDO::ERRMODE_EXCEPTION
);

echo "EQUIPMENT BORROWING REMINDER SYSTEM\n";
echo "WEEK 13 - MANUAL REVIEW RECORDS\n";
echo "--------------------------------------\n\n";

$query = $db->query("SELECT * FROM borrowings ORDER BY id DESC");

foreach ($query->fetchAll(PDO::FETCH_ASSOC) as $record) {
    foreach ($record as $field => $value) {
        echo $field . ": " . ($value ?? "NULL") . "\n";
    }
    echo "--------------------------------------\n";
}
