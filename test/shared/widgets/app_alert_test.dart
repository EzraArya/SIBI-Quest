import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sibi_quest/shared/widgets/app_alert.dart';

void main() {
  Widget buildSubject({
    required VoidCallback onPrimary,
    required VoidCallback onSecondary,
  }) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AppAlert(
            title: 'Delete account',
            message: 'This action cannot be undone.',
            primaryButtonLabel: 'Delete',
            secondaryButtonLabel: 'Cancel',
            onPrimaryPressed: onPrimary,
            onSecondaryPressed: onSecondary,
          ),
        ),
      ),
    );
  }

  testWidgets('renders provided title and message', (tester) async {
    await tester.pumpWidget(buildSubject(onPrimary: () {}, onSecondary: () {}));

    expect(find.text('Delete account'), findsOneWidget);
    expect(find.text('This action cannot be undone.'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('triggers callbacks when buttons are tapped', (tester) async {
    var primaryTapped = false;
    var secondaryTapped = false;

    await tester.pumpWidget(
      buildSubject(
        onPrimary: () {
          primaryTapped = true;
        },
        onSecondary: () {
          secondaryTapped = true;
        },
      ),
    );

    await tester.tap(find.text('Delete'));
    await tester.pump();

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(primaryTapped, isTrue);
    expect(secondaryTapped, isTrue);
  });
}
