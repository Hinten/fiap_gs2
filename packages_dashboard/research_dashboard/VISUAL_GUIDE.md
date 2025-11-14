# Flutter Dashboard Implementation - Visual Guide

## Overview

Complete Flutter dashboard implementation for Research Management System with three main views: Coordinator, Advisor, and Student dashboards.

## Dashboard Selector Screen

The main screen allows users to select which dashboard to view and configure the API URL:

**Features**:
- API URL configuration (default: http://localhost:8002)
- Three dashboard options with descriptions
- Material Design 3 cards with icons
- Instructions for API setup

**Components**:
- Configuration card with TextField for API URL
- Three dashboard selection cards:
  - 🔵 Coordinator Dashboard (Blue)
  - 🟢 Advisor Dashboard (Green)
  - 🟠 Student Dashboard (Orange)
- Info card with setup instructions

## Coordinator Dashboard

**Visual Elements**:
1. **Metrics Grid** (2x2):
   - Total Projects card (blue icon, shows total and active count)
   - Completion Rate card (green icon, percentage display)
   - Projects in Risk card (orange icon, shows critical count)
   - Students per Advisor card (purple icon, average ratio)

2. **Warning Cards**:
   - Red alert card for students without advisor
   - Shows count and "Action needed" message

3. **Alerts Section**:
   - Header with active alerts count
   - List of alert cards with:
     - Emoji indicator (🟢🟡🔴)
     - Alert type as title
     - Message description
     - Time stamp ("há X dias/horas")
     - Action menu (Resolve/Dismiss)

**Color Scheme**:
- Blue: Primary metrics
- Green: Positive indicators
- Orange: Warnings
- Red: Critical alerts
- Purple: Team metrics

## Advisor Dashboard

**Visual Elements**:
1. **Metrics Grid** (2x2):
   - Total Projects (blue)
   - Active Projects (green)
   - Total Students (purple)
   - Active Alerts (orange/grey based on count)

2. **Project List**:
   - Header "Lista de Projetos"
   - Project cards with:
     - Project title
     - Health emoji (🟢🟡🔴)
     - Description (truncated)
     - Three chips:
       * Research area (blue chip)
       * Status (color-coded chip)
       * Health status (color-coded chip)
   - Tap to view details

**Empty State**:
- Inbox icon (grey)
- "Nenhum projeto encontrado" message

## Student Dashboard

**Visual Elements**:
1. **Project Card** (elevated, highlighted):
   - Large project title
   - Health emoji (32pt, top-right)
   - Divider
   - Information rows with icons:
     - 🗂️ Area
     - 🚩 Status
     - 🏥 Health Status
     - 👤 Advisor Status (✅ or ⚠️)
     - 📅 Expected Deadline

2. **Alert Card** (if applicable):
   - Orange background
   - Warning icon
   - Alert count and message
   - Arrow to view details

3. **Quick Actions**:
   - Two buttons side by side:
     - "Submeter Atualização" (filled button)
     - "Ver Timeline" (outlined button)

**Empty State** (no project):
- Folder-off icon (large, grey)
- "Nenhum projeto ativo encontrado" message
- Help text to contact coordination

## Reusable Widgets

### MetricCard
- Card with elevation
- Icon in colored circle (with opacity background)
- Title (grey text)
- Large value (colored, bold)
- Optional subtitle (grey text)

### AlertCard
- List tile format
- Severity emoji leading
- Type as title (bold)
- Message as subtitle
- Timestamp in small grey text
- Popup menu with actions (if active)

### ProjectCard
- Card with InkWell
- Title row with health emoji
- Description (max 2 lines)
- Chips row:
  - Area chip (blue)
  - Status chip (status-colored)
  - Health chip (health-colored)

## Color Coding

**Status Colors**:
- Active: Green
- Completed: Blue
- Paused: Orange
- Archived: Grey
- Proposal: Purple

**Health Status**:
- On Track: Green (🟢)
- At Risk: Orange (🟡)
- Critical: Red (🔴)

**Severity**:
- Info: Green (🟢)
- Warning: Orange (🟡)
- Critical: Red (🔴)

## Interactions

**Pull to Refresh**:
- All dashboards support pull-to-refresh
- Invalidates providers and reloads data

**Error Handling**:
- Red error icon
- Error message display
- "Tentar Novamente" button

**Loading States**:
- Circular progress indicator centered

## Responsive Design

- Metrics use GridView with:
  - 2 columns
  - 16px spacing
  - 1.5-1.8 aspect ratio
- Cards have consistent 16px padding
- Proper spacing between sections (24px)

## API Integration

All dashboards connect to:
- Base URL: `http://localhost:8002`
- Endpoints:
  - `/api/v1/dashboard/coordinator`
  - `/api/v1/dashboard/advisor?advisor_id={id}`
  - `/api/v1/dashboard/student?student_id={id}`
  - `/api/v1/projects`
  - `/api/v1/alerts`

## Testing

Run the example:
```bash
cd packages_dashboard/research_dashboard/example
flutter pub get
flutter run -d chrome
```

Ensure Python API is running:
```bash
cd packages/research_management
python -m research_management.main
```

## Summary

The Flutter dashboard provides:
✅ Three complete dashboard views
✅ Real-time data visualization
✅ Material Design 3 theming
✅ Responsive layouts
✅ Error handling and loading states
✅ Pull-to-refresh functionality
✅ Reusable widget library
✅ Example application for testing

All dashboards are ready for production use with the Python API backend.
