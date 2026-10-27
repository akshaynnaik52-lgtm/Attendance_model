# Phase 10 Checklist — Authentication & RBAC

- [x] Create/extend `User` model with `username`, `password_hash`, `role`, `status`, `created_at`, `last_login`
- [x] Implement secure Argon2id password hashing using `argon2-cffi`
- [x] Implement JWT access and refresh token utilities (`app/core/security.py`)
- [x] Define Auth endpoints (`/api/auth/login`, `/api/auth/me`, `/api/auth/refresh`, `/api/auth/logout`)
- [x] Create reusable RBAC dependencies (`get_current_user`, `require_admin`, `require_authenticated_user`)
- [x] Protect sensitive student management endpoints with `ADMIN` role requirement
- [x] Protect recognition and attendance routes with authentication requirement
- [x] Implement Admin User Management endpoints (`GET /api/users`, `POST /api/users`, `PATCH /api/users/{id}/role`, `PATCH /api/users/{id}/status`)
- [x] Configure backend CORS based on environment settings
- [x] Add security audit logging for logins, logouts, role changes, and enrollments
- [x] Update frontend with `AuthProvider`, `useAuth()`, route protection, and active user badge
- [x] Create complete automated test suite (`tests/test_auth_rbac.py`) verifying password hashing, login, token expiry, and role checks
- [x] Documented in `docs/PHASE_10_AUTH_RBAC.md` and `docs/PHASE_10_CHECKLIST.md`
