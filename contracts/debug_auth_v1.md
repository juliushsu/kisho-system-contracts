# Debug API Auth Contract v1

## REQUIRED AUTH SCHEME

Frontend MUST use:

- apikey: SUPABASE_ANON_KEY
- Authorization: Bearer <USER_ACCESS_TOKEN>

Example:

Authorization: Bearer ${session.access_token}

---

## TOKEN SOURCE

MUST come from:

supabase.auth.getSession()

---

## FORBIDDEN

- Using SUPABASE_ANON_KEY as Bearer token
- Hardcoding debug token in frontend
- Missing Authorization header
- Using expired session token

---

## ERROR HANDLING

If no session:

→ Show NOT_AUTHENTICATED
→ DO NOT call API

If 401:

→ Display exact error message
→ DO NOT retry silently
→ DO NOT fallback

---

## ENV RULES

- staging: allow viewer roles
- production: restrict to admin roles

---

## VERSION

v1.0 (2026-04-09)
