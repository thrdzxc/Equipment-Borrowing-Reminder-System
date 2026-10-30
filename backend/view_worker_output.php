
<?php

$db = new PDO(
    'sqlite:' . __DIR__ . '/database/database.sqlite'
);
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "EQUIPTRACK - WEEK 13\n";
echo "AUTOMATION PROCESSING LOGS\n";
echo "========================================\n\n";

$sql = "
    SELECT run_id, borrowing_id, event_type,
           attempt, result_code, created_at
    FROM automation_events
    WHERE event_type IN (
        'delivery_attempt',
        'routed_for_review',
        'run_complete'
    )
    ORDER BY id DESC
    LIMIT 20
";

$events = $db->query($sql)->fetchAll(PDO::FETCH_ASSOC);

if (!$events) {
    echo "No automation processing events found.\n";
} else {
    foreach ($events as $event) {
        echo "Time: {$event['created_at']}\n";
        echo "Run: {$event['run_id']}\n";
        echo "Borrowing: " .
             ($event['borrowing_id'] ?? 'N/A') . "\n";
        echo "Event: {$event['event_type']}\n";
        echo "Attempt: {$event['attempt']}\n";
        echo "Result: {$event['result_code']}\n";
        echo "----------------------------------------\n";
    }
}
