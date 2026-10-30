# Equipment Borrowing Reminder System — Week 13

**Author:** Sales, Samuel Jr. C. | **Section:** BSIT 3 - B  
**Course:** Integrative Programming and Technologies 2 / IT Free Elective 2  
**Week 13:** Advanced Automation and Scripting (October 26–30, 2026)

## Project overview

A Week 13 classroom proof-of-concept in **Flutter Web + Laravel REST API + SQLite**. Staff operators register inventory, issue equipment loans, and manually trigger due-soon reminder simulation.

**UI update (v1.2 white edition):** The Flutter Web client uses a formal white/blue glass interface with frosted panels, clear contrast, an icon-only collapsible sidebar, and a mobile drawer. The four promotional labels were removed. The supplied ULS logo and campus images remain as subtle branded assets. This revised source requires a fresh local Flutter build.

**Automation scope:** The backend processes up to 10 eligible loans per run, attempts at most 3 simulated notifications per loan, retries transient errors with bounded backoff, routes permanent errors to human review, and records structured events. **No actual email or SMS is sent.**

## Important verification status

Source code is provided. PHP files have been syntax-checked and 11 isolated reminder-policy checks passed, but Composer, Flutter and their dependencies were unavailable in the artifact-authoring environment; therefore the complete application was **not executed end-to-end there**. See `docs/EVIDENCE_INDEX.md` and `docs/ISSUES_AND_LIMITATIONS.md`. The newly revised white UI has not been independently compiled here. The earlier user-provided Chrome screenshot shows an API connectivity error in the old UI and is not proof that the new UI or backend works.

**Start here:** `RUN_WINDOWS_AND_PHONE.md` includes corrected Android Studio/Windows steps, API setup, and phone browser instructions. `docs/Week13_Submissions_0_to_6/` maps this project to the seven Drive reference categories without copying another student's evidence.

## Requirements

- Windows 11 with **PHP >=8.2**, **Composer**, `php.ini` extensions `pdo_sqlite`, `sqlite3`, `mbstring`, `fileinfo`, `openssl`, and `curl` as required by installed Laravel dependencies.
- **Flutter stable**, Chrome, and Git. Flutter 3.24+ with Dart 3.5+ is suitable for the supplied Dart syntax; use the installed stable SDK.
- Internet to run `composer install` and `flutter pub get` initially.
- Local ports **8000** (API) and **3000** (Flutter) must be available.

## Step 1 — Laravel backend (PowerShell, terminal 1)

```powershell
cd backend
composer install
Copy-Item .env.example .env
# Open .env and replace DEMO_ADMIN_PASSWORD=CHANGE_ME_LOCALLY
# with your own private, random password of at least 12 characters.
# Never push .env to GitHub.
php artisan key:generate
New-Item -ItemType File -Path database/database.sqlite -Force
php artisan migrate --seed
php artisan serve --host=127.0.0.1 --port=8000
```

Open `http://127.0.0.1:8000/api/health` and confirm `status: ok`. If migrations say the SQLite driver is missing, enable the `pdo_sqlite` and `sqlite3` extensions in your active `php.ini`, restart the terminal and try again.

## Step 2 — Flutter Web (PowerShell, terminal 2)

```powershell
cd frontend
flutter create . --platforms web
flutter pub get
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

If `flutter create` asks about rewriting files, preserve the supplied `lib/`, `test/` and `pubspec.yaml` files. The first command fills in platform scaffolding absent from a source-only project. Sign in using the `DEMO_ADMIN_EMAIL` and private `DEMO_ADMIN_PASSWORD` set in the local backend `.env`.

## Step 3 — Demonstrate the Week 13 workflow

1. Open **Equipment** → **Add equipment**. Use a unique asset tag, equipment name, category, and positive quantity.
2. Open **Borrowings** → **New borrowing**. Choose equipment, type a controlled `Demo User` name, and set a due date **within 48 hours**.
3. Open **Automation** → **Normal success** → **Run automation**. Check that a `reminder_completed` event appears.
4. Create another loan due soon. Select **Transient failure → retry → success**; run and verify attempt 1 failure, `retry_scheduled`, attempt 2 success.
5. Create a third loan due soon. Select **Permanent failure**; verify `needs_review` and `routed_for_review` event. In Borrowings, use **Reset reminder** only after review.
6. Use **Mark returned** to restore availability. Use **Log out** to revoke the current token.

A completed reminder is not retried in a subsequent run. To demonstrate each outcome, use separate new pending loans.

## Step 4 — Actual test commands

The isolated policy smoke test (which does not exercise Laravel HTTP or Flutter) can be rerun even without Composer:

```powershell
php backend/tests/Smoke/ReminderPolicySmoke.php
```



```powershell
# Terminal within backend (Laravel dependencies installed):
php artisan test
# Terminal within frontend (Flutter dependencies installed):
flutter test
```

Also perform and record manual scenarios from `docs/WEEK13_TEST_PLAN.md`. Capture **real screenshots** and **real event logs**. The project intentionally does not include invented runtime evidence.

## Folders

```text
backend/     Laravel API source, models, controllers, service, migrations, seeder, PHPUnit tests
frontend/    Flutter Web UI source and widget test
docs/        Design, User Manual, evidence index, test plan, screenshots and contribution note
```

## GitHub and submission

Create a new GitHub repository (or select your instructor-approved repository), then place this project's files at its root. **At minimum include `README.md`, `backend/`, `frontend/`, `docs/USER_MANUAL.md`, `docs/User_Manual.docx`, and manual screenshot files.** Keep `.env`, `vendor/`, compiled files, live tokens and private data out of Git. Make a real commit and record its exact hash in `docs/EVIDENCE_INDEX.md`.

Suggested commands from the project root after reviewing files:

```powershell
git init
git add .
git commit -m "Week 13 equipment reminder workflow and user manual"
git branch -M main
git remote add origin https://github.com/YOUR_ACCOUNT/YOUR_REPO.git
git push -u origin main
```

The remote URL above is a placeholder, not an existing project repository. **No GitHub push has been performed here**, because no target repository was specified or accessible. The course guide requires a verifiable repository commit/tag and evidence index.

## Acknowledgements and responsible use

Flutter, Dart, Laravel, Sanctum, SQLite, PHPUnit, and the relevant open-source libraries are used according to their respective licenses. This starter implementation and associated documentation were prepared with AI assistance, which must be acknowledged according to instructor policy. Verify, understand, secure, test, and defend every component personally before submission.

## Formal white UI revision and evidence

- The old dark-theme browser screenshot was supplied by the student and preserved under `docs/Week13_Submissions_0_to_6/04_Flutter_Screens/` as a **before-redesign API-unreachable capture**.
- Do not reuse the other student's Google Drive screenshots or submit reference illustrations as your own.
- User Manual screenshot slots are explicitly pending genuine screenshots taken after compiling and running the new build.
- Screenshots needed: login, desktop overview, collapsed sidebar, mobile navigation, equipment/add form, borrowing form, success/retry/permanent automation, return, and narrow-width validation.
- No GitHub upload or Google Drive submission was performed.
