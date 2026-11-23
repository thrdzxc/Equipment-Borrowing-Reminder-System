# EQUIPTRACK — Equipment Borrowing Reminder System

**Student:** Sales, Samuel Jr. C.  
**Section:** BSIT 3-B  
**Institution:** University of La Salette  
**Course:** Integrative Programming and Technologies 2 / IT Free Elective 2  
**Repository:** https://github.com/thrdzxc/Equipment-Borrowing-Reminder-System  
**Project:** Project 5, Weeks 13–18 (Flutter Web + Laravel REST API)

## Overview

EQUIPTRACK is a classroom prototype for laboratory equipment inventory, borrowing, returns, due-date tracking and *simulated* reminder automation. The primary intended roles are **student**, **laboratory staff**, and **equipment custodian**. It is not a production notification platform; no real email or SMS messages are sent.

**Implemented and demonstrated:** authenticated login/logout, role-restricted inventory and borrowing functions, loan creation/returns with stock updates, health checks, dashboard aggregates, simulated reminder runs with bounded retries and human-review routing, structured automation events, and responsive Flutter Web screens.

**Scope distinction:** The Project 5 reference describes a broader request → approval → release → due-date tracking → return → inspection → closure lifecycle. Standalone approval, inspection, and closure stages have **not been verified** in this build; do not represent them as implemented or UAT-accepted without additional code and testing.

## Architecture

```text
Chrome / Flutter Web (port 3000)
    | JSON REST requests; Sanctum bearer token held in memory
    v
Laravel API (port 8000)
    | Authentication, role checks, validation, transactions,
    | reminder simulation, structured event logs
    v
SQLite (backend/database/database.sqlite)
```

The local development server uses **HTTP loopback only**. Any actual deployment must use trusted HTTPS/TLS and deployment-specific security configuration. SQLite is suitable for the bounded local prototype; production concurrency, backups, recovery and access controls require separate evaluation.

Architecture evaluation: `docs/week17/` supporting documents and evidence, as available in the submission package.

## Role and API scope

| Role | Supported API permissions |
|---|---|
| Student | Authenticated dashboard and equipment list (minimized fields) |
| Staff | Dashboard, equipment list, borrowing list/create/return |
| Custodian | Staff capabilities plus equipment creation, reminder reset, automation run and events |

The backend is authoritative for permissions; Flutter only adjusts visible UI controls.

### Implemented routes (relative to `/api`)

| Method | Route | Access |
|---|---|---|
| GET | `/health` | Public |
| POST | `/auth/login` | Public, rate-limited |
| POST | `/auth/logout` | Authenticated |
| GET | `/dashboard` | Authenticated |
| GET | `/equipment` | Authenticated |
| POST | `/equipment` | Custodian |
| GET | `/borrowings` | Staff or custodian |
| POST | `/borrowings` | Staff or custodian |
| POST | `/borrowings/{borrowing}/return` | Staff or custodian |
| POST | `/borrowings/{borrowing}/reset-reminder` | Custodian |
| GET | `/automation/events` | Custodian |
| POST | `/automation/run` | Custodian, rate-limited |

Detailed request, response, validation and error contracts: **`docs/week17/openapi.yaml`**. The OpenAPI file describes the locally implemented API; it is not proof of production readiness.

## Requirements

- Windows 11, PowerShell, Chrome and Git.
- PHP 8.2+ and Composer, with extensions required by Laravel and SQLite (including `pdo_sqlite` and `sqlite3`).
- Flutter stable SDK supporting the project's `frontend/pubspec.yaml` Dart constraints.
- Ports **8000** and **3000** available.
- Test-only credentials chosen locally, not shared in code or screenshots.

## Local setup — backend

From the **repository root** in PowerShell:

```powershell
cd backend
composer install
Copy-Item .env.example .env
# Edit .env locally: set a strong DEMO_ADMIN_PASSWORD and other test-only secrets.
# Never commit .env, plaintext tokens or database files.
php artisan key:generate
if (!(Test-Path .\database\database.sqlite)) { New-Item -ItemType File .\database\database.sqlite | Out-Null }
php artisan migrate --seed
php artisan serve --host=127.0.0.1 --port=8000
```

If `.env` or the SQLite file already exists and contains your test data, **do not overwrite it or re-run seed/migration operations blindly**. First inspect the current configuration and back up data. `backend/.env.example` contains safe placeholders, including `FRONTEND_ORIGIN=http://localhost:3000`, `TOKEN_TTL_MINUTES=60`, and `SECURE_REQUIRE_HTTPS=false` for loopback development. HTTPS enforcement requires the correct trusted production proxy/TLS setup.

Health endpoint: `http://127.0.0.1:8000/api/health`. A healthy local response contains `status: ok`, `service: equipment-reminder-api`, and `delivery: simulation-only`.

