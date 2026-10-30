# Week 13 Evidence Index — Submission Inventory

**Project:** Equipment Borrowing Reminder System  
**Student:** Sales, Samuel Jr. C. — BSIT 3 - B  
**Due:** October 30, 2026, 11:59 PM PHT (unless officially revised).  
**GitHub repository:** NOT YET PROVIDED / CREATED  
**Tag or commit for submission:** PENDING actual Git commit  
**Build environment:** PENDING student execution

| Artifact | Location | Evidence status |
|---|---|---|
| Workflow boundary and trigger | `docs/WORKFLOW_AND_API.md` | Prepared (design) |
| Screen-flow sketch and UI state definitions | `docs/WORKFLOW_AND_API.md` | Prepared (design) |
| Flutter Web source | `frontend/lib/` and `frontend/pubspec.yaml` | Authored; Flutter compile/run pending |
| Laravel REST API source and migrations | `backend/` | Authored; Composer install/integration run pending |
| Retry / recovery implementation | `backend/app/Services/ReminderRunner.php` | Authored; API behavior pending actual test |
| Server feature test source | `backend/tests/Feature/Week13WorkflowTest.php` | Authored; PHPUnit execution pending |
| Flutter widget test source | `frontend/test/login_screen_test.dart` | Authored; Flutter execution pending |
| PHP syntax check output | `docs/evidence/php_syntax_check.txt` | Actual PHP CLI lint checks passed |
| Isolated reminder policy tests | `backend/tests/Smoke/ReminderPolicySmoke.php`; `docs/evidence/isolated_policy_smoke_actual.txt` | 11 actual policy checks passed; does **not** validate Laravel HTTP API |
| Success / transient / permanent logs | `docs/logs/` | **Missing actual execution evidence — capture after running** |
| Week 13 test plan / test result form | `docs/WEEK13_TEST_PLAN.md` | Prepared; actual result fields blank |
| Actual browser screenshots | `docs/screenshots/` | **Missing actual execution evidence — capture after running** |
| Visual reference images (not evidence) | `docs/reference_screenshots/` | Illustrative only; not real Flutter screenshots |
| User Manual | `docs/User_Manual.docx`, `docs/USER_MANUAL.md` | Prepared with labeled reference images |
| Week 13 technical portfolio | `docs/Week13_Technical_Portfolio.docx` | Prepared with explicit test status and limitations |
| Individual contribution statement | `docs/INDIVIDUAL_CONTRIBUTION.md` | Draft — verify and sign after execution |
| Repo permission and upload confirmation | To be filled on submission | Pending |

## Minimum captured screenshots

`01_login_actual.png`, `03_add_equipment_actual.png`, `05_success_actual.png`, `06_retry_recovery_actual.png`, `07_permanent_failure_actual.png`, `09_return_actual.png`, `10_network_recovery_actual.png`, `13_responsive_actual.png`.

## Submission check

- [ ] Flutter and Laravel work from documented setup commands
- [ ] Record actual PHP/Flutter versions and Git commit/tag
- [ ] Save real expected and actual results (not just expected)
- [ ] Capture real success, transient/retry/recovery, permanent review event logs
- [ ] Check the submitted files for live credentials and personal data
- [ ] Replace all illustrative User Manual references with real screenshots, or clearly retain them as illustrations alongside actual evidence
- [ ] Push source and `docs/USER_MANUAL.md` plus manual images to the intended GitHub repository
- [ ] Confirm instructor can open repository and files
- [ ] Reopen uploaded submission and preserve proof of upload


## White UI revision status
- UI source revised to formal white/blue glassmorphism with responsive layouts and collapsible icon-only sidebar. **New build has not been compiled in this environment; verify in Android Studio.**
- User-supplied earlier dark-theme login screenshot is located in `docs/Week13_Submissions_0_to_6/04_Flutter_Screens/` and explicitly records a Laravel API connectivity failure only.
- The 0–6 folder map is based on the Drive reference folder structure; it does not contain another student's evidence.
