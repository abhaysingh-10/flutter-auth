# Full Production Authentication System
## Stack: Flutter + Django REST Framework
## Structure: Phases (Build one phase, test, then move to next)

---

# PHASE 1 — Django Setup + Custom User Model

## Goal
Get Django project running with a custom User model using UUID and email as login field.

## Packages to install:
pip install djangorestframework
pip install djangorestframework-simplejwt
pip install django-cors-headers
pip install python-decouple

## Custom User Model:
Fields needed:
- id → UUID (not integer)
- email → unique, used as username
- full_name
- profile_picture → url, nullable
- is_verified → boolean, default False
- auth_provider → choices: email, google, apple
- created_at → auto

## Important:
- Set AUTH_USER_MODEL in settings.py BEFORE any migrations
- Never change user model after first migration — will break everything
- Use email as USERNAME_FIELD
- Remove username field completely

## End of Phase 1 Check:
- Django runs without errors ✅
- Custom user model created ✅
- First migration done ✅
- Admin panel shows custom user ✅

---

# PHASE 2 — JWT Auth APIs (Email + Password)

## Goal
Build register, login, logout, refresh APIs using JWT.

## Packages to install:
pip install djangorestframework-simplejwt

## APIs to build:
POST /api/auth/register/   → full_name + email + password → create user
POST /api/auth/login/      → email + password → return access + refresh JWT
POST /api/auth/logout/     → blacklist refresh token
POST /api/auth/refresh/    → return new access token
GET  /api/auth/me/         → return logged in user details

## JWT Settings:
ACCESS_TOKEN_LIFETIME     = 15 minutes
REFRESH_TOKEN_LIFETIME    = 30 days
ROTATE_REFRESH_TOKENS     = True
BLACKLIST_AFTER_ROTATION  = True
AUTH_HEADER_TYPES         = Bearer

## Security:
- All secrets in .env file
- Never hardcode SECRET_KEY
- Token blacklisting on logout
- Refresh token rotation enabled

## End of Phase 2 Check:
- Register works ✅
- Login returns access + refresh token ✅
- Logout blacklists token ✅
- Refresh gives new token ✅
- Me endpoint returns user data ✅
- Test everything in Postman before moving on ✅

---

# PHASE 3 — Google Sign In (Backend)

## Goal
Django receives Google id_token from Flutter, verifies it with Google servers, creates or finds user, returns JWT.

## Packages to install:
pip install google-auth

## Flow:
Flutter sends id_token to Django
  → Django verifies id_token with Google servers
  → Extracts email, name, picture from token
  → If user exists → login → return JWT
  → If user does not exist → create user → return JWT

## API:
POST /api/auth/google/
Request body: { "id_token": "google_id_token_here" }
Response: { "access": "...", "refresh": "..." }

## Important:
- Verification MUST happen on Django backend
- Never trust what Flutter sends without verifying with Google
- Set auth_provider = google on user creation
- If email already exists with auth_provider = email → return error asking to login with password

## Environment variables needed:
GOOGLE_CLIENT_ID=your_google_client_id

## End of Phase 3 Check:
- Google token verified on backend ✅
- New user created on first Google login ✅
- Existing user logged in on second Google login ✅
- JWT returned correctly ✅
- Test with real token from Postman ✅

---

# PHASE 4 — Apple Sign In (Backend)

## Goal
Django receives Apple identity_token from Flutter, verifies it with Apple public keys, creates or finds user, returns JWT.

## Packages to install:
pip install PyJWT
pip install cryptography

## Flow:
Flutter sends identity_token to Django
  → Django fetches Apple public keys
  → Verifies identity_token using public keys
  → Extracts email, name
  → If user exists → login → return JWT
  → If user does not exist → create user → return JWT

## API:
POST /api/auth/apple/
Request body: { "identity_token": "apple_token_here", "full_name": "John Doe" }
Response: { "access": "...", "refresh": "..." }

## Important:
- Apple only sends name on FIRST sign in — save it immediately
- After first sign in Apple never sends name again
- Set auth_provider = apple on user creation
- Verification must happen server side using Apple public keys

## Environment variables needed:
APPLE_TEAM_ID=your_apple_team_id
APPLE_CLIENT_ID=your_apple_client_id
APPLE_KEY_ID=your_apple_key_id
APPLE_PRIVATE_KEY=your_apple_private_key

## End of Phase 4 Check:
- Apple token verified on backend ✅
- New user created on first Apple login ✅
- Name saved correctly on first login ✅
- Existing user logged in on second Apple login ✅
- JWT returned correctly ✅

---

# PHASE 5 — CORS + .env + Backend Final Cleanup

