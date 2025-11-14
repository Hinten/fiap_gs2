import 'package:flutter/material.dart';
import '../models/alert.dart';

/// Alert card widget for displaying alerts
class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback? onResolve;
  final VoidCallback? onDismiss;

  const AlertCard({
    super.key,
    required this.alert,
    this.onResolve,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: ListTile(
        leading: Text(
          alert.severity.emoji,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          alert.type.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(alert.message),
            const SizedBox(height: 4),
            Text(
              _formatDate(alert.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: alert.status == AlertStatus.active
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'resolve' && onResolve != null) {
                    onResolve!();
                  } else if (value == 'dismiss' && onDismiss != null) {
                    onDismiss!();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'resolve',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 20),
                        SizedBox(width: 8),
                        Text('Resolver'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'dismiss',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, size: 20),
                        SizedBox(width: 8),
                        Text('Dispensar'),
                      ],
                    ),
                  ),
                ],
              )
            : null,
        isThreeLine: true,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return 'há ${diff.inDays} dia${diff.inDays > 1 ? 's' : ''}';
    } else if (diff.inHours > 0) {
      return 'há ${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
    } else if (diff.inMinutes > 0) {
      return 'há ${diff.inMinutes} minuto${diff.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'agora';
    }
  }
}
