import 'package:flutter_test/flutter_test.dart';
import 'package:approval_interface/approval_interface.dart';

void main() {
  group('ApprovalItem', () {
    test('can be created with required fields', () {
      final item = ApprovalItem(
        id: 'test-1',
        type: ApprovalType.codeReview,
        title: 'Test Item',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(item.id, 'test-1');
      expect(item.type, ApprovalType.codeReview);
      expect(item.title, 'Test Item');
      expect(item.status, ApprovalStatus.pending);
      expect(item.priority, ApprovalPriority.normal);
    });

    test('can be created with all fields', () {
      final now = DateTime.now();
      final item = ApprovalItem(
        id: 'test-2',
        type: ApprovalType.grading,
        title: 'Full Test Item',
        description: 'Test description',
        priority: ApprovalPriority.high,
        status: ApprovalStatus.approved,
        content: {'key': 'value'},
        assignedTo: 'user-123',
        createdAt: now,
        reviewedAt: now,
        approvedAt: now,
        metadata: {'meta': 'data'},
      );

      expect(item.description, 'Test description');
      expect(item.priority, ApprovalPriority.high);
      expect(item.status, ApprovalStatus.approved);
      expect(item.content, {'key': 'value'});
      expect(item.assignedTo, 'user-123');
      expect(item.metadata, {'meta': 'data'});
    });

    test('can be serialized to JSON', () {
      final item = ApprovalItem(
        id: 'test-3',
        type: ApprovalType.award,
        title: 'JSON Test',
        description: 'Testing JSON',
        priority: ApprovalPriority.critical,
        status: ApprovalStatus.rejected,
        createdAt: DateTime(2024, 1, 1, 12, 0),
        assignedTo: 'admin',
      );

      final json = item.toJson();

      expect(json['id'], 'test-3');
      expect(json['type'], 'award');
      expect(json['title'], 'JSON Test');
      expect(json['description'], 'Testing JSON');
      expect(json['priority'], 'critical');
      expect(json['status'], 'rejected');
      expect(json['assigned_to'], 'admin');
      expect(json['created_at'], '2024-01-01T12:00:00.000');
    });

    test('can be deserialized from JSON', () {
      final json = {
        'id': 'test-4',
        'type': 'content',
        'title': 'From JSON',
        'description': 'Deserialization test',
        'priority': 'low',
        'status': 'inReview',
        'content': {'data': 'test'},
        'assigned_to': 'reviewer',
        'created_at': '2024-01-01T10:00:00.000',
        'reviewed_at': '2024-01-02T10:00:00.000',
        'metadata': {'source': 'test'},
      };

      final item = ApprovalItem.fromJson(json);

      expect(item.id, 'test-4');
      expect(item.type, ApprovalType.content);
      expect(item.title, 'From JSON');
      expect(item.description, 'Deserialization test');
      expect(item.priority, ApprovalPriority.low);
      expect(item.status, ApprovalStatus.inReview);
      expect(item.content, {'data': 'test'});
      expect(item.assignedTo, 'reviewer');
      expect(item.createdAt, DateTime(2024, 1, 1, 10, 0));
      expect(item.reviewedAt, DateTime(2024, 1, 2, 10, 0));
      expect(item.metadata, {'source': 'test'});
    });

    test('copyWith creates a copy with updated fields', () {
      final original = ApprovalItem(
        id: 'test-5',
        type: ApprovalType.issue,
        title: 'Original',
        status: ApprovalStatus.pending,
        createdAt: DateTime(2024, 1, 1),
      );

      final updated = original.copyWith(
        title: 'Updated',
        status: ApprovalStatus.approved,
      );

      expect(updated.id, original.id);
      expect(updated.type, original.type);
      expect(updated.title, 'Updated');
      expect(updated.status, ApprovalStatus.approved);
      expect(updated.createdAt, original.createdAt);
    });

    test('copyWith without parameters returns identical copy', () {
      final original = ApprovalItem(
        id: 'test-6',
        type: ApprovalType.codeReview,
        title: 'Copy Test',
        createdAt: DateTime(2024, 1, 1),
      );

      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.type, original.type);
      expect(copy.title, original.title);
      expect(copy.status, original.status);
      expect(copy.createdAt, original.createdAt);
    });

    test('toString includes basic information', () {
      final item = ApprovalItem(
        id: 'test-7',
        type: ApprovalType.grading,
        title: 'ToString Test',
        status: ApprovalStatus.pending,
        createdAt: DateTime.now(),
      );

      final string = item.toString();

      expect(string, contains('test-7'));
      expect(string, contains('grading'));
      expect(string, contains('ToString Test'));
      expect(string, contains('pending'));
    });

    test('handles null optional fields in JSON', () {
      final json = {
        'id': 'test-8',
        'type': 'other',
        'title': 'Minimal',
        'priority': 'normal',
        'status': 'pending',
        'created_at': '2024-01-01T00:00:00.000',
      };

      final item = ApprovalItem.fromJson(json);

      expect(item.id, 'test-8');
      expect(item.description, isNull);
      expect(item.content, isNull);
      expect(item.assignedTo, isNull);
      expect(item.reviewedAt, isNull);
      expect(item.approvedAt, isNull);
      expect(item.metadata, isNull);
    });

    test('handles unknown enum values gracefully', () {
      final json = {
        'id': 'test-9',
        'type': 'unknown_type',
        'title': 'Enum Test',
        'priority': 'unknown_priority',
        'status': 'unknown_status',
        'created_at': '2024-01-01T00:00:00.000',
      };

      final item = ApprovalItem.fromJson(json);

      // Should fallback to default values
      expect(item.type, ApprovalType.other);
      expect(item.priority, ApprovalPriority.normal);
      expect(item.status, ApprovalStatus.pending);
    });
  });

  group('ApprovalType enum', () {
    test('has all expected values', () {
      expect(ApprovalType.values.length, 6);
      expect(ApprovalType.values, contains(ApprovalType.codeReview));
      expect(ApprovalType.values, contains(ApprovalType.grading));
      expect(ApprovalType.values, contains(ApprovalType.award));
      expect(ApprovalType.values, contains(ApprovalType.content));
      expect(ApprovalType.values, contains(ApprovalType.issue));
      expect(ApprovalType.values, contains(ApprovalType.other));
    });
  });

  group('ApprovalPriority enum', () {
    test('has all expected values', () {
      expect(ApprovalPriority.values.length, 4);
      expect(ApprovalPriority.values, contains(ApprovalPriority.critical));
      expect(ApprovalPriority.values, contains(ApprovalPriority.high));
      expect(ApprovalPriority.values, contains(ApprovalPriority.normal));
      expect(ApprovalPriority.values, contains(ApprovalPriority.low));
    });
  });

  group('ApprovalStatus enum', () {
    test('has all expected values', () {
      expect(ApprovalStatus.values.length, 4);
      expect(ApprovalStatus.values, contains(ApprovalStatus.pending));
      expect(ApprovalStatus.values, contains(ApprovalStatus.inReview));
      expect(ApprovalStatus.values, contains(ApprovalStatus.approved));
      expect(ApprovalStatus.values, contains(ApprovalStatus.rejected));
    });
  });
}
