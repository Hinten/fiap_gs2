import 'package:flutter/material.dart';

import '../services/wellbeing_monitoring_service.dart';

/// Widget for students to report their wellbeing status.
///
/// Provides an accessible, intuitive interface for mood and stress reporting
/// with clear consent mechanisms for LGPD/GDPR compliance.
class WellbeingCheckinWidget extends StatefulWidget {
  /// The monitoring service to record check-ins.
  final WellbeingMonitoringService service;

  /// Optional student ID (only used if consent is given).
  final String? studentId;

  /// Callback when check-in is successfully recorded.
  final VoidCallback? onCheckinRecorded;

  const WellbeingCheckinWidget({
    required this.service,
    this.studentId,
    this.onCheckinRecorded,
    super.key,
  });

  @override
  State<WellbeingCheckinWidget> createState() => _WellbeingCheckinWidgetState();
}

class _WellbeingCheckinWidgetState extends State<WellbeingCheckinWidget> {
  int _moodLevel = 3;
  int _stressLevel = 3;
  String _notes = '';
  bool _consentToShare = false;
  bool _isSubmitting = false;

  // Emoji representations for mood levels
  static const List<String> _moodEmojis = [
    '😢', // 1 - Very sad
    '😕', // 2 - Sad
    '😐', // 3 - Neutral
    '🙂', // 4 - Happy
    '😄', // 5 - Very happy
  ];

  static const List<String> _moodLabels = [
    'Very Sad',
    'Sad',
    'Neutral',
    'Happy',
    'Very Happy',
  ];

  static const List<Color> _stressColors = [
    Colors.green, // 1 - Very low
    Colors.lightGreen, // 2 - Low
    Colors.orange, // 3 - Moderate
    Colors.deepOrange, // 4 - High
    Colors.red, // 5 - Very high
  ];

