# Firebase Authentication - Quick Start Guide

## 🚀 Quick Start

### Backend (Python Microservice)

```bash
# 1. Install package
cd packages/auth_service
pip install -e ".[dev]"

# 2. Set environment variables
export FIREBASE_PROJECT_ID="your-project-id"
export FIREBASE_SERVICE_ACCOUNT_BASE64="<base64_encoded_json>"

# 3. Use in your FastAPI app
```

```python
from fastapi import FastAPI, Depends
from auth_service import init_firebase_admin, verify_firebase_token, AuthUser

app = FastAPI()

@app.on_event("startup")
async def startup():
    init_firebase_admin()

@app.get("/api/protected")
async def protected(user: AuthUser = Depends(verify_firebase_token)):
    return {"user": user.email}
```

### Frontend (Flutter App)

```bash
# 1. Add to pubspec.yaml
cd packages_dashboard/firebase_auth
flutter pub get
```

```yaml
dependencies:
  firebase_auth:
    path: ../firebase_auth
```

```dart
// 2. Initialize Firebase
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FirebaseService().initialize(
    config: FirebaseConfig(
      apiKey: 'YOUR_API_KEY',
      authDomain: 'your-project.firebaseapp.com',
      projectId: 'your-project',
      storageBucket: 'your-project.appspot.com',
      messagingSenderId: '123456789',
      appId: '1:123456789:web:abcdef',
    ),
  );
  
  runApp(ProviderScope(child: MyApp()));
}

// 3. Use AuthWrapper
class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthWrapper(
        child: HomeScreen(),
        signedOutBuilder: (context) => LoginScreen(),
      ),
    );
  }
}
```

## 📦 What's Included

### Backend Package: `auth_service`
- ✅ Firebase Admin SDK integration
- ✅ FastAPI middleware for token verification
- ✅ RBAC (Role-Based Access Control)
- ✅ Tenant/multi-org support
- ✅ Custom claims management
- ✅ User management utilities

### Frontend Package: `firebase_auth`
- ✅ Firebase Flutter SDK integration
- ✅ Email/password, Google, custom token auth
- ✅ Automatic token management
- ✅ Dio HTTP interceptor
- ✅ Riverpod state management
- ✅ Auth wrapper widgets
- ✅ Role & tenant guards

## 🔑 Environment Setup

### Get Firebase Service Account

```bash
# 1. Go to Firebase Console
# 2. Project Settings → Service Accounts
# 3. Generate New Private Key
# 4. Download JSON file

# 5. Encode for environment variable
base64 -i service-account.json | tr -d '\n' > service-account-base64.txt
```

### Backend Environment Variables

```bash
# Required
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_SERVICE_ACCOUNT_BASE64=<paste_base64_here>

# Optional
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
```

### Frontend Configuration

```dart
// Option 1: Direct values (dev only)
final config = FirebaseConfig(
  apiKey: 'AIzaSy...',
  authDomain: 'project.firebaseapp.com',
  projectId: 'project-id',
  // ...
);

// Option 2: Environment variables (recommended)
final config = FirebaseConfig(
  apiKey: const String.fromEnvironment('FIREBASE_API_KEY'),
  authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
  // ...
);
```

## 🎯 Common Use Cases

### Protected API Endpoint

```python
@app.get("/api/admin/users")
async def list_users(user: AuthUser = Depends(require_role("admin"))):
    return {"users": [...]}
```

### Role-Based UI

```dart
class AdminPanel extends StatelessWidget {
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRole: 'admin',
      child: AdminContent(),
    );
  }
}
```

### API Calls with Auth

```dart
// Automatically adds Authorization header
final dio = createAuthenticatedDio(
  authService: authService,
  baseUrl: 'https://api.example.com',
);

final response = await dio.get('/api/protected');
```

### Custom Claims

```python
# Backend: Set custom claims
from auth_service import set_custom_claims

set_custom_claims("user123", {
    "role": "admin",
    "tenant_id": "fiap-school-1"
})
```

```dart
// Frontend: Check custom claims
final user = await authService.currentUser;
if (user?.hasRole('admin') ?? false) {
  // Show admin features
}
```

## 🔐 Security Checklist

- [ ] Never commit service account keys
- [ ] Use Secret Manager in production
- [ ] Enable Firebase App Check
- [ ] Configure CORS properly
- [ ] Use HTTPS for all endpoints
- [ ] Implement rate limiting
- [ ] Log authentication events
- [ ] Validate custom claims
- [ ] Set up IAM roles correctly
- [ ] Regularly update dependencies

## 📚 Documentation

- **Integration Guide**: `docs/firebase-auth-integration.md` (13KB)
- **Implementation Summary**: `docs/firebase-auth-implementation-summary.md` (10KB)
- **Backend README**: `packages/auth_service/README.md` (8KB)
- **Frontend README**: `packages_dashboard/firebase_auth/README.md` (9KB)

## 🧪 Testing

```bash
# Backend tests
cd packages/auth_service
pytest --cov=src

# Frontend tests
cd packages_dashboard/firebase_auth
flutter test
```

## 🆘 Troubleshooting

### "Firebase Admin not initialized"
→ Call `init_firebase_admin()` in startup event

### "Invalid service account JSON"
→ Verify JSON is valid: `python -m json.tool service-account.json`

### "401 Unauthorized"
→ Check token is in Authorization header: `Bearer <token>`

### "Permission Denied" (Vertex AI)
→ Verify service account has `roles/aiplatform.user`

## 🔗 Quick Links

- [Firebase Console](https://console.firebase.google.com/)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Firebase Auth Docs](https://firebase.google.com/docs/auth)
- [Vertex AI Docs](https://cloud.google.com/vertex-ai/docs)

## 📞 Support

For detailed information, see the comprehensive documentation in `docs/` directory.
