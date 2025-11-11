# Firebase Auth Emulator - Tests and Examples

This document provides instructions for running Firebase Auth Emulator tests and examples for both Python and Flutter packages.

## Prerequisites

### 1. Install Firebase Tools

```bash
npm install -g firebase-tools@latest
```

### 2. Install Dependencies

#### Python (auth_service)
```bash
cd packages/auth_service
pip install -e ".[dev]"
```

#### Flutter (dashboard_auth)
```bash
cd packages_dashboard/dashboard_auth
flutter pub get

# For the example app
cd example
flutter pub get
```

## Starting the Firebase Emulator

The Firebase Auth Emulator must be running before executing any tests or examples.

### Start Emulator

From the repository root:

```bash
firebase emulators:start --only auth --project demo-test-project
```

You should see output like:
```
✔  All emulators ready! It is now safe to connect your app.

┌────────────────┬────────────────┐
│ Emulator       │ Host:Port      │
├────────────────┼────────────────┤
│ Authentication │ 127.0.0.1:9099 │
└────────────────┴────────────────┘
```

Keep this terminal running while you run tests/examples in another terminal.

## Running Python Tests (auth_service)

### Run All Emulator Tests

```bash
cd packages/auth_service
FIREBASE_AUTH_EMULATOR_HOST="localhost:9099" pytest tests/test_auth_emulator.py -v
```

### Expected Output

```
tests/test_auth_emulator.py::TestFirebaseAuthEmulator::test_create_user PASSED
tests/test_auth_emulator.py::TestFirebaseAuthEmulator::test_get_user_by_email PASSED
tests/test_auth_emulator.py::TestFirebaseAuthEmulator::test_update_user PASSED
tests/test_auth_emulator.py::TestFirebaseAuthEmulator::test_delete_user PASSED
tests/test_auth_emulator.py::TestFirebaseAuthEmulator::test_create_custom_token PASSED
tests/test_auth_emulator.py::TestFirebaseAuthEmulator::test_set_custom_user_claims PASSED
tests/test_auth_emulator.py::TestFirebaseAuthEmulator::test_list_users PASSED
tests/test_auth_emulator.py::TestFirebaseAuthEmulator::test_verify_custom_token_fails_with_invalid_token PASSED

================================================== 8 passed in 0.24s ==================================================
```

### Run Python Example

```bash
cd packages/auth_service
FIREBASE_AUTH_EMULATOR_HOST="localhost:9099" python example/firebase_emulator_example.py
```

### Expected Output

The example will:
1. Create a new user
2. Retrieve user by UID and email
3. Update user information
4. Set custom claims (role, tenant_id, permissions)
5. Create a custom token
6. Disable and re-enable the user
7. List all users
8. Delete the user

```
======================================================================
Firebase Auth Emulator - Example Application
======================================================================
✅ Firebase Admin SDK initialized for emulator

📝 Creating a new user...
✅ User created successfully!
   UID: sucgVfVHdtvIMXBh4GpoOAaSt0oX
   Email: demo@example.com
   Display Name: Demo User

[... additional output ...]

======================================================================
✅ All examples completed successfully!
======================================================================
```

## Running Flutter Tests (dashboard_auth)

### Run All Emulator Tests

```bash
cd packages_dashboard/dashboard_auth
flutter test test/auth_emulator_test.dart
```

### Expected Tests

The Flutter tests validate:
- Firebase initialization with emulator
- User registration with email/password
- User sign in with email/password
- Invalid credentials handling
- User management (get current user, update display name)
- Email verification
- Token retrieval (ID token and token result)
- Password reset
- AuthUserModel operations

### Test Groups

1. **FirebaseInitService**: Validates emulator initialization
2. **User Creation and Authentication**: Registration, sign in, sign out
3. **User Management**: Profile updates, token retrieval
4. **AuthUserModel**: Model operations, role checking, JSON serialization
5. **Password Reset**: Password reset email functionality

## Running Flutter Example App

The Flutter example provides a visual interface to interact with Firebase Auth Emulator.

### Run Example

```bash
cd packages_dashboard/dashboard_auth/example

# For web
flutter run -d chrome

# For desktop (if available)
flutter run -d linux   # or macos, windows

# For mobile (if emulator/device is connected)
flutter run
```

### Example Features

The example app includes:

1. **Emulator Status Display**: Shows connection to localhost:9099
2. **Current User Card**: Displays authenticated user information
3. **Authentication Form**: 
   - Email and password inputs
   - Optional display name
   - Register button
   - Sign in button
   - Sign out button
   - Get token button
