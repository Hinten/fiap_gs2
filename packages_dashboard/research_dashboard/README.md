# Research Dashboard

Flutter package for Research Management System dashboards - visualizing scientific initiation coordination data.

## Features

- **Coordinator Dashboard**: Overview of all projects, metrics, and alerts
- **Advisor Dashboard**: Projects and students management view  
- **Student Dashboard**: Personal project status and progress tracking
- **Real-time Metrics**: Visualize completion rates, health indicators, and alerts
- **API Integration**: Communicates with Python FastAPI backend

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  research_dashboard:
    path: ../research_dashboard
```

## Usage

### 1. Configure the API Service

```dart
import 'package:research_dashboard/research_dashboard.dart';

final service = ResearchManagementService(
  baseUrl: 'http://localhost:8002',  // Your API URL
);
```

### 2. Use Dashboard Screens

#### Coordinator Dashboard

```dart
import 'package:research_dashboard/research_dashboard.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CoordinatorDashboardScreen(),
    );
  }
}
```

## Example

See the `example` folder for a complete working demo:

```bash
cd example
flutter pub get
flutter run -d chrome
```

## License

Part of FIAP Global Solution 2025.2 project - Educational purposes.
