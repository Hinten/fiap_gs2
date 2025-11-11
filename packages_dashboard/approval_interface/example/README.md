# Approval Interface Example

This example demonstrates how to use the `approval_interface` package in a Flutter application.

## Features Demonstrated

- ✅ Display list of pending approval items
- ✅ Approve and reject items with feedback
- ✅ Filter items by type and priority
- ✅ Bulk approval operations
- ✅ Real-time statistics
- ✅ Responsive Material Design 3 UI
- ✅ Mock data for testing without backend

## Running the Example

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher

### Steps

1. Navigate to the example directory:

```bash
cd example
```

2. Get dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
# Run on Chrome (web)
flutter run -d chrome

# Run on connected device
flutter devices
flutter run -d <device-id>
```

## Using Mock Data

By default, the example uses mock data to demonstrate the package functionality without requiring a backend API. This is controlled by the cloud icon in the app bar:

- ☁️ Off (default): Uses generated mock data
- ☁️ On: Attempts to connect to real API (requires configuration)

## Connecting to Real API

To connect to a real backend API, configure the base URL:

```bash
flutter run --dart-define=API_BASE_URL=https://your-api.example.com
```

The API should implement the following endpoints:

- `GET /api/v1/approvals/pending` - List pending items
- `GET /api/v1/approvals/{id}` - Get specific item
- `POST /api/v1/approvals/{id}/approve` - Approve item
- `POST /api/v1/approvals/{id}/reject` - Reject item
- `PUT /api/v1/approvals/{id}/edit` - Edit item
- `POST /api/v1/approvals/bulk-approve` - Bulk approve
- `GET /api/v1/approvals/history` - Get history

## Project Structure

```
example/
├── lib/
│   ├── main.dart           # Main app entry point
│   └── mock_data.dart      # Mock data generator
├── pubspec.yaml            # Dependencies
└── README.md               # This file
```

## Code Overview

### Main App (main.dart)

The main file sets up the Flutter app with Material Design 3 theming and integrates the approval interface:

```dart
import 'package:approval_interface/approval_interface.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        home: ApprovalDashboardScreen(),
      ),
    ),
  );
}
```

### Mock Data (mock_data.dart)

Generates realistic approval items for demonstration:

```dart
final mockItems = MockData.generateMockApprovalItems();
```

## Customization

You can customize various aspects of the approval interface:

### Custom Approval Service

```dart
// Override the approval service provider with custom configuration
final customServiceProvider = Provider<ApprovalService>((ref) {
  return ApprovalService(
    baseUrl: 'https://your-api.com',
    dio: customDioInstance,
    logger: customLogger,
  );
});
```

### Custom Styling

The package uses Material Design 3 and respects your app's theme:

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
    useMaterial3: true,
  ),
  home: ApprovalDashboardScreen(),
);
```

## Features to Explore

1. **Dashboard**: View all pending approvals with statistics
2. **Filters**: Filter by type (code review, grading, etc.) and priority
3. **Bulk Actions**: Select multiple items and approve them at once
4. **Individual Actions**: Approve or reject items with comments
5. **Responsive Design**: Works on web, mobile, and desktop
6. **Dark Mode**: Automatically supports light and dark themes

## Next Steps

- Integrate with your backend API
- Customize the UI to match your brand
- Add authentication and authorization
- Implement notifications for new approvals
- Add detailed item views with editing capabilities

## Support

For issues or questions, please refer to the main package README or open an issue on GitHub.
