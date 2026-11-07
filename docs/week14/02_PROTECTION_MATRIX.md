# Week 14 — Data-flow and protection-requirements matrix

| Asset / flow | Where stored or sent | Threat | Required protection | Control in code / verification |
|---|---|---|---|---|
| Local login password | Browser request -> Laravel only | Disclosure, guessing | TLS in hosted deployment; no log; hashing at rest; throttle | `AuthController`, Laravel Hash, login throttle, adverse login test |
| Bearer access token | Server-issued; browser memory; hashed server copy | Theft/replay/expiration | HTTPS; short expiry; revoke on logout; no persistent browser storage | Sanctum expiring token, `ApiClient`, expiry and logout tests |
| User role | Server database | Client-side privilege escalation | Trust server role only; least privilege | Role migration, `EnsureRole`, role matrix, 403 tests |
| Borrower name and due date | API -> SQLite; staff/custodian views | Unauthorized disclosure | Restricted endpoints, data minimization, validated fields | Borrowing route middleware, select projection, validation tests |
| Equipment stock | API -> SQLite | Invalid or unauthorized changes | Staff return/borrow, custodian inventory changes; DB transaction | Endpoint roles, validation, stock regression test |
| Automation control | API -> job simulation | Unauthorized run and repeated notifications | Custodian-only, throttle, bounded retries, local-only modes | `routes/api.php`, `ReminderRunner`, role tests |
| Events / audit | SQLite and Laravel logs | PII / secrets in logs | Minimal event fields, no credentials or borrower names | Event projection, structured run codes, log search |
| Server configuration | Untracked `.env` on local or host | Key exposure | Never commit; protected storage; placeholders in `.env.example` | `.gitignore`, git status and secret check evidence |
| Flutter compiled assets | Public web bundles | Compiled secret leakage | No runtime secrets in dart-define/assets | API URL only in define; secret-scan and bundle-review checklist |
| Network transport | Hosted browser <-> HTTPS API | Interception or downgrade | Valid cert, HTTPS-only, no mixed-content credentials | Secure middleware / HTTPS browser deployment evidence |

## Adverse cases to document from actual output

| Case | Expected | How to demonstrate |
|---|---|---|
| Wrong password | 401, generic message | PHPUnit `test_wrong_password...` / UI |
| No bearer token | 401 | PHPUnit `test_unauthenticated...` |
| Altered token | 401 | PHPUnit `test_invalid_and_altered...` |
| Expired bearer | 401 | PHPUnit `test_expired_token...` |
| Student tries equipment creation or borrower read | 403 | PHPUnit `test_student...` |
| Staff tries automation | 403 | PHPUnit `test_staff...` |
| Invalid borrower input | 422 and no stock change | PHPUnit `test_invalid_input...` |
| HTTP when HTTPS policy enabled | 403 `HTTPS_REQUIRED` | PHPUnit `test_https_requirement...` (not a live HTTPS session) |
| Successful protected workflow | Authorized 201/200 | Existing Week13 test and Week14 custodian test |
