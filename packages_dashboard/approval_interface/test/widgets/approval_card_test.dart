import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:approval_interface/approval_interface.dart';

void main() {
  group('ApprovalCard', () {
    late ApprovalItem testItem;

    setUp(() {
      testItem = ApprovalItem(
        id: 'test-1',
        type: ApprovalType.codeReview,
        title: 'Test Approval Item',
        description: 'This is a test description',
        priority: ApprovalPriority.high,
        status: ApprovalStatus.pending,
        createdAt: DateTime(2024, 1, 1),
        assignedTo: 'test-user',
      );
    });

    testWidgets('displays basic item information', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(item: testItem),
          ),
        ),
      );

      expect(find.text('Test Approval Item'), findsOneWidget);
      expect(find.text('This is a test description'), findsOneWidget);
    });

    testWidgets('shows priority badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(item: testItem),
          ),
        ),
      );

      // Priority badge should be visible
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('displays type chip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(item: testItem),
          ),
        ),
      );

      expect(find.text('Code Review'), findsOneWidget);
    });

    testWidgets('displays status chip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(item: testItem),
          ),
        ),
      );

      expect(find.text('Pendente'), findsOneWidget);
    });

    testWidgets('shows action buttons when showActions is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(
              item: testItem,
              showActions: true,
            ),
          ),
        ),
      );

      expect(find.text('Aprovar'), findsOneWidget);
      expect(find.text('Rejeitar'), findsOneWidget);
    });

    testWidgets('hides action buttons when showActions is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(
              item: testItem,
              showActions: false,
            ),
          ),
        ),
      );

      expect(find.text('Aprovar'), findsNothing);
      expect(find.text('Rejeitar'), findsNothing);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(
              item: testItem,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('calls onApprove callback when approve button is pressed', (tester) async {
      bool approved = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(
              item: testItem,
              onApprove: () => approved = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Aprovar'));
      await tester.pumpAndSettle();

      expect(approved, true);
    });

    testWidgets('calls onReject callback when reject button is pressed', (tester) async {
      bool rejected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(
              item: testItem,
              onReject: () => rejected = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Rejeitar'));
      await tester.pumpAndSettle();

      expect(rejected, true);
    });

    testWidgets('shows checkbox when onSelectChanged is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(
              item: testItem,
              onSelectChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('checkbox reflects isSelected state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(
              item: testItem,
              isSelected: true,
              onSelectChanged: (_) {},
            ),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);
    });

    testWidgets('calls onSelectChanged when checkbox is tapped', (tester) async {
      bool? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(
              item: testItem,
              isSelected: false,
              onSelectChanged: (value) => selectedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(selectedValue, true);
    });

    testWidgets('hides action buttons for approved items', (tester) async {
      final approvedItem = testItem.copyWith(status: ApprovalStatus.approved);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(item: approvedItem),
          ),
        ),
      );

      expect(find.text('Aprovar'), findsNothing);
      expect(find.text('Rejeitar'), findsNothing);
    });

    testWidgets('displays critical priority with correct icon', (tester) async {
      final criticalItem = testItem.copyWith(priority: ApprovalPriority.critical);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(item: criticalItem),
          ),
        ),
      );

      expect(find.byIcon(Icons.priority_high), findsOneWidget);
    });

    testWidgets('displays low priority with correct icon', (tester) async {
      final lowItem = testItem.copyWith(priority: ApprovalPriority.low);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(item: lowItem),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('displays assigned user when present', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(item: testItem),
          ),
        ),
      );

      expect(find.text('test-user'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('does not show description when null', (tester) async {
      final itemWithoutDesc = testItem.copyWith(description: null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApprovalCard(item: itemWithoutDesc),
          ),
        ),
      );

      // Title should still be visible
      expect(find.text('Test Approval Item'), findsOneWidget);
      // But description should not be rendered
      expect(find.text('This is a test description'), findsNothing);
    });
  });
}
