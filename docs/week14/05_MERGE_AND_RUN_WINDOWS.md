# Week 14 — Merge into existing GitHub project and run on Windows

**Do not create a second repository. Do not delete the Week 13 `.git` directory or local SQLite database.**

## Step 1 — Safely merge source

1. Extract `EquipTrack_Week14_Secure_Integration.zip` to a temporary folder in Downloads. The extracted top level contains `backend`, `frontend`, `docs`, and README files.
2. In File Explorer, open your existing Git-connected project folder:
   `D:\Downloads\Equipment_Borrowing_Reminder_System\Equipment_Borrowing_Reminder_System_Week13`
3. Copy **backend, frontend, docs and README** from the extracted package into that existing folder and select **Replace files in destination** for matching source files. Do not delete the destination folder or initialize Git again.
4. This new ZIP intentionally omits `.git`, `backend/.env`, and `backend/database/database.sqlite`; those originals must remain in your existing Windows folder and must NOT be committed.
5. You can make a local backup first: copy the original folder to an offline directory; make sure the backup is not uploaded to GitHub.

## Step 2 — Configure local controlled demo accounts

Use Android Studio terminal in the existing project's `backend` directory:

```powershell
cd "D:\Downloads\Equipment_Borrowing_Reminder_System\Equipment_Borrowing_Reminder_System_Week13\backend"
composer install
# Keep your existing private .env file! If missing, copy .env.example to .env.
php artisan config:clear
php artisan migrate
php artisan migrate:status
```

In your **private** `backend/.env` (do not share it), set unique 12+ character values for:

- `DEMO_ADMIN_EMAIL` / `DEMO_ADMIN_PASSWORD` — existing demo operator becomes `custodian` when seeded.
- `DEMO_STAFF_EMAIL` / `DEMO_STAFF_PASSWORD` — optional safe fictional staff account.
- `DEMO_STUDENT_EMAIL` / `DEMO_STUDENT_PASSWORD` — optional safe fictional student account.
- `FRONTEND_ORIGIN=http://localhost:3000`, `TOKEN_TTL_MINUTES=60`, `SECURE_REQUIRE_HTTPS=false` for local HTTP only.

**Never type these private passwords in chat, screenshots, Git commands, or committed documentation.** The placeholders in `.env.example` are intentionally unusable; optional seeding requires changing them.

Then run:

```powershell
php artisan db:seed
php artisan serve --host=127.0.0.1 --port=8000
```

If you already have a local database with borrowing records, **do not** run `migrate:fresh` or delete the SQLite file. The new migration simply adds the `users.role` column and keeps previous records.

## Step 3 — Start Flutter (second terminal)

```powershell
cd "D:\Downloads\Equipment_Borrowing_Reminder_System\Equipment_Borrowing_Reminder_System_Week13\frontend"
flutter pub get
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

Log in using your locally configured custodian credentials. Confirm Borrowings, Equipment, Automation, and User Guide still work. Log out and log in with staff/student if configured; verify the restricted menu in each role. Server routes independently block forbidden operations.

## Step 4 — Execute tests (third terminal)

```powershell
cd "D:\Downloads\Equipment_Borrowing_Reminder_System\Equipment_Borrowing_Reminder_System_Week13\backend"
php .\vendor\phpunit\phpunit\phpunit --testdox
cd ..\frontend
flutter analyze
flutter test --reporter expanded
```

If tests fail, record real errors and fix them; do not present expected results as actual. Use `docs/week14/03_TEST_PLAN_AND_EVIDENCE_INDEX.md` for suggested screenshots.

## Step 5 — HTTPS configuration for an approved hosted environment

The local demo runs HTTP and is intentionally NOT evidence of encrypted transport. For hosting:
- Use a valid HTTPS certificate at an HTTPS-enabled reverse proxy/server and redirect browser HTTP to HTTPS.
- Trust only known proxy IPs for the Laravel forwarded protocol; do not trust arbitrary client `X-Forwarded-Proto` headers.
- Use `APP_ENV=production`, `APP_DEBUG=false`, `APP_URL=https://your-domain`, and `FRONTEND_ORIGIN=https://your-frontend-domain` in private host configuration.
- Build Flutter with `--dart-define=API_BASE_URL=https://your-api-domain/api` (the URL itself is public; never put a key/token in dart-define).
- Never change `SECURE_REQUIRE_HTTPS` to bypass HTTPS in staging/production; middleware always requires secure transport in those environments.
- Verify TLS and redirects from a real browser, then independently test 401, 403, validation, CORS, expiration, and logs.

## Step 6 — Review and push to the existing repository

From the *existing* project root:

```powershell
cd "D:\Downloads\Equipment_Borrowing_Reminder_System\Equipment_Borrowing_Reminder_System_Week13"
git remote -v
git status --short
git ls-files | Select-String '(^|/)\.env$|\.sqlite$|\.pem$|\.key$|\.p12$'
git check-ignore backend/.env backend/database/database.sqlite
# DO NOT continue if git ls-files showed live secrets or database files.
git add backend frontend docs README.md .gitignore
git diff --cached --stat
git diff --cached --check
git commit -m "Week 14: Secure integration, RBAC and adverse tests"
git push origin main
git rev-parse --short HEAD
```

Check that `origin` belongs to **thrdzxc/Equipment-Borrowing-Reminder-System** before pushing, and that Git uses your intended commit author. If a merge conflicts with work changed since the uploaded ZIP, resolve it instead of force-pushing. Open the repository in a browser to verify the changed files appear.
