import 'package:flutter/material.dart';
import '../models/project.dart';

/// Project card widget for displaying project information
class ProjectCard extends StatelessWidget {
  final ResearchProject project;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Text(
                    project.healthStatus.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(
                      project.area,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue[100],
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Chip(
                    label: Text(
                      project.status.displayName,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _getStatusColor(project.status),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Chip(
                    label: Text(
                      project.healthStatus.displayName,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _getHealthColor(project.healthStatus),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return Colors.green[100]!;
      case ProjectStatus.completed:
        return Colors.blue[100]!;
      case ProjectStatus.paused:
        return Colors.orange[100]!;
      case ProjectStatus.archived:
        return Colors.grey[300]!;
      case ProjectStatus.proposal:
        return Colors.purple[100]!;
    }
  }

  Color _getHealthColor(HealthStatus healthStatus) {
    switch (healthStatus) {
      case HealthStatus.onTrack:
        return Colors.green[100]!;
      case HealthStatus.atRisk:
        return Colors.orange[100]!;
      case HealthStatus.critical:
        return Colors.red[100]!;
    }
  }
}
