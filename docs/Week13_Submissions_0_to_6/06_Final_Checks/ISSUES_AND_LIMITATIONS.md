# Week 13 Open Issues and Limitations

1. **Required setup on student's Windows computer:** Flutter SDK and Composer dependencies are not available in the authoring environment. Actual compile, browser, migrations, authentication and REST API integration tests are pending.
2. **Screenshot evidence:** new screenshots are still required for the formal white UI. The old dark-theme login screenshot shows an unreachable API and is documented as pre-redesign evidence only.
3. **GitHub repository:** no target repository URL was given. Source and User Manual are stored in the repository-ready ZIP, but no remote push has been performed.
4. **Simulated delivery:** demo-only; no borrower message is ever sent. This does not demonstrate production notification delivery.
5. **No deployment/security assurance:** limited to one local development instance; extra hardening is required before operational use.
6. **Known UI constraint:** in this initial week, the responsive drawer, scrolling tables and date picker still need on-device/manual review.
7. **Boundary testing:** 10 loan cap, concurrency guard and rollback behavior must be verified on the student's actual installed environment.
8. **User privacy:** use controlled names only; remove test secrets/tokens from logs and screenshots. Configure `.env` locally, never commit it.
