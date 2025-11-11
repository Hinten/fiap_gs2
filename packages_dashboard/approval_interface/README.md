# Approval Interface

A generic, reusable Flutter package for managing approval workflows. This package provides a comprehensive solution for displaying, filtering, and managing items that require approval, such as code reviews, grading, awards, content, and more.

## Features

✨ **Generic & Reusable**: Works with any type of approval workflow
🎨 **Material Design 3**: Modern UI with light/dark theme support
📊 **Real-time Statistics**: Dashboard with visual metrics
🔍 **Advanced Filtering**: Filter by type, priority, and status
✅ **Bulk Operations**: Approve multiple items at once
📱 **Responsive**: Works on mobile, web, and desktop
🧪 **Fully Tested**: Comprehensive test coverage
🎯 **Type-safe**: Built with strong typing and null safety

## Installation

Add this package as a dependency in your `pubspec.yaml`:

```yaml
dependencies:
  approval_interface:
    path: ../approval_interface  # For monorepo setup
  
  # Or from pub.dev (once published)
  # approval_interface: ^0.1.0
  
  # Required peer dependencies
  flutter_riverpod: ^2.4.0
  dio: ^5.3.3
  intl: ^0.18.1
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Wrap your app with ProviderScope

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:approval_interface/approval_interface.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 2. Use the ApprovalDashboardScreen

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Approval Interface Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ApprovalDashboardScreen(),
    );
  }
}
```

### 3. Configure API Base URL

Set the base URL for your backend API:

```bash
flutter run --dart-define=API_BASE_URL=https://your-api.example.com
```

Or programmatically override the provider:

```dart
void main() {
  runApp(
    ProviderScope(
      overrides: [
        approvalServiceProvider.overrideWith((ref) => ApprovalService(
          baseUrl: 'https://your-api.example.com',
        )),
      ],
      child: const MyApp(),
    ),
  );
}
```

## Usage

### Using Individual Components

You can use individual widgets from the package:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:approval_interface/approval_interface.dart';

class CustomApprovalScreen extends ConsumerWidget {
  const CustomApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approvals')),
      body: const ApprovalList(
        enableSelection: true,
        showActions: true,
      ),
    );
  }
}
```

### Creating Custom Approval Items

```dart
final item = ApprovalItem(
  id: 'unique-id',
  type: ApprovalType.codeReview,
  title: 'Pull Request #123',
  description: 'Add new authentication feature',
  priority: ApprovalPriority.high,
  status: ApprovalStatus.pending,
  createdAt: DateTime.now(),
  assignedTo: 'user@example.com',
  content: {
    'pr_number': 123,
    'files_changed': 15,
  },
);
```

### Programmatic Operations

```dart
// Approve an item
await ref.read(approvalProvider.notifier).approveItem(
  'item-id',
  comment: 'Looks good!',
);

// Reject an item
await ref.read(approvalProvider.notifier).rejectItem(
  'item-id',
  reason: 'Needs more tests',
);

// Bulk approve
final results = await ref.read(approvalProvider.notifier).bulkApprove(
  ['id1', 'id2', 'id3'],
);
```

## Backend API Requirements

Your backend API should implement these endpoints:

### GET /api/v1/approvals/pending
Returns a list of pending approval items.

**Query Parameters:**
- `type`: Filter by approval type
- `priority`: Filter by priority
- `status`: Filter by status
- `assigned_to`: Filter by assigned user

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "item-1",
      "type": "codeReview",
      "title": "Pull Request #123",
      "description": "Add feature X",
      "priority": "high",
      "status": "pending",
      "created_at": "2024-11-11T10:00:00Z",
      "assigned_to": "user@example.com"
    }
  ]
}
```

### POST /api/v1/approvals/{id}/approve
Approves an item.

**Body:**
```json
{
  "comment": "Optional approval comment"
}
```

### POST /api/v1/approvals/{id}/reject
Rejects an item.

**Body:**
```json
{
  "reason": "Required rejection reason"
}
```

### POST /api/v1/approvals/bulk-approve
Bulk approves multiple items.

**Body:**
```json
{
  "item_ids": ["id1", "id2", "id3"]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "results": {
      "id1": true,
      "id2": true,
      "id3": false
    }
  }
}
```

See the [roadmap.md](roadmap.md) for complete API specification.

## Architecture

### Models
- **ApprovalItem**: Core data model for approval items
- **ApprovalType**: Enum for item types (codeReview, grading, award, content, issue)
- **ApprovalPriority**: Enum for priority levels (critical, high, normal, low)
- **ApprovalStatus**: Enum for item status (pending, inReview, approved, rejected)

### Services
- **ApprovalService**: Handles all API communications

### Providers (Riverpod)
- **approvalServiceProvider**: Provides configured service instance
- **approvalProvider**: State management for approval items
- **selectedItemsProvider**: Manages bulk selection state

### Widgets
- **ApprovalCard**: Displays individual approval item
- **ApprovalList**: Displays list of items with refresh and error handling
- **ApprovalDashboardScreen**: Full-featured dashboard with statistics and filters

## Testing

### Run All Tests

```bash
flutter test
```

### Run with Coverage

```bash
flutter test --coverage
lcov --list coverage/lcov.info
```

### Run Specific Tests

```bash
# Model tests
flutter test test/models/

# Widget tests
flutter test test/widgets/
```

## Example App

A complete example app is included in the `example/` directory. It demonstrates:

- Using mock data for offline testing
- All package features and components
- Custom styling and theming
- Integration patterns

To run the example:

```bash
cd example
flutter pub get
flutter run -d chrome
```

See the [example/README.md](example/README.md) for more details.

## Development

### Code Analysis

```bash
# Analyze code
flutter analyze

# Format code
flutter format .
```

### Project Structure

```
lib/
├── src/
│   ├── models/              # Data models
│   │   └── approval_item.dart
│   ├── services/            # API services
│   │   └── approval_service.dart
│   ├── providers/           # Riverpod providers
│   │   └── approval_provider.dart
│   ├── widgets/             # Reusable widgets
│   │   ├── approval_card.dart
│   │   └── approval_list.dart
│   └── screens/             # Screen widgets
│       └── approval_dashboard_screen.dart
└── approval_interface.dart  # Main export file

test/
├── models/                  # Model tests
├── services/                # Service tests
└── widgets/                 # Widget tests

example/
└── lib/
    ├── main.dart           # Example app
    └── mock_data.dart      # Mock data generator
```

## Contributing

This package is part of the FIAP AI-Enhanced Learning Platform monorepo. Follow the project's coding standards:

- Use Dart's official style guide
- Maintain test coverage above 80%
- Document all public APIs
- Use meaningful commit messages

## License

Part of FIAP Global Solution 2025.2 project.

## Support

For issues, questions, or contributions, please refer to the main repository or open an issue on GitHub.