## Local setup — frontend

In **a second PowerShell terminal**, from the repository root:

```powershell
cd frontend
flutter pub get
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

Open `http://localhost:3000`. Use the fictional/local test account configured in your backend. The API bearer token is held in memory and cleared on logout or an authenticated 401 response. Do not use actual student personal data for demonstrations.

If initial Flutter Web platform scaffolding is genuinely absent from a fresh source-only checkout, consult `RUN_WINDOWS_AND_PHONE.md` before creating platform files. Do not overwrite existing `frontend/lib`, `frontend/test`, or `pubspec.yaml`.

## Supported demonstration workflow

1. Log in with an authorized custodian account.
2. Open **Equipment** to review inventory; custodian may add an item with a unique asset tag and positive quantity.
3. Open **Borrowings** and create a controlled loan with a fictional borrower and a valid future due date. Confirm one available unit is deducted.
4. Open **Automation** to run the supported simulation, using an eligible test loan. Review structured events. Modes supported by the API in local/testing environments include `success`, `transient_once`, `transient_always` and `permanent_failure`. An automation run with zero eligible loans demonstrates run completion, **not delivered reminders**.
5. If a loan is routed to `needs_review`, a custodian can reset it when allowed.
6. Mark a loan returned and verify stock restoration. Log out and confirm protected actions require authentication.

Reminder mode override is **local/testing only** and must not be treated as an unrestricted production feature.

## Validation and tests

From `backend`:

```powershell
php .\vendor\phpunit\phpunit\phpunit --testdox
# Or, if available in the installation:
php artisan test
```

From `frontend`:

```powershell
flutter analyze
flutter test --reporter expanded
```

Record the **actual** current test counts, errors and test date; do not carry forward older pass counts without rerunning. Week 13–16 reports contain historical automation, security, hardening, performance and recovery evidence. The health-endpoint load measurements from Week 16 are local prototype observations, not production capacity benchmarks.

## Week 17 — UAT and documentation

- UAT Plan: `Week17_UAT_Plan_Sales_Samuel_Jr_C.docx` (in Week 17 submission evidence folder).
- UAT Results Template: `Week17_UAT_Results_Sales_Samuel_Jr_C.docx` (initially **NOT TESTED**).
- Architecture evaluation and diagrams: Week 17 submission evidence folder.
- OpenAPI contract: `docs/week17/openapi.yaml`.
- Screenshots: Week 17 evidence folder, indexed by evidence ID.

**UAT approval remains a separate prerequisite.** Preliminary developer checks are not equivalent to an instructor-approved UAT session with actual participant feedback. Record expected and actual outcomes, findings, dispositions and retests; do not fabricate a signature, comment or PASS result.

## Known limitations and maintenance

- **Simulated reminders only**: no real outbound delivery or external SMS/email integration.
- **Local development environment**: no production deployment validation or trusted public HTTPS endpoint demonstrated by the described local tests.
- **Lifecycle scope gap**: standalone approval, inspection and formal closure were not verified.
- **SQLite and backups**: suitable for controlled local testing; define backup, restore and concurrency requirements before real multi-user deployment.
- **Security and data minimization**: use fictional records; protect `.env`, tokens, credentials and private data. Review role checks and token expiry in regression testing.
- **Maintenance routine**: rerun backend/frontend tests after changes, check framework dependencies, monitor health/logs, verify backup restoration, update the OpenAPI contract and README when routes change, and keep known issues traceable.

**Readiness:** A classroom prototype for controlled UAT and defense, **not production-approved**. Final recommendation remains conditional on authorized UAT, documented findings and the instructor's evaluation.

## Repository and evidence integrity

Work in the **existing** repository; do **not** run `git init` or add a second `origin`.

```powershell
# From repository root
 git status --short
 git diff --check
 git add README.md docs/week17/openapi.yaml
 git diff --cached --check
 git diff --cached --stat
# After reviewing exactly what is staged:
 git commit -m "Week 17: Add OpenAPI and update project README"
 git push origin main
```

Before committing, ensure `.env`, private keys, tokens, real data, generated SQLite databases, and unnecessary JSON exports are not staged. Keep evidence aligned to the actual commit hash. Do not claim GitHub push success until the remote accepts the commit.

## Files and acknowledgements

- `backend/`: Laravel routes/controllers, models, validation, reminder runner, migrations, tests.
- `frontend/`: Flutter Web interface, API client and widget/security tests.
- `docs/`: Guides, test plans, evidence references and `docs/week17/openapi.yaml`.
- `RUN_WINDOWS_AND_PHONE.md`: Original local development guide.

This project uses Flutter, Dart, Laravel, Sanctum, SQLite, PHPUnit and open-source dependencies. AI assistance in documentation and development should be disclosed according to instructor policy. The author remains responsible for validating claims and understanding the work.
