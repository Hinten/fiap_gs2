import 'package:flutter/material.dart';
import 'package:student_wellbeing/student_wellbeing.dart';

/// Example app demonstrating the student wellbeing monitoring package.
///
/// This example shows:
/// - WellbeingCheckinWidget for student input
/// - EarlyAlertDashboard for viewing alerts
/// - In-memory service setup
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the wellbeing monitoring service
  final service = WellbeingMonitoringService(
    retentionDays: 30,
    alertWindowDays: 7,
    stressThreshold: 4.0,
    scoreThreshold: 40.0,
  );

  await service.initialize();

  runApp(StudentWellbeingExampleApp(service: service));
}

/// Main application widget.
class StudentWellbeingExampleApp extends StatelessWidget {
  final WellbeingMonitoringService service;

  const StudentWellbeingExampleApp({
    required this.service,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Wellbeing Monitor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: WellbeingHomePage(service: service),
    );
  }
}

/// Home page with tabs for check-in and dashboard.
class WellbeingHomePage extends StatefulWidget {
  final WellbeingMonitoringService service;

  const WellbeingHomePage({
    required this.service,
    super.key,
  });

  @override
  State<WellbeingHomePage> createState() => _WellbeingHomePageState();
}

class _WellbeingHomePageState extends State<WellbeingHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Wellbeing Monitor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete all data',
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildCheckinTab(),
          _buildDashboardTab(),
          _buildStatsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Check-In',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_amber_outlined),
            selectedIcon: Icon(Icons.warning_amber),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Statistics',
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          WellbeingCheckinWidget(
            service: widget.service,
            studentId: 'example-student-123',
            onCheckinRecorded: () {
              // Optionally switch to alerts tab after check-in
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Check-in recorded! View alerts tab.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildInfoCard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          EarlyAlertDashboard(service: widget.service),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return StreamBuilder<List<WellbeingCheckin>>(
      stream: widget.service.checkinsStream,
      initialData: const [],
      builder: (context, snapshot) {
        final checkins = snapshot.data ?? [];
        final totalCheckins = checkins.length;
        final avgMood = checkins.isEmpty
            ? 0.0
            : checkins.map((c) => c.moodLevel).reduce((a, b) => a + b) /
                totalCheckins;
        final avgStress = checkins.isEmpty
            ? 0.0
            : checkins.map((c) => c.stressLevel).reduce((a, b) => a + b) /
                totalCheckins;
        final consentRate = checkins.isEmpty
            ? 0.0
            : checkins.where((c) => c.consentToShare).length /
                totalCheckins *
                100;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Wellbeing Statistics',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildStatCard(
                  'Total Check-Ins',
                  totalCheckins.toString(),
                  Icons.fact_check,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  'Average Mood',
                  avgMood.toStringAsFixed(1),
                  Icons.mood,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  'Average Stress',
                  avgStress.toStringAsFixed(1),
                  Icons.trending_up,
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  'Consent Rate',
                  '${consentRate.toStringAsFixed(0)}%',
                  Icons.security,
                  Colors.purple,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.amber.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 32),
            const SizedBox(height: 8),
            Text(
              'Example App',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This is a demonstration of the student wellbeing monitoring '
              'package. Your check-ins are stored locally and can be deleted '
              'at any time using the delete button above.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'Are you sure you want to delete all stored wellbeing data? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.service.deleteAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    widget.service.dispose();
    super.dispose();
  }
}