  static const List<String> _stressLabels = [
    'Very Low',
    'Low',
    'Moderate',
    'High',
    'Very High',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How are you feeling today?',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildMoodSelector(),
            const SizedBox(height: 32),
            _buildStressSelector(),
            const SizedBox(height: 24),
            _buildNotesField(),
            const SizedBox(height: 24),
            _buildConsentSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Semantics(
      label: 'Mood level selector',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Mood',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final level = index + 1;
              final isSelected = _moodLevel == level;
              return Semantics(
                label: 'Mood: ${_moodLabels[index]}',
                selected: isSelected,
                button: true,
                onTap: () => setState(() => _moodLevel = level),
                child: GestureDetector(
                  onTap: () => setState(() => _moodLevel = level),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          _moodEmojis[index],
                          style: const TextStyle(fontSize: 32),
                          semanticsLabel: _moodLabels[index],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _moodLabels[index],
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStressSelector() {
    return Semantics(
      label: 'Stress level selector',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Stress Level',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Semantics(
            label:
                'Stress level slider. Current value: ${_stressLabels[_stressLevel - 1]}',
            value: _stressLabels[_stressLevel - 1],
            increasedValue:
                _stressLevel < 5 ? _stressLabels[_stressLevel] : null,
            decreasedValue:
                _stressLevel > 1 ? _stressLabels[_stressLevel - 2] : null,
            onIncrease:
                _stressLevel < 5 ? () => setState(() => _stressLevel++) : null,
            onDecrease:
                _stressLevel > 1 ? () => setState(() => _stressLevel--) : null,
            child: Slider(
              value: _stressLevel.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _stressLabels[_stressLevel - 1],
              activeColor: _stressColors[_stressLevel - 1],
              onChanged: (value) =>
                  setState(() => _stressLevel = value.toInt()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Very Low',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                _stressLabels[_stressLevel - 1],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _stressColors[_stressLevel - 1],
                ),
              ),
              Text(
                'Very High',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Semantics(
      label: 'Optional notes text field',
      textField: true,
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Notes (optional)',
          hintText: 'Share anything on your mind...',
          border: OutlineInputBorder(),
          helperText:
              'Optional. Will only be stored locally with your consent.',
        ),
        maxLines: 3,
        onChanged: (value) => setState(() => _notes = value),
      ),
    );
  }

  Widget _buildConsentSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.privacy_tip_outlined,
                  color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Privacy & Data Sharing',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              TextButton(
                onPressed: _showConsentDetailsModal,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Learn More',
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Your wellbeing data is private and stored securely on your device. '
            'Check the box below only if you consent to sharing anonymized '
            'aggregate data to help improve student support services.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _consentToShare,
            onChanged: (value) => setState(() => _consentToShare = value!),
            title: const Text(
              'I consent to sharing anonymized data',
              style: TextStyle(fontSize: 14),
            ),
            subtitle: _consentToShare
                ? const Text(
                    '✓ Your data will be anonymized before sharing',
                    style: TextStyle(fontSize: 11, color: Colors.green),
                  )
                : null,
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Future<void> _showConsentDetailsModal() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.privacy_tip, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(
              child: Text('Privacy & Consent Details'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How Your Data is Protected',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildConsentDetailItem(
                icon: Icons.lock_outline,
                title: 'Local Encrypted Storage',
                description:
                    'All your check-ins are stored securely on your device using encryption. No data leaves your device without your explicit consent.',
              ),
              _buildConsentDetailItem(
                icon: Icons.person_off_outlined,
                title: 'Anonymization',
                description:
                    'If you consent to share, your personal identifiers (name, ID) are completely removed. Only aggregate mood/stress statistics are shared.',
              ),
              _buildConsentDetailItem(
                icon: Icons.group_outlined,
                title: 'Aggregate Reporting Only',
                description:
                    'Shared data is combined with other students\' data. Individual responses cannot be identified.',
              ),
              _buildConsentDetailItem(
                icon: Icons.delete_outline,
                title: 'Right to Deletion',
                description:
                    'You can delete all your data at any time. This is your legal right under LGPD and GDPR.',
              ),
              _buildConsentDetailItem(
                icon: Icons.schedule_outlined,
                title: 'Automatic Data Retention',
                description:
                    'Data is automatically deleted after the retention period (typically 30 days) for your privacy.',
              ),
              const SizedBox(height: 16),
              const Text(
                'What Data is Shared (if you consent)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '✓ Average mood levels (aggregated by day)\n'
                '✓ Average stress levels (aggregated by day)\n'
                '✓ Anonymized timestamps (day only, no exact times)\n\n'
                '✗ Your name or student ID\n'
                '✗ Your personal notes\n'
                '✗ Exact check-in times\n'
                '✗ Any identifying information',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You Have Control',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You can always save check-ins locally without sharing. '
                      'Consent is optional and can be given or revoked at any time.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentDetailItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isSubmitting ? null : _saveLocally,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Locally'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submitCheckin,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
            label: const Text('Submit'),
          ),
        ),
      ],
    );
  }

  Future<void> _saveLocally() async {
    try {
      await widget.service.recordCheckin(
        studentId: widget.studentId,
        moodLevel: _moodLevel,
        stressLevel: _stressLevel,
        notes: _notes.isNotEmpty ? _notes : null,
        consentToShare: false, // Local only, no sharing
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in saved locally'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
        widget.onCheckinRecorded?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving check-in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitCheckin() async {
    setState(() => _isSubmitting = true);

    try {
      await widget.service.recordCheckin(
        studentId: widget.studentId,
        moodLevel: _moodLevel,
        stressLevel: _stressLevel,
        notes: _notes.isNotEmpty ? _notes : null,
        consentToShare: _consentToShare,
      );

      // Show anonymization info if consent was given
      if (_consentToShare && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in recorded and will be anonymized for sharing!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in saved locally (not shared)'),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (mounted) {
        _resetForm();
        widget.onCheckinRecorded?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting check-in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _resetForm() {
    setState(() {
      _moodLevel = 3;
      _stressLevel = 3;
      _notes = '';
      _consentToShare = false;
    });
  }
}
