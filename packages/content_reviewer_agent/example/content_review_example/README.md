# Content Review Example App

A Flutter web/mobile application demonstrating the Content Reviewer Agent API integration.

## Features

- **Full Review**: Run all four agents simultaneously
- **Error Detection**: Check for spelling, grammar, and syntax errors
- **Comprehension Analysis**: Analyze readability and suggest simplifications
- **Source Verification**: Verify citations and sources
- **Content Update**: Detect outdated or deprecated content

## Architecture

The app follows a clean architecture pattern:

```
lib/
├── models/           # Data models matching API responses
├── services/         # API client service
├── screens/          # Main UI screens
└── widgets/          # Reusable UI components
```

## Running the App

### Prerequisites

1. Start the Content Reviewer Agent API:

```bash
cd ../../  # Go to content_reviewer_agent package root
pip install -e ".[dev]"
python -m content_reviewer_agent.main
```

The API will run on `http://localhost:8000`

2. Install Flutter dependencies:

```bash
flutter pub get
```

### Run on Web

```bash
flutter run -d chrome
```

### Run on Mobile

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Usage

1. **Enter Content**: The app comes pre-loaded with sample content demonstrating various issues
2. **Select Review Type**: Choose which type of review to perform
3. **Configure API URL**: Default is `http://localhost:8000`, change if needed
4. **Click Review**: Press the "Review Content" button
5. **View Results**: See issues categorized by severity with suggested fixes

## UI Components

### Review Summary Card

Displays:
- Overall quality score
- Issue counts by severity
- Recommendations
- Review metadata

### Review Issue Card

Shows for each issue:
- Issue type and severity badge
- Description
- Location in content
- Original problematic text
- Suggested fix
- Confidence score
- Reference sources

## API Integration

The app communicates with the Content Reviewer Agent API using:

- **Dio**: HTTP client for making API requests
- **Riverpod**: State management for service injection
- **Custom Models**: Dart classes mirroring Python Pydantic models

## Testing

```bash
# Run unit and widget tests
flutter test

# Run with coverage
flutter test --coverage
```

## Technologies

- **Flutter**: Cross-platform UI framework
- **Riverpod**: State management
- **Dio**: HTTP client
- **Material 3**: Design system

## License

Part of FIAP Global Solution 2025.2 project.