4. **Status Panel**: Shows operation results and errors

### Using the Example

1. **Register a New User**:
   - Enter email (e.g., `test@example.com`)
   - Enter password (e.g., `password123`)
   - Optionally enter display name
   - Click "Register"
   - User info will appear in "Current User" section

2. **Sign In**:
   - Enter existing email and password
   - Click "Sign In"
   - User info will be displayed

3. **Get Token**:
   - While signed in, click "Get Token"
   - ID token will be displayed in status

4. **Sign Out**:
   - Click "Sign Out"
   - Current user section will show "Not signed in"

## Test Coverage

### Python Tests (`test_auth_emulator.py`)

- ✅ Create user with email/password
- ✅ Get user by UID
- ✅ Get user by email
- ✅ Update user information
- ✅ Delete user
- ✅ Create custom token
- ✅ Set custom user claims (roles, tenant)
- ✅ List users
- ✅ Verify invalid token fails

### Flutter Tests (`auth_emulator_test.dart`)

- ✅ Firebase initialization for emulator
- ✅ Create user with email/password and display name
- ✅ Sign in with email/password
- ✅ Invalid credentials error handling
- ✅ Check if user is signed in
- ✅ Get current user
- ✅ Update display name
- ✅ Send email verification
- ✅ Get ID token
- ✅ Get ID token result with claims
- ✅ Sign out user
- ✅ AuthUserModel role checking
- ✅ AuthUserModel JSON serialization
- ✅ Send password reset email

## Troubleshooting

### Emulator Not Running

**Error**: Connection refused or timeout

**Solution**: Make sure the emulator is running in another terminal:
```bash
firebase emulators:start --only auth --project demo-test-project
```

### Port Already in Use

**Error**: Port 9099 is already in use

**Solution**: Either stop the process using port 9099 or change the port in `firebase.json`

### Python Tests Fail with Import Error

**Error**: `ModuleNotFoundError: No module named 'auth_service'`

**Solution**: Install the package in editable mode:
```bash
cd packages/auth_service
pip install -e ".[dev]"
```

### Flutter Tests Fail to Run

**Error**: Flutter SDK not found or dependencies not installed

**Solution**: 
```bash
# Install Flutter SDK first
# Then install dependencies
cd packages_dashboard/dashboard_auth
flutter pub get
```

### Firebase Network Errors in CI

If running in CI environments with restricted network access, the emulator UI download may fail. This is handled by disabling the UI in `firebase.json`:

```json
{
  "emulators": {
    "auth": {
      "port": 9099
    },
    "ui": {
      "enabled": false
    }
  }
}
```

## Environment Variables

### Python

- `FIREBASE_AUTH_EMULATOR_HOST`: Set to `localhost:9099` to use emulator
- `FIREBASE_PROJECT_ID`: Project ID (set to `demo-test-project` for emulator)

### Flutter

The Flutter package uses `FirebaseInitService.initializeWithEmulator()` which automatically configures the emulator connection programmatically.

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Firebase Emulator Tests

on: [push, pull_request]

jobs:
  test-python:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install Firebase Tools
        run: npm install -g firebase-tools@latest
      
      - name: Install Python Dependencies
        run: |
          cd packages/auth_service
          pip install -e ".[dev]"
      
      - name: Start Firebase Emulator
        run: |
          firebase emulators:start --only auth --project demo-test-project &
          sleep 15
      
      - name: Run Python Tests
        run: |
          cd packages/auth_service
          FIREBASE_AUTH_EMULATOR_HOST="localhost:9099" pytest tests/test_auth_emulator.py -v

  test-flutter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install Firebase Tools
        run: npm install -g firebase-tools@latest
      
      - name: Get Flutter Dependencies
        run: |
          cd packages_dashboard/dashboard_auth
          flutter pub get
      
      - name: Start Firebase Emulator
        run: |
          firebase emulators:start --only auth --project demo-test-project &
          sleep 15
      
      - name: Run Flutter Tests
        run: |
          cd packages_dashboard/dashboard_auth
          flutter test test/auth_emulator_test.dart
```

## Additional Resources

- [Firebase Emulator Suite Documentation](https://firebase.google.com/docs/emulator-suite)
- [Firebase Auth Emulator](https://firebase.google.com/docs/emulator-suite/connect_auth)
- [Firebase Admin Python SDK](https://firebase.google.com/docs/admin/setup)
- [FlutterFire Documentation](https://firebase.flutter.dev/)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the Firebase Emulator logs
3. Open an issue in the repository
