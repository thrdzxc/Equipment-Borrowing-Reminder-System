# How to Replace Reference Images with Actual Week 13 Screenshots

1. Start the Laravel server and Flutter browser from the README commands. Keep Chrome's URL and test environment identifiable in evidence when appropriate, but never expose passwords or bearer tokens.
2. Log in. Capture `docs/screenshots/01_login_actual.png` (before entering any password) and a dashboard shot after login.
3. Register an equipment item, and capture `03_add_equipment_actual.png`.
4. Add an eligible due-soon borrowing, then run normal success; capture the actual response and activity log as `05_success_actual.png`.
5. Add a new due-soon borrowing. Select `Transient failure → retry → success`. Capture the actual event sequence, especially attempt numbers 1 and 2 and `retry_scheduled`, as `06_retry_recovery_actual.png`.
6. Add a third eligible loan. Select `Permanent failure`, run and capture the `routed_for_review` event as `07_permanent_failure_actual.png`.
7. Demonstrate reset, return, network outage/recovery, mobile-width drawer, and logout with the remaining names in `WEEK13_TEST_PLAN.md`.
8. In `docs/USER_MANUAL.md`, replace image links `reference_screenshots/..._REFERENCE_NOT_LIVE.png` with the matching actual screenshot in `screenshots/`. In DOCX, replace preview images manually or regenerate with the included `tools/generate_manual.py` after actual screenshots are present.
9. Record actual tests, environment, date/time, commit hash and limitations. Do not edit browser output to manufacture success.
