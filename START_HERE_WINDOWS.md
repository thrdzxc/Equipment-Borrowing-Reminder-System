# START HERE — Windows 11

Equipment Borrowing Reminder System (Week 13)
Sales, Samuel Jr. C. | BSIT 3-B

## A. Open the Flutter project first

1. Extract this ZIP with **Extract All** (do not run Flutter from inside ZIP).
2. Open the extracted `Equipment_Borrowing_Reminder_System_Week13` folder. You should see `frontend`, `backend`, `docs`, `README.md`.
3. Open **Visual Studio Code**.
4. Select **File > Open Folder**, select the **frontend** folder, and click **Select Folder**.
5. Select **Terminal > New Terminal**.
6. Run the following commands in that terminal:

```powershell
flutter doctor
flutter create . --platforms web
flutter pub get
flutter devices
```

7. Run Flutter in Chrome on port 3000:

```powershell
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

The branded login screen should open in Chrome. **Sign-in cannot succeed until the Laravel API below is running.**

If `flutter` is not recognized, ensure Flutter SDK's `bin` folder is in PATH; check e.g. `C:\develop\flutter\bin` and restart VS Code. Do not run `flutter create equipment_borrowing...` again — the supplied project already exists.

## B. Start the Laravel API, SQLite database, and demo user

1. Open a **second** VS Code window or terminal in the `backend` folder. Ensure PHP 8.2+, Composer, SQLite PDO extension are installed; on Windows you can test `php -v` and `composer --version`.
2. From `backend` folder run:

```powershell
composer install
Copy-Item .env.example .env
notepad .env
```

3. In `.env`, replace `DEMO_ADMIN_PASSWORD=CHANGE_ME_LOCALLY` with **your own new password containing at least 12 characters**, save, close. Keep `.env` private.
4. Execute:

```powershell
php artisan key:generate
php artisan migrate --seed
php artisan serve --host=127.0.0.1 --port=8000
```

5. Open `http://127.0.0.1:8000/api/health` in Chrome; it should respond with a JSON health status. If `pdo_sqlite` is missing, enable `pdo_sqlite` and `sqlite3` in the active PHP `php.ini`.
6. Sign into Flutter using `admin@example.test` and the private password you just set.

The included `backend/database/database.sqlite` is an **empty SQLite file**, not a database with migrated tables. `php artisan migrate --seed` builds the tables and demo data.

## C. Phone test comes after local PC test

The phone and laptop must be on the same Wi-Fi. You must use the laptop's LAN IPv4 address instead of `127.0.0.1` in both the Flutter URL and API base URL; start both servers on `0.0.0.0` and configure the allowed CORS origin in Laravel. See `README.md` for local requirements. Do not expose this demo API to the public internet or use real personal records.

## D. Evidence & GitHub

After testing, capture **actual application screenshots** for dashboard, equipment, borrowing, reminder success/retry/permanent failure, logs, and mobile layout. The existing `docs/` images are **illustrations, not actual runtime screenshots**. Replace screenshots in the final User Manual with real captures. Commit the User Manual and code in your own GitHub repository and record the actual commit/tag in the evidence index.

## E. Technical verification note

The layout code and project files are supplied, but Flutter and Composer were not available in the authoring environment to verify a complete Flutter/Laravel build. Verify on your Windows setup; do not label it production-ready before the full checks pass.
