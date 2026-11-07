# Week 14 — Residual risks, limitations and individual contribution

## Residual-risk statement

1. **TLS not deployed by this package.** HTTP is allowed for local development. Hosted HTTPS enforcement blocks insecure access, but does not create a valid certificate, configure a trusted reverse proxy, or verify browser-to-server encryption. Risk remains until independently deployed and browser-tested over HTTPS.
2. **Bearer token is accessible to runtime JavaScript.** Keeping it only in memory avoids persistent storage but does not prevent theft by injected scripts or compromised dependencies. Future work: strong CSP, dependency audits, potentially cookie/CSRF session design.
3. **Role management is manual and bounded.** Only three server roles exist: `student`, `staff`, `custodian`. Demo seeder provisions roles locally. There is no administrative approval, user registration, user-management screen, or institutional identity integration.
4. **Incomplete project-wide workflow.** The Week 13 prototype is staff-operated and lacks student request/approval/release/inspection/closure as separate states. Role-based controls do not falsely imply these stages now exist; subsequent weeks must address scope in an instructor-approved way.
5. **SQLite/local concurrency and operational controls.** Local testing doesn't prove production safety, encrypted backups, incident response, monitoring retention or load capacity.
6. **Simulated reminders only.** No actual SMS/email is sent. Results are synthetic delivery outcomes from the Week 13 reminder simulation.
7. **Input validation is necessary but not sufficient.** Additional coverage is needed for payload limits, dependency vulnerabilities, CORS in target hosting, and rate-limit behavior under realistic request volume.
8. **Secure logging is based on minimal selected application fields.** Hosting/proxy/framework error logs may have different behavior; review them before deployment.

## Security choices and alternatives

- Framework hashing + Sanctum hashed tokens instead of inventing custom password/token cryptography.
- HTTPS transport instead of custom client-side encryption of generic API payloads; layered server authorization as primary enforcement.
- A least-privilege custodian/staff/student matrix instead of giving every logged-in account unrestricted admin permissions.
- Local seeded fictional accounts for evidence; do not collect real students' private data.

## Individual contribution record (complete truthfully after local verification)

**Student:** Sales, Samuel Jr. C.
**Section:** BSIT 3-B
**Project:** Equipment Borrowing Reminder System
**Assessment:** Week 14 — SA8 and IA5

| Date | Work actually performed by student | Evidence / commit | Verification result |
|---|---|---|---|
| To complete | Reviewed security requirements and changes | Source diff/document | Not independently confirmed |
| To complete | Ran role and adverse tests in local Windows environment | Screenshots W14-02, W14-08 | Not run here |
| To complete | Verified Flutter login/UI role navigation | Screenshots W14-03 to W14-07 | Not run here |
| To complete | Verified secrets excluded and pushed correct commit | W14-10 and W14-12 | Not run here |

**AI/external assistance disclosure:** Project code and documentation were prepared with AI assistance. The student must inspect, test, understand, adapt, and accurately represent the submitted work; no results or evidence were invented. Document third-party libraries from `composer.lock` / `pubspec.lock`.

## Final submission condition

Complete the evidence index with true outcomes, retain real screenshots, and record the repository URL and actual commit hash. Do not claim production readiness or a working HTTPS endpoint without deployment proof.
