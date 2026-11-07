# Week 14 SA8/IA5 — test plan and screenshot evidence index

Record **actual results** and **exact local commit hash** before submission. Blank actual cells are intentional; no unseen test is claimed to pass.

## Mandatory command evidence (Android Studio PowerShell terminals)

From repository root:

```powershell
cd backend
php artisan config:clear
php artisan migrate:status
php .\vendor\phpunit\phpunit\phpunit --testdox
cd ..\frontend
flutter pub get
flutter analyze
flutter test --reporter expanded
```

The Week13 project uses a lightweight Laravel build; `php artisan test` may not be registered. Use the PHPUnit binary above. Record whether the runs actually pass.

## Real evidence capture matrix

| ID | Required evidence and exact filename | Expected result | Actual result (fill after run) |
|---|---|---|---|
| W14-01 | `01_role_migration.png` — `php artisan migrate:status` | New `add_role_to_users_table` migration Ran | NOT RUN |
| W14-02 | `02_security_phpunit_tests.png` — PHPUnit --testdox | Tests demonstrate 401, 403, 422, expiry, revocation, HTTPS-required and authorized paths; all pass | NOT RUN |
| W14-03 | `03_flutter_analyze_test.png` — Flutter analyze + test | No analysis errors and widget tests pass | NOT RUN |
| W14-04 | `04_custodian_secure_ui.png` — login then equipment/automation | Custodian can see secured operations | NOT RUN |
| W14-05 | `05_staff_role_ui.png` — staff navigation | Equipment and loans available; no automation/admin inventory button | NOT RUN |
| W14-06 | `06_student_limited_ui.png` — student navigation | Equipment/overview only; no borrower list | NOT RUN |
| W14-07 | `07_validation_error.png` — intentionally blank/invalid borrowing form | Validation message; no record created | NOT RUN |
| W14-08 | `08_session_unauthorized.png` — 401 behavior via test | Expired/altered token rejected | NOT RUN |
| W14-09 | `09_https_enforcement_test.png` — corresponding PHPUnit test | Plaintext request rejected when HTTPS gate enabled | NOT RUN |
| W14-10 | `10_git_secret_safety.png` — git checks | No `.env`, SQLite DB, keys in tracked changes | NOT RUN |
| W14-11 | `11_successful_loan_regression.png` — Week13 test run | Stock borrowing/return still passes | NOT RUN |
| W14-12 | `12_commit_and_remote.png` — git status and rev-parse | Week14 commit is present on existing `main` | NOT RUN |

Evidence count is not a course-mandated screenshot number; these are organized *recommended* filenames sufficient to cover the assignment. The instructor may request different organization.

## Safe secret check

Run from project root. Do NOT screenshot any real secret values returned by a broad grep. These commands show tracked *file paths*, not contents:

```powershell
git ls-files | Select-String '(^|/)\.env$|\.sqlite$|\.pem$|\.key$|\.p12$'
git status --short
git check-ignore backend/.env backend/database/database.sqlite
```

Expected: `git ls-files` lists no live sensitive files; `git check-ignore` confirms both paths ignored; inspect `git status` for unexpected additions. If sensitive files are tracked, stop, remove from the index with `git rm --cached <path>` (without deleting your local copy), and consider whether previously published credentials need rotation.

## Checkpoint procedure

1. Run `composer install` / `flutter pub get` if dependencies missing.
2. Set unique passwords in private `.env`; do not screen-record the values.
3. Run `php artisan migrate` (do not reset DB) then `php artisan db:seed` locally to assign custodian and optional role test accounts.
4. Run the real tests above; save raw output internally and crop only terminal commands and outcomes, not passwords.
5. Run the Chrome UI with Laravel and Flutter on their documented ports; test each role using only controlled demo accounts.
6. Check whether the API is HTTP-only. Do **not** claim HTTPS is active merely because the middleware test passed.
7. Complete this table, commit changes, record commit hash and verify GitHub content.
