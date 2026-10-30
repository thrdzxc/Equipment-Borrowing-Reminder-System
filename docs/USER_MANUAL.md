# Equipment Borrowing Reminder System — User Manual

**Sales, Samuel Jr. C. | BSIT 3-B**  
**UI:** Flutter Web (responsive)  
**Backend:** Laravel REST API + SQLite (local demo)  
**Delivery:** Reminder simulation only; no live SMS or emails are sent.

## 1. Access the system
Start the Laravel API and Flutter Web app using `RUN_WINDOWS_AND_PHONE.md`. Open `http://localhost:3000` in Chrome. The sign-in page uses white glass cards, the ULS logo, and subtle campus imagery. On phone, open the LAN URL described in the setup guide.

**Screenshot to insert:** `docs/screenshots/01_login_white_ui_actual.png` — must be captured from the NEW running UI.

## 2. Sign in
Enter the operator email and private password configured in the backend `.env` seeder; select **Sign in to system**. Incorrect or missing credentials show an error; an unreachable API shows network guidance. The API must be running for login to succeed.

**Screenshot:** `02_login_validation_actual.png`, `03_dashboard_actual.png`.

## 3. Navigation and sidebar
On desktop, select the double-arrow icon to collapse the sidebar to **icons only**, and use it again to expand labels. Select Overview, Equipment, Borrowings, Automation or User Guide. On a narrow phone screen, use the top menu button to open navigation as a drawer.

**Screenshot:** `04_sidebar_expanded_actual.png`, `05_sidebar_collapsed_actual.png`, `06_phone_menu_actual.png`.

## 4. Add equipment
Select Equipment → **Add equipment**. Enter a unique asset tag, descriptive equipment name, category, and quantity greater than zero, then choose Save equipment. Invalid data is rejected by the form and API.

**Screenshot:** `07_add_equipment_actual.png`, `08_equipment_validation_actual.png`.

## 5. Create a borrowing
Select Borrowings → **New borrowing**. Choose an available equipment item, enter a fictional borrower name for demonstrations, select the due date, then create the record. Available quantity decreases when the loan is accepted.

**Screenshot:** `09_new_borrowing_actual.png`, `10_borrowing_record_actual.png`.

## 6. Run reminder automation
Create a loan due within 48 hours, then open Automation. Choose a simulation scenario:

- Normal success: processing completes and an event is logged.
- Transient failure → retry → success: first attempt fails temporarily, a bounded retry is recorded, and a later attempt succeeds.
- Permanent failure → review: no automatic retries for a permanent condition; the loan is routed for human review.

Select **Run automation** and check the result counts and structured event log. Create a **new eligible borrowing** for each scenario so a completed record is not processed again.

**Screenshot:** `11_success_actual.png`, `12_retry_actual.png`, `13_permanent_review_actual.png`.

## 7. Review and return equipment
In Borrowings, use **Reset reminder** only for a loan already marked `needs_review`, following the responsible staff's review. Use **Mark returned** when equipment is physically returned and confirm inventory availability is restored.

**Screenshot:** `14_review_action_actual.png`, `15_return_actual.png`.

## 8. Responsive browser use
Test Chrome at full desktop width and narrow 375-pixel width (developer tools), then verify on a phone browser over the same private network. Forms must remain readable, the navigation must be accessible, and tables may scroll horizontally to preserve their columns.

**Screenshot:** `16_responsive_375_actual.png` and phone browser capture.

## 9. Logout
Select **Log out** in the sidebar. The server revokes the active token and returns to the sign-in page.

**Screenshot:** `17_logout_actual.png`.

## Evidence and safety
All screenshot names above are **capture instructions**, not existing files. The old user-supplied login screenshot documents an API connectivity problem in a previous dark-themed UI and is not proof of the revised design. Do not publish credentials, real borrower information, or invented screenshots. The source must be run on the user's laptop before the updated UI is treated as verified.
