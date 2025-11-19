import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/alert_cluster.dart';
import '../models/wellbeing_checkin.dart';
import 'package:flutter/material.dart';

import '../models/alert_cluster.dart';
import '../services/wellbeing_monitoring_service.dart';

/// Dashboard for viewing aggregated wellbeing alerts.
///
/// Displays only anonymized cluster-level data without identifying
/// individual students, ensuring LGPD/GDPR compliance.
class EarlyAlertDashboard extends StatefulWidget {
  /// The monitoring service providing alert data.
  final WellbeingMonitoringService service;

  const EarlyAlertDashboard({
    required this.service,
    super.key,
  });

  @override
  State<EarlyAlertDashboard> createState() => _EarlyAlertDashboardState();
}

class _EarlyAlertDashboardState extends State<EarlyAlertDashboard> {
  List<AlertCluster> _alerts = [];
  List<WellbeingCheckin> _recentCheckins = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _loadAlerts();
    _subscribeToAlerts();
  }

  void _loadAlerts() {
    setState(() {
      _alerts = widget.service.getActiveAlerts();
    });
  }

  void _subscribeToAlerts() {
    widget.service.alertsStream.listen((alerts) {
      if (mounted) {
        setState(() {
          _alerts = alerts;
        });
      }
    });

    widget.service.checkinsStream.listen((checkins) {
      if (mounted) {
        setState(() {
          // Get last 14 days of check-ins for trend chart
          final cutoff = DateTime.now().subtract(const Duration(days: 14));
          _recentCheckins =
              checkins.where((c) => c.timestamp.isAfter(cutoff)).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildPrivacyNotice(),
            const SizedBox(height: 24),
            if (_recentCheckins.isNotEmpty) ...[
              _buildTrendChart(),
              const SizedBox(height: 24),
            ],
            _buildAlertsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange[700],
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Early Alert Dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${_alerts.length} active alert${_alerts.length != 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: 'Refresh alerts',
        ),
      ],
    );
  }

  Widget _buildPrivacyNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.privacy_tip_outlined, color: Colors.green[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Protected',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'All data shown is anonymized and aggregated. Individual '
                  'students cannot be identified from these alerts. Alerts '
                  'represent patterns in anonymous clusters only.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, size: 20),
              const SizedBox(width: 8),
              Text(
                'Wellbeing Trends (Last 14 Days)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildLineChart(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(Colors.blue, 'Mood'),
              _buildLegendItem(Colors.orange, 'Stress'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    // Group check-ins by day and calculate averages
    final Map<DateTime, List<WellbeingCheckin>> checkinsByDay = {};
    for (final checkin in _recentCheckins) {
      final day = DateTime(
        checkin.timestamp.year,
        checkin.timestamp.month,
        checkin.timestamp.day,
      );
      checkinsByDay.putIfAbsent(day, () => []).add(checkin);
    }

    // Calculate daily averages
    final moodSpots = <FlSpot>[];
    final stressSpots = <FlSpot>[];
    final sortedDays = checkinsByDay.keys.toList()..sort();

    for (int i = 0; i < sortedDays.length; i++) {
      final day = sortedDays[i];
      final dayCheckins = checkinsByDay[day]!;

      final avgMood =
          dayCheckins.map((c) => c.moodLevel).reduce((a, b) => a + b) /
              dayCheckins.length;
      final avgStress =
          dayCheckins.map((c) => c.stressLevel).reduce((a, b) => a + b) /
              dayCheckins.length;

      moodSpots.add(FlSpot(i.toDouble(), avgMood));
      stressSpots.add(FlSpot(i.toDouble(), avgStress));
    }

    if (moodSpots.isEmpty) {
      return const Center(
        child: Text(
          'No data to display',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= sortedDays.length) return const Text('');
                final day = sortedDays[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${day.month}/${day.day}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        minX: 0,
        maxX: (sortedDays.length - 1).toDouble(),
        minY: 1,
        maxY: 5,
        lineBarsData: [
          // Mood line
          LineChartBarData(
            spots: moodSpots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
          // Stress line
          LineChartBarData(
            spots: stressSpots,
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.orange,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final day = sortedDays[spot.x.toInt()];
                final label = spot.barIndex == 0 ? 'Mood' : 'Stress';
                return LineTooltipItem(
                  '$label: ${spot.y.toStringAsFixed(1)}\n${day.month}/${day.day}',
                  TextStyle(
                    color: spot.barIndex == 0 ? Colors.blue : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAlertsList() {
    if (_alerts.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: _alerts.map((alert) => _buildAlertCard(alert)).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.green[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Alerts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'All wellbeing indicators are within normal ranges',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(AlertCluster alert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildSeverityBadge(alert.severity),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.clusterName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatAlertType(alert.alertType),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatTimestamp(alert.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert.description,
              style: const TextStyle(fontSize: 14),
            ),
            if (alert.percentageChange != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    alert.percentageChange! < 0
                        ? Icons.trending_down
                        : Icons.trending_up,
                    size: 16,
                    color: alert.percentageChange! < 0 ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Trend: ${alert.percentageChange!.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: alert.percentageChange! < 0
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.group_outlined, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Cluster size: ${alert.clusterSize} (anonymous)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (alert.recommendations.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Recommended Actions:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              ...alert.recommendations.map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Text(
                          rec,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(AlertSeverity severity) {
    Color color;
    String label;
    IconData icon;

    switch (severity) {
      case AlertSeverity.high:
        color = Colors.red;
        label = 'HIGH';
        icon = Icons.error;
      case AlertSeverity.medium:
        color = Colors.orange;
        label = 'MEDIUM';
        icon = Icons.warning;
      case AlertSeverity.low:
        color = Colors.blue;
        label = 'LOW';
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAlertType(AlertType type) {
    switch (type) {
      case AlertType.stressIncrease:
        return 'Stress Increase';
      case AlertType.lowMood:
        return 'Low Mood Pattern';
      case AlertType.generalConcern:
        return 'General Concern';
      case AlertType.decliningTrend:
        return 'Declining Trend';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
