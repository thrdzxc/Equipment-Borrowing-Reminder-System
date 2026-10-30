# Run on Windows — Android Studio, Flutter Web + Laravel API

**Project:** Equipment Borrowing Reminder System  
**Author:** Sales, Samuel Jr. C.  
**Important:** The white UI design was authored in source but has not been compiled here; build and verify it locally.

## A. Flutter Web — first terminal (Android Studio)

Open the **frontend** folder, which contains `pubspec.yaml` and `lib/main.dart`. Do not run Flutter commands from the parent `Equipment_Borrowing_Reminder_System` folder.

```powershell
flutter create . --platforms web
flutter pub get
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

If the app is already running in Chrome, stop Flutter with `q` in the terminal, then rerun this command to ensure the new white-theme source compiles. Chrome should open at http://localhost:3000.

## B. Laravel backend — second terminal

In a second PowerShell terminal, navigate to the `backend` folder (the sibling of `frontend`). Verify `php -v` and `composer --version` work and that PHP has `pdo_sqlite` enabled.

```powershell
composer install
Copy-Item .env.example .env
notepad .env
```

Set `DEMO_ADMIN_PASSWORD=` to a **new private password at least 12 characters long**. The example `CHANGE_ME_LOCALLY` will NOT be accepted by the seeder. Keep `DEMO_ADMIN_EMAIL` as your chosen local demo email. Never upload `.env`.

```powershell
php artisan key:generate
New-Item -ItemType File -Path database/database.sqlite -Force
php artisan migrate --seed
php artisan serve --host=127.0.0.1 --port=8000
```

**Do not run `New-Item` again if it would replace a populated database.** It is only needed for first-time initialization; it does not delete an existing file by default but review the file before rerunning migrations.

Open http://127.0.0.1:8000/api/health and confirm the response includes `status: ok`. This checks API reachability but not database tables or login. Then sign in on Chrome with the local `.env` email and private password.

## C. Test the Week 13 integration

From the backend directory after installing dependencies:

```powershell
php artisan migrate:status
php artisan test
```

From the frontend directory:

```powershell
flutter test
flutter analyze
```

Test Equipment → Add equipment, Borrowings → New borrowing, Automation → Normal success / Transient once / Permanent failure, then Mark returned. Save screenshots and actual logs. Do not state a test passed unless it really did.

## D. Phone browser (same Wi-Fi only, development preview)

The module requires Flutter **Web** (not APK). Test on a phone using the laptop's LAN IPv4 address instead of `127.0.0.1`:

1. Run `ipconfig` in Windows; identify laptop Wi-Fi IPv4 address.
2. In backend `.env`, set `FRONTEND_ORIGIN=http://YOUR_LAN_IP:3000` and keep the API development-only.
3. Start Laravel with `php artisan serve --host=0.0.0.0 --port=8000`.
4. Start Flutter Web with `flutter run -d chrome --web-hostname 0.0.0.0 --web-port 3000 --dart-define=API_BASE_URL=http://YOUR_LAN_IP:8000/api`.
5. From the phone on the **same private Wi-Fi**, open `http://YOUR_LAN_IP:3000`.
6. Check Windows Firewall rules and CORS if access is blocked. Never expose these dev servers to the public Internet. Local HTTP is suitable for isolated lab testing only.

Replace `YOUR_LAN_IP` with the real computer IP; that is a placeholder. Mobile browser screenshots must be captured from the running Flutter Web app.
