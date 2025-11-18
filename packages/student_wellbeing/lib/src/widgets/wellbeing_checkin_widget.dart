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
  State<WellbeingCheckinWidget> createState() =>
      _WellbeingCheckinWidgetState();
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
    return Column(
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
            return GestureDetector(
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
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStressSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stress Level',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Slider(
          value: _stressLevel.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: _stressLabels[_stressLevel - 1],
          activeColor: _stressColors[_stressLevel - 1],
          onChanged: (value) => setState(() => _stressLevel = value.toInt()),
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
    );
  }

  Widget _buildNotesField() {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Notes (optional)',
        hintText: 'Share anything on your mind...',
        border: OutlineInputBorder(),
        helperText: 'Optional. Will only be stored locally with your consent.',
      ),
      maxLines: 3,
      onChanged: (value) => setState(() => _notes = value),
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
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
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
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Your wellbeing data is private. Check the box below only if you '
            'consent to sharing anonymized aggregate data to help improve '
            'student support services. You can delete your data at any time.',
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
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in recorded successfully!'),
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
