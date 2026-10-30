
<?php

$db = new PDO(
    'sqlite:' . __DIR__ . '/database/database.sqlite'
);

$db->setAttribute(
    PDO::ATTR_ERRMODE,
    PDO::ERRMODE_EXCEPTION
);

echo "EQUIPMENT BORROWING REMINDER SYSTEM\n";
echo "WEEK 13 - AUTOMATION EVENT LOGS\n";
echo "----------------------------------------\n\n";

$query = $db->query(
    "SELECT * FROM automation_events ORDER BY id DESC LIMIT 20"
);

$events = $query->fetchAll(PDO::FETCH_ASSOC);

if (empty($events)) {
    echo "No automation events recorded yet.\n";
} else {
    foreach ($events as $event) {
        foreach ($event as $column => $value) {
            echo $column . ": " . ($value ?? 'NULL') . "\n";
        }

        echo "----------------------------------------\n";
    }
}
