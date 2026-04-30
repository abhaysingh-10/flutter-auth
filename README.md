# Auth: Flutter + Django Production-Ready System

This isn't just another basic login app. It's a full-stack, industry-standard authentication system designed with smooth animations and production-grade security logic. 

We built this to handle the "real world" stuff: secure token storage, automatic refreshing, email verification, and a flexible login (Email or Username).

##  What's inside?

### The Backend (Django REST Framework)
*   **Custom User Model:** Uses UUIDs instead of simple IDs for better security.
*   **Dual-Login Logic:** Users can log in using either their **Email** or **Username**. No more "email only" restrictions.
*   **JWT Auth:** Implemented using `simplejwt`. It handles access tokens, refresh tokens, and blacklisting on logout.
*   **OTP System:** A built-in engine that generates 6-digit verification codes for new accounts.

### The Frontend (Flutter)
*   **Smooth UI:** Entrance and transition animations using `flutter_animate`.
*   **Smart Navigation:** The app knows exactly where to send you. Signup -> OTP Verify -> Home Screen.
*   **Riverpod State:** Solid state management to keep the UI in sync with the user's auth status.
*   **Production Interceptor:** A background Dio interceptor that automatically attaches tokens to requests and retries them if they expire.

## Setup & Run

### 1. Start the Backend
```bash
cd backend
source venv/bin/activate
python manage.py migrate
python manage.py runserver
```
*Note: Check the terminal for the OTP code when you sign up!*

### 2. Start the App
```bash
flutter run
```

---

## Real Talk: Issues We Faced & Fixed

Development isn't always smooth. Here are the "gotchas" i solved during this build:

1.  **The "Port 8000" Trap:** i kept hitting 404 errors because a different Django project was running on the same port. **Fix:** Use `kill -9` on the ghost process or run on a different port.
2.  **Field Mismatch (400 Bad Request):** Django was strictly looking for an `email` field, but Flutter was sending an `identifier`. **Fix:** Overrode the JWT Serializer to accept a generic `username` field for both email/user.
3.  **Riverpod 3.0 Surprise:** A new version of Riverpod broke our `StateNotifier`. **Fix:** Downgraded to the stable **2.6.1** to keep the architecture reliable.
4.  **The "Me" Endpoint 404:** Absolute paths vs Relative paths in Flutter imports almost cost us our sanity. **Fix:** Standardized imports and verified the Django URL patterns.

---

## Next Steps for Production
*   [ ] **Connect SMTP:** Add your Gmail App Password to `settings.py` to send real emails.
*   [ ] **Social Keys:** Add your Google/Apple Client IDs to the `AuthNotifier`.
*   [ ] **Forgot Password:** Implement the reset flow (frontend and backend already have the folders ready).

**Built with ☕ and persistence.**
