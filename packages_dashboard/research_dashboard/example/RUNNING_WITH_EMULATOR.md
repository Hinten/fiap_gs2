# Running the Research Dashboard Example

This guide explains how to run the Research Dashboard Flutter example app with the Python API backend and Firebase emulator.

## Prerequisites

### 1. Install Required Tools

```bash
# Firebase Tools (required for emulator)
npm install -g firebase-tools@latest

# Python dependencies
cd ../../research_management
pip install -e ".[dev]"

# Flutter dependencies
cd ../../packages_dashboard/research_dashboard
flutter pub get
cd example
flutter pub get
```

### 2. Verify Flutter Setup

```bash
flutter doctor
flutter devices  # Check available devices
```

You should see at least one of:
- Chrome (web)
- Linux (desktop)
- Android emulator
- iOS simulator

## Running the Example

### Step 1: Start Firebase Emulator

Open a new terminal and start the Firebase emulator from the repository root:

```bash
cd /path/to/fiap_gs2

# Start Firestore emulator
firebase emulators:start --only firestore --project demo-test-project
```

You should see:
```
✔  All emulators ready! It is now safe to connect your app.

┌───────────┬────────────────┐
│ Emulator  │ Host:Port      │
├───────────┼────────────────┤
│ Firestore │ 127.0.0.1:8080 │
└───────────┴────────────────┘
```

**Keep this terminal running!**

### Step 2: Start Python API

Open another terminal and start the Python API:

```bash
cd packages/research_management

# Set environment variables to use emulator
export FIRESTORE_EMULATOR_HOST="localhost:8080"
export FIREBASE_PROJECT_ID="demo-test-project"

# Start the API
python -m research_management.main
```

You should see:
```
Research Management API started
API version: v1
Firebase project: demo-test-project
INFO:     Uvicorn running on http://0.0.0.0:8002 (Press CTRL+C to quit)
```

**Wait for the API to fully start (about 5-10 seconds)**

### Step 3: Verify API is Running

In a third terminal, test the API:

```bash
# Test health endpoint
curl http://localhost:8002/health
# Should return: {"status":"healthy"}

# Test root endpoint
curl http://localhost:8002/
# Should return: {"service":"Research Management API","version":"0.1.0","status":"running"}
```

### Step 4: Run Flutter Example

In a fourth terminal, run the Flutter app:

```bash
cd packages_dashboard/research_dashboard/example

# Run on Chrome (recommended for testing)
flutter run -d chrome

# Or run on Linux desktop
flutter run -d linux

# Or run on specific device
flutter run -d <device-id>
```

The app should launch and show the dashboard selector screen.

## Using the Dashboard

### 1. Configure API URL

On the main screen, verify the API URL is set to:
```
http://localhost:8002
```

### 2. Select Dashboard Type

Choose one of the three dashboards:

- **Coordinator Dashboard**: Overview of all projects and metrics
- **Advisor Dashboard**: Requires advisor ID (e.g., `advisor-001`)
- **Student Dashboard**: Requires student ID (e.g., `student-001`)

### 3. View Dashboard

The dashboard will fetch data from the Python API and display:
- Metrics cards
- Project lists
- Active alerts
- Health indicators

## Troubleshooting

### Connection Timeout Errors

If you see connection timeout errors:

1. **Check API is running**: 
   ```bash
   curl http://localhost:8002/health
   ```

2. **Check Firebase emulator is running**:
   ```bash
   curl http://localhost:8080
   ```

3. **Verify environment variables** (in API terminal):
   ```bash
   echo $FIRESTORE_EMULATOR_HOST
   # Should show: localhost:8080
   ```

4. **Wait longer after starting API**: The API needs 5-10 seconds to initialize Firebase connection

5. **Check firewall/port access**: Make sure ports 8002 and 8080 are not blocked

### Empty Dashboard

If the dashboard loads but shows no data:

1. The emulator starts with empty data by default
2. You can:
   - Create test data via the API
   - Use the Python example script to populate data
   - Import seed data

### API Not Found (404) Errors

If you get 404 errors:

1. Verify the API URL in the Flutter app
2. Check the API routes are registered:
   ```bash
   curl http://localhost:8002/docs
   ```
   This should show the API documentation

### Firebase Emulator Connection Issues

If Firebase connection fails:

1. **Restart emulator**:
   ```bash
   # Stop emulator (Ctrl+C)
   firebase emulators:start --only firestore --project demo-test-project
   ```

