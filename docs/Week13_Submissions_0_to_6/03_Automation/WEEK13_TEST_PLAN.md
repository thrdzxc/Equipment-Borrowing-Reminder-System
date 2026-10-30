# Week 13 Test Procedure and Evidence Sheet

**Build:** record actual Git commit/tag in Evidence Index. **Environment:** Windows 11, Chrome, Flutter version, Laravel version, PHP version, database driver, and machine configuration must be filled from the real test environment.

**Important:** The test rows below are planned procedures and expected outcomes. Do **not** mark PASS until the integration has actually been executed. No screenshots or API logs have been invented.

## Controlled setup

1. Configure the local `.env` with a strong private demo password. Start Laravel, verify `/api/health`, then start Flutter on port 3000.
2. Log in as the demo operator. Use names like `Demo User A`, not real student records.
3. Use three *separate* loans with due dates within the next 48 hours for T05–T07.
4. Run `php artisan test` and `flutter test` once dependencies are installed; capture actual console output.

| ID | Test / procedure | Expected result | Actual / result | Evidence filename |
|---|---|---|---|---|
| T01 | Sign in with valid local demo account | Dashboard loads; token accepted | NOT RUN | `01_login_actual.png` |
| T02 | POST protected `/equipment` without token | HTTP 401; no change to data | NOT RUN | `02_unauthorized_actual.png` |
| T03 | Add valid `LAB-CAM-03`, name Camera, qty 3 | HTTP 201; appears in inventory | NOT RUN | `03_add_equipment_actual.png` |
| T04 | Add same asset tag twice; qty 0; blank fields | HTTP 422 for each invalid case | NOT RUN | `04_validation_actual.png` |
| T05 | Add Demo Loan A due tomorrow; run success | completed=1, simulated, event log | NOT RUN | `05_success_actual.png` |
| T06 | Add Loan B due tomorrow; run transient_once | 1 retry; attempt 1 transient; attempt 2 success | NOT RUN | `06_retry_recovery_actual.png` |
| T07 | Add Loan C due tomorrow; run permanent_failure | needs_review=1; routed_for_review event; no infinite retry | NOT RUN | `07_permanent_failure_actual.png` |
| T08 | Reset Loan C and rerun normal success | Reminds successfully after review | NOT RUN | `08_manual_recovery_actual.png` |
| T09 | Return Loan A, then attempt duplicate return | Qty increases once, second request HTTP 409 | NOT RUN | `09_return_actual.png` |
| T10 | Stop backend; refresh Flutter Equipment | Network error panel; on restart refresh loads | NOT RUN | `10_network_recovery_actual.png` |
| T11 | Run eligible 11+ loans in one call | Only up to 10 processed, others remain pending | NOT RUN | `11_bounded_workflow_actual.png` |
| T12 | Logout and use old bearer token | HTTP 401 after token revocation | NOT RUN | `12_logout_actual.png` |
| T13 | Resize Chrome viewport to mobile | Nav changes to drawer; controls stay usable | NOT RUN | `13_responsive_actual.png` |
| T14 | Run `php artisan test` and `flutter test` | Both suites pass | NOT RUN | `14_test_console_actual.png` |

**Measured runtime / result:** Not yet executed in a real Flutter + Laravel environment. The source and scenario script require verification on the student's system.

## Expected sample structured event sequences (not execution evidence)

**Success:** `delivery_attempt(SIMULATED_DELIVERY_OK)` → `reminder_completed(SIMULATED_ONLY)`.

**Recovered transient:** `delivery_attempt(TRANSIENT_NETWORK_SIMULATED)` → `retry_scheduled(TRANSIENT_RETRY)` → `delivery_attempt(SIMULATED_DELIVERY_OK)` → `reminder_completed(SIMULATED_ONLY)`.

**Permanent:** `delivery_attempt(PERMANENT_DESTINATION_INVALID)` → `routed_for_review(PERMANENT_DESTINATION_INVALID)`.

## Reproducible backend test suite

Source: `backend/tests/Feature/Week13WorkflowTest.php`. Tests cover unauthorized access, blank input rejection, loan/return inventory safety, transient recovery, permanent safe failure, duplicate asset tag and invalid due date. Run with `php artisan test` from `backend/` after Composer dependencies have been installed. Do not mark tests as passed solely because the file exists.

## Actual result record template

```text
Date and time (Philippine):
Student / tester:
Git commit hash:
Flutter SDK / browser:
PHP / Laravel / DB:
Test ID:
Expected:
Actual:
PASS / FAIL / BLOCKED:
Screenshot / log file:
Defect / rerun notes:
```
