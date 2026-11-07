# Week 14 — Secure Integration (SA8 + IA5)

**Project 5:** Equipment Borrowing Reminder System
**Individual student:** Sales, Samuel Jr. C. | BSIT 3-B
**Course:** PFEBSIT 002 — Integrative Programming and Technologies 2
**Documented deadline:** November 6, 2026, 11:59 PM Philippine Standard Time (official LMS/instructor changes prevail).

## What has changed

This is an incremental update to the existing Week 13 staff-operated Flutter Web + Laravel + SQLite prototype, **not a new repository**. The Week 13 reminder simulation, bounded retry logic and borrowing/return flow have been retained.

New Week 14 code:
- Least-privilege role checks enforced by Laravel middleware: `student`, `staff`, `custodian`.
- A role migration; custodian assignment is explicit in the local controlled-data seeder, never accepted from a request body.
- A short-lived Sanctum bearer token (default 60 minutes, configurable 5–120), logout revocation, client-side 401 handling, and no persistent browser token storage.
- HTTPS-required enforcement on API routes for staging/production. Local HTTP for development is **not** evidence of encrypted transport.
- CORS limited to the configured frontend origin; no wildcard; no cookie credentials.
- No-store/no-referrer/nosniff API response headers.
- Stronger borrowing-name validation, minimal login user response, limited borrowing projection and sanitized automation event fields.
- Week 14 security tests in `backend/tests/Feature/Week14SecurityTest.php` and `frontend/test/api_client_security_test.dart`.

## Important limits

- This is a classroom **simulation**, not real email/SMS or a production service. No actual third-party encryption key or private certificate is included.
- Week 13 only implemented a staff-operated checkout, not the guide's complete student request/approval/release/inspection/closure workflow. That gap is recorded as residual scope for later weeks, not silently claimed complete.
- The `student` role may see the inventory and aggregate dashboard but not borrowing names. Only `staff`/`custodian` may operate loans; only `custodian` may administer equipment and reminders.
- The source package cannot contain actual screenshots of unperformed Windows checks. Follow `03_TEST_PLAN_AND_EVIDENCE_INDEX.md` and attach your own actual outputs.

## Required next actions on your Windows PC

1. Follow `05_MERGE_AND_RUN_WINDOWS.md` to copy this package into the **same** existing GitHub-connected Week 13 project folder without deleting `.git`, your private `.env`, or your SQLite database.
2. Run migration (`php artisan migrate`) and then local seeding (`php artisan db:seed`) after configuring unique passwords in private `.env` for demo custodian/staff/student accounts. **Do not screenshot credentials or upload `.env`.**
3. Run backend PHPUnit tests, Flutter analysis/tests, the role checks, and the browser workflow. Capture actual evidence using `03_TEST_PLAN_AND_EVIDENCE_INDEX.md`.
4. Complete the expected/actual evidence matrix, record real commit hash, and push the amended project to the **existing** `thrdzxc/Equipment-Borrowing-Reminder-System` repository.
5. Verify the original .env/SQLite files remain ignored (`git status --ignored`) and inspect staged diff before push.

## Verification accomplished in the package-building environment

- PHP source linted successfully with `php -l` for API, configuration, migrations, and tests.
- Existing isolated reminder policy smoke script reported 11 PASS conditions (real output in `evidence/policy_smoke_actual.txt`).
- **Not run:** Laravel integration tests or Flutter tests in the package-building environment; the runtime here lacks `pdo_sqlite` and Flutter. This does not claim Week 14 functionality passed before you run the tests.

## Documents

`01_SECURITY_DESIGN.md`: role matrix, data flows, controls, design decisions.
`02_PROTECTION_MATRIX.md`: field/asset risks and protection requirements.
`03_TEST_PLAN_AND_EVIDENCE_INDEX.md`: repeatable cases with screenshots and actual-result blanks.
`04_RESIDUAL_RISK_AND_CONTRIBUTION.md`: known limitations and an honest completion template.
`05_MERGE_AND_RUN_WINDOWS.md`: precise update, local commands, HTTPS/hosting limitations, Git push guidance.