2. **Clear emulator data**:
   ```bash
   rm -rf ~/.config/firebase/emulators/
   firebase emulators:start --only firestore --project demo-test-project
   ```

3. **Check emulator logs**:
   Look for errors in the emulator terminal

## Running Integration Tests

To verify the connection between Flutter and Python API:

```bash
cd packages_dashboard/research_dashboard

# Make sure API and emulator are running first!

# Run integration tests
flutter test test/integration/api_integration_test.dart
```

Expected output:
```
✅ Health check endpoint should respond
✅ Root endpoint should respond
✅ Coordinator dashboard endpoint should respond
✅ Projects endpoint should respond
✅ Alerts endpoint should respond
```

## Quick Start Script

Create a file `start_dashboard.sh` in the example folder:

```bash
#!/bin/bash

echo "Starting Research Dashboard..."
echo ""
echo "Step 1/4: Starting Firebase emulator..."
firebase emulators:start --only firestore --project demo-test-project &
EMULATOR_PID=$!
sleep 5

echo ""
echo "Step 2/4: Starting Python API..."
cd ../../research_management
export FIRESTORE_EMULATOR_HOST="localhost:8080"
export FIREBASE_PROJECT_ID="demo-test-project"
python -m research_management.main &
API_PID=$!
sleep 10

echo ""
echo "Step 3/4: Waiting for services to be ready..."
until curl -s http://localhost:8002/health > /dev/null; do
    echo "Waiting for API..."
    sleep 2
done

echo ""
echo "Step 4/4: Launching Flutter app..."
cd ../../packages_dashboard/research_dashboard/example
flutter run -d chrome

# Cleanup on exit
echo ""
echo "Shutting down services..."
kill $API_PID
kill $EMULATOR_PID
```

Then run:
```bash
chmod +x start_dashboard.sh
./start_dashboard.sh
```

## Creating Test Data

To populate the dashboard with test data, use the Python example:

```bash
cd packages/research_management

# Make sure emulator is running
export FIRESTORE_EMULATOR_HOST="localhost:8080"
export FIREBASE_PROJECT_ID="demo-test-project"

# Run the example to create test data
python example.py
```

This will create:
- Sample projects
- Project members (students, advisors)
- Project updates
- Alerts

Then refresh your Flutter dashboard to see the data.

## Development Tips

1. **Hot Reload**: Use Flutter's hot reload (press 'r' in terminal) to quickly see UI changes

2. **DevTools**: Use Flutter DevTools for debugging:
   ```bash
   flutter run -d chrome --dart-define=FLUTTER_WEB_USE_SKIA=true
   ```

3. **API Documentation**: Visit http://localhost:8002/docs for interactive API documentation

4. **Emulator UI**: Enable Firebase Emulator UI for data inspection:
   ```json
   // In firebase.json
   {
     "emulators": {
       "ui": {
         "enabled": true,
         "port": 4000
       }
     }
   }
   ```
   Then visit: http://localhost:4000

## Common Environment Variables

### Python API
```bash
export FIRESTORE_EMULATOR_HOST="localhost:8080"
export FIREBASE_PROJECT_ID="demo-test-project"
export FIREBASE_AUTH_EMULATOR_HOST="localhost:9099"  # If using auth
```

### Flutter App
The app reads the API URL from the UI input field. No environment variables needed.

## Production Deployment

For production deployment:

1. **Don't use emulator**: Remove emulator environment variables
2. **Use real Firebase project**: Set up Firebase project credentials
3. **Update API URL**: Point to deployed API endpoint
4. **Enable CORS**: Configure CORS for your frontend domain
5. **Use HTTPS**: Ensure API uses HTTPS in production

## Support

If you encounter issues:

1. Check the [VISUAL_GUIDE.md](../VISUAL_GUIDE.md) for UI reference
2. Review [README.md](../README.md) for package documentation
3. Check Python API logs in the terminal
4. Check Flutter app console in DevTools

## Summary

**Minimum requirements to run the example:**

1. ✅ Firebase emulator running on port 8080
2. ✅ Python API running on port 8002 with emulator environment variables
3. ✅ Flutter app started and pointing to http://localhost:8002

**Startup sequence:**
1. Firebase emulator (wait 5 sec)
2. Python API (wait 10 sec)  
3. Verify API health check
4. Run Flutter app

**Testing connectivity:**
```bash
curl http://localhost:8080  # Emulator
curl http://localhost:8002/health  # API
flutter test test/integration/api_integration_test.dart  # Integration tests
```