## Goal
Make backend ready for Flutter to connect. Clean up all settings.

## Packages to install:
pip install django-cors-headers

## CORS Settings:
CORS_ALLOWED_ORIGINS = [
    "http://localhost:8000",
    "http://127.0.0.1:8000",
]

## .env file (never push to GitHub):
SECRET_KEY=your_django_secret_key
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1
GOOGLE_CLIENT_ID=your_google_client_id
APPLE_TEAM_ID=your_apple_team_id
APPLE_CLIENT_ID=your_apple_client_id
APPLE_KEY_ID=your_apple_key_id
APPLE_PRIVATE_KEY=your_apple_private_key

## .gitignore must include:
.env
__pycache__/
*.pyc
db.sqlite3

## End of Phase 5 Check:
- .env working ✅
- No secrets hardcoded anywhere ✅
- CORS configured ✅
- All 7 APIs tested in Postman ✅
- Backend 100% ready for Flutter ✅

---

# PHASE 6 — Flutter Setup + Folder Structure

## Goal
Create Flutter project with clean production folder structure and install all packages.

## Packages to install (pubspec.yaml):
dio
flutter_secure_storage
google_sign_in
sign_in_with_apple
flutter_animate
shared_preferences
google_fonts

## Folder Structure:
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_colors.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   └── storage_service.dart
│   └── utils/
│       └── validators.dart
├── features/
│   └── auth/
│       ├── screens/
│       │   ├── splash_screen.dart
│       │   ├── login_screen.dart
│       │   ├── register_screen.dart
│       │   └── home_screen.dart
│       └── widgets/
│           ├── auth_button.dart
│           ├── auth_text_field.dart
│           ├── social_sign_in_button.dart
│           └── auth_divider.dart
└── main.dart

## api_constants.dart:
const String baseUrl = 'http://127.0.0.1:8000/api/';
const String loginUrl = 'auth/login/';
const String registerUrl = 'auth/register/';
const String logoutUrl = 'auth/logout/';
const String refreshUrl = 'auth/refresh/';
const String meUrl = 'auth/me/';
const String googleUrl = 'auth/google/';
const String appleUrl = 'auth/apple/';

## app_colors.dart:
Primary accent  → #6C63FF (deep purple)
Background      → #FFFFFF
Text primary    → #1A1A2E
Text secondary  → #6B7280
Error           → #EF4444
Success         → #10B981
Border          → #E5E7EB

## End of Phase 6 Check:
- Flutter project runs ✅
- Folder structure created ✅
- All packages installed ✅
- Constants files set up ✅

---

# PHASE 7 — Storage Service + API Service + Interceptor

## Goal
Build the core services layer that everything else depends on.

## storage_service.dart:
Wrapper around flutter_secure_storage
Functions needed:
- saveAccessToken(token)
- saveRefreshToken(token)
- getAccessToken()
- getRefreshToken()
- clearAll()
- saveRememberMe(bool)
- getRememberMe()

## api_service.dart:
Dio instance with:
- baseUrl from api_constants.dart
- Interceptor that attaches Bearer token to every request
- If 401 received → call refresh endpoint
- If refresh succeeds → retry original request silently
- If refresh fails → clearAll tokens → redirect to Login

## End of Phase 7 Check:
- Storage service saves and reads tokens correctly ✅
- Dio instance sends Bearer token automatically ✅
- Token refresh works silently on 401 ✅
- Failed refresh clears storage and redirects to login ✅

---

# PHASE 8 — Auth Service

## Goal
One file that contains all authentication logic.

## auth_service.dart functions:
- login(email, password) → calls API → saves tokens → returns bool
- register(fullName, email, password) → calls API → returns bool
- logout() → calls API → clears storage → returns bool
- googleLogin() → triggers Google Sign In → gets id_token → calls API → saves tokens → returns bool
- appleLogin() → triggers Apple Sign In → gets identity_token → calls API → saves tokens → returns bool
- isLoggedIn() → checks if access token exists → returns bool
- getCurrentUser() → calls /auth/me/ → returns user data

## End of Phase 8 Check:
- login() works ✅
- register() works ✅
- logout() clears everything ✅
- googleLogin() works end to end ✅
- appleLogin() works end to end ✅
- isLoggedIn() returns correct value ✅

---

# PHASE 9 — Splash Screen + Auto Login

## Goal
First screen user sees. Decides where to go based on token.

## Logic:
App opens → Splash Screen
  → wait 1.5 seconds (show logo with animation)
  → check StorageService.getAccessToken()
  → if token exists → navigate to Home Screen
  → if no token → navigate to Login Screen

## UI:
- White background
- App logo in center
- Subtle fade in animation on logo
- Tagline below logo with slight delay

