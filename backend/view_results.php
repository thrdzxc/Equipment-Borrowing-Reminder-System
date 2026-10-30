
<?php
$db = new PDO('sqlite:' . __DIR__ . '/database/database.sqlite');
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "WEEK 13 - AUTOMATION DATABASE RESULTS\n\n";
echo "BORROWING REMINDER STATUS\n";
echo "--------------------------------------\n";

foreach ($db->query(
    "SELECT id, borrower_name, status, reminder_status,
            reminder_attempts, last_error_code
     FROM borrowings ORDER BY id"
) as $row) {
    echo "Loan #{$row['id']} | {$row['borrower_name']}\n";
    echo "Status: {$row['status']}\n";
    echo "Reminder: {$row['reminder_status']}\n";
    echo "Attempts: {$row['reminder_attempts']}\n";
    echo "Error: " . ($row['last_error_code'] ?? 'None') . "\n\n";
}

echo "AUTOMATION EVENT SUMMARY\n";
echo "--------------------------------------\n";

foreach ($db->query(
    "SELECT event_type, result_code, COUNT(*) AS total
     FROM automation_events
     GROUP BY event_type, result_code
     ORDER BY event_type, result_code"
) as $row) {
    echo "{$row['event_type']} | {$row['result_code']}";
    echo " | Count: {$row['total']}\n";
}
