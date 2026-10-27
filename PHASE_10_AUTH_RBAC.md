# Phase 10 — Authentication and Role-Based Access Control (RBAC)

## 1. Objective
Implement secure authentication and role-based access control (RBAC) across the entire Face Recognition Attendance system. Authorization is strictly owned and enforced by the FastAPI Backend; frontend visual states are for user experience and are not security boundaries.

## 2. Password Security & Hashing
- **Algorithm**: Argon2id via `argon2-cffi`.
- Passwords are never stored in plaintext, never logged, and hashes are never exposed via client-facing schemas.
- Verified using constant-time verification functions to prevent timing attacks.
- The first administrator is provisioned once with `python -m app.bootstrap_admin` using `INITIAL_ADMIN_USERNAME` and `INITIAL_ADMIN_PASSWORD`; no default credentials are created.

## 3. JWT Authentication Strategy
- **Format**: Signed JSON Web Tokens (PyJWT) using HMAC-SHA256 (`HS256`).
- **Access Tokens**: Short-lived (default 60 minutes) carrying claims:
  - `sub`: User UUID string
  - `role`: Role designation (`ADMIN` or `USER`)
  - `username`: Institutional handle
  - `type`: `"access"`
  - `exp`: Expiration timestamp
- **Refresh Tokens**: Long-lived (default 7 days) carrying `type: "refresh"`. Cannot be used directly to access protected API resources; only exchanged via `POST /api/auth/refresh`.
- **CORS Configuration**: Configured with explicit origins (`ALLOWED_ORIGINS` in `config.py`), preventing arbitrary cross-origin request forgery.

## 4. Roles and Permissions Matrix

| Endpoint | Method | Permitted Roles | Description |
|---|---|---|---|
| `/api/auth/login` | POST | Public | Authenticates credentials, returns tokens |
| `/api/auth/me` | GET | `ADMIN`, `USER` | Retrieves current authenticated profile |
| `/api/auth/refresh` | POST | Public (with token) | Issues fresh access token |
| `/api/auth/logout` | POST | `ADMIN`, `USER` | Invalidation / audit log trigger |
| `/api/users/` | GET, POST | `ADMIN` | User management |
| `/api/users/{id}/*` | PATCH | `ADMIN` | Update roles or activate/deactivate users |
| `/api/students/register` | POST | `ADMIN` | Create student and enroll exactly five validated camera samples atomically |
| `/api/students/` | GET | `ADMIN`, `USER` | View student directory |
| `/api/students/{id}` | DELETE | `ADMIN` | Delete student, face samples, and attendance records |
| `/api/students/{id}/enroll` | POST | `ADMIN` | Add a camera-captured face sample |
| `/api/attendance/sessions` | POST | `ADMIN` | Create attendance sessions |
| `/api/attendance/sessions` | GET | `ADMIN`, `USER` | View attendance sessions |
| `/api/attendance/sessions/{id}/start` | POST | `ADMIN` | Activate session |
| `/api/attendance/sessions/{id}/stop` | POST | `ADMIN` | Complete session |
| `/api/attendance/recognize` | POST | `ADMIN`, `USER` | Submit live frame to mark attendance |
| `/api/attendance/reports` | GET | `ADMIN`, `USER` | View attendance summaries |

## 5. Security & Audit Logging
The backend logs security-critical events under logger `security.audit`:
- Successful and failed login attempts.
- Deactivated user access attempts.
- User creation and role modification.
- Biometric face enrollment actions with executing admin handle.
- Tokens, passwords, and raw biometric embeddings are explicitly excluded from logs.

## 6. Frontend Authentication
- Implemented `AuthProvider` and `useAuth()` in `src/context/AuthContext.tsx`.
- Centralized Axios request interceptor attaches `Authorization: Bearer <token>` automatically on all API calls.
- Unauthenticated requests are blocked and redirected to the `/login` route.
- Administrative controls (such as New Session, Register Student) are conditionally rendered based on `user.role === 'ADMIN'`, while backend authorization remains authoritative.