## End of Phase 9 Check:
- Logo animates in smoothly ✅
- If logged in → goes to Home automatically ✅
- If not logged in → goes to Login ✅

---

# PHASE 10 — Login Screen UI + Logic

## Goal
Clean minimal login screen connected to backend.

## UI Elements:
- App logo at top (small)
- "Welcome back" heading
- Email TextField
- Password TextField (obscure + toggle visibility icon)
- Remember Me checkbox
- Login button (shows spinner during API call)
- "Forgot password?" link (placeholder)
- Divider "or continue with"
- Google Sign In button
- Apple Sign In button (show only on iOS)
- "Don't have an account? Register" link

## Animations:
- Fade in on screen load
- Slide up on form elements with slight delay
- Shake animation on wrong credentials

## Validation (before API call):
- Email: must be valid format
- Password: minimum 8 characters
- Show inline errors below each field

## Logic:
Login button pressed
  → validate form
  → show loading spinner
  → AuthService.login(email, password)
  → if success → navigate to Home
  → if fail → show error message → shake animation

## End of Phase 10 Check:
- UI looks clean and minimal ✅
- Animations work smoothly ✅
- Validation shows inline errors ✅
- Login works with real backend ✅
- Loading spinner shows during API call ✅
- Wrong password shows error + shake ✅
- Google Sign In works ✅
- Apple Sign In works on iOS ✅

---

# PHASE 11 — Register Screen UI + Logic

## Goal
Clean register screen connected to backend.

## UI Elements:
- "Create account" heading
- Full Name TextField
- Email TextField
- Password TextField (obscure + toggle)
- Confirm Password TextField
- Register button (shows spinner)
- Divider "or continue with"
- Google Sign In button
- Apple Sign In button (iOS only)
- "Already have an account? Login" link

## Validation (before API call):
- Full name: required, minimum 2 characters
- Email: valid format
- Password: minimum 8 characters
- Confirm password: must match password

## Logic:
Register button pressed
  → validate form
  → show loading spinner
  → AuthService.register(fullName, email, password)
  → if success → navigate to Login with success message
  → if fail → show error message

## End of Phase 11 Check:
- UI matches Login screen style ✅
- All validations work ✅
- Register works with real backend ✅
- Loading spinner works ✅
- Navigates to Login after success ✅

---

# PHASE 12 — Home Screen + Logout

## Goal
Post login landing screen. Shows user info and logout button.

## UI Elements:
- "Welcome, {full_name}" heading
- User email shown below
- Profile picture if available (from Google)
- Logout button

## Logic:
Screen loads
  → AuthService.getCurrentUser()
  → display name, email, picture

Logout pressed
  → AuthService.logout()
  → clears all tokens
  → navigate to Login Screen

## End of Phase 12 Check:
- User name and email show correctly ✅
- Google profile picture shows if available ✅
- Logout clears everything ✅
- After logout → goes to Login ✅
- Cannot go back to Home after logout ✅

---

# PHASE 13 — Final Testing + Polish

## Goal
Test every flow end to end. Fix any issues. Polish UI.

## Test every flow:
- Email register → login → home → logout ✅
- Google sign in → home → logout ✅
- Apple sign in → home → logout ✅
- Close app while logged in → reopen → goes to home directly ✅
- Wrong password → error shown ✅
- Empty fields → validation shown ✅
- Token expiry → refresh happens silently ✅
- Logout → token blacklisted on backend ✅

## UI Polish:
- Consistent spacing everywhere (24px horizontal padding)
- All buttons have loading states
- All errors shown clearly
- Animations feel smooth not jarring
- Keyboard dismisses properly
- No overflow errors on smaller screens

## Final Checks:
- Test on real iPhone (not simulator) ✅
- Test on Android emulator ✅
- No hardcoded secrets anywhere ✅
- .env not pushed to GitHub ✅
- All API calls handle errors gracefully ✅

---

# Big Picture — All 13 Phases

Phase 1  → Django setup + Custom User Model
Phase 2  → JWT Auth APIs (email + password)
Phase 3  → Google Sign In backend
Phase 4  → Apple Sign In backend
Phase 5  → CORS + .env + Backend cleanup
Phase 6  → Flutter setup + folder structure
Phase 7  → Storage + API service + interceptor
Phase 8  → Auth service (all functions)
Phase 9  → Splash screen + auto login
Phase 10 → Login screen UI + logic
Phase 11 → Register screen UI + logic
Phase 12 → Home screen + logout
Phase 13 → Final testing + polish

Build one phase → test completely → move to next.
Never skip a phase.
Never move to next phase if current phase has errors.