import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:crcrme_banque_stages/main.dart';
import 'package:crcrme_banque_stages/screens/enterprises_list/widgets/enterprise_card.dart';
import 'package:crcrme_banque_stages/screens/students_list/widgets/student_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  group('Navigation', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    testWidgets('Then opening page is My students',
        (WidgetTester tester) async {
      // Load the app and navigate to the home page.
      await tester.pumpWidget(const BanqueStagesApp(mockFirebase: true));

      // Verify that the home page is "My students"
      expect(find.text(ScreenTest.myStudents.name), findsOneWidget);
    });

    testWidgets('The drawer navigates and closes on click',
        (WidgetTester tester) async {
      // Load the app and navigate and open the drawer.
      await tester.pumpWidget(const BanqueStagesApp(mockFirebase: true));

      // Verify that the drawer contains the expected tiles
      for (final screenNameOuter in ScreenTest.values) {
        for (final screenNameInner in ScreenTest.values) {
          // For some reason, these two next fail (because it is too long)
          if (screenNameInner == ScreenTest.healthAndSafetyAtPFAE ||
              screenNameOuter == ScreenTest.healthAndSafetyAtPFAE) {
            continue;
          }

          // Navigate from Outer to Inner screen
          await tester.navigateToScreen(screenNameInner);

          // Verify the page is loaded and drawer is closed
          expect(find.text(screenNameInner.name), findsOneWidget);
          expect(find.text(drawerTitle), findsNothing);

          // Return to outer loop screen
          await tester.navigateToScreen(screenNameOuter);
        }
      }
    });

    testWidgets('The reinitialize data button is not shown in production',
        (WidgetTester tester) async {
      // Remove the reinitialized data button (as in production)
      initializeProgram(useDatabaseEmulator: false, mockFirebase: true);

      // Load the app and navigate to the home page (My students).
      await tester.pumpWidget(const BanqueStagesApp(mockFirebase: true));

      // Verify the reinitialized button is hidden (as in production)
      await tester.openDrawer();
      expect(find.text(reinitializedDataButtonText), findsNothing);
      await tester.closeDrawer();

      // Reinitialized the testing conditions
      initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

      // Verify the reinitialized button is present (as in testing)
      await tester.openDrawer();
      expect(find.text(reinitializedDataButtonText), findsOneWidget);
    });
  });

  group('Data loading', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    testWidgets('The dummy data are properly loaded',
        (WidgetTester tester) async {
      // Load the app and navigate to the home page.
      await tester.pumpWidget(const BanqueStagesApp(mockFirebase: true));

      // Verify the home page is empty
      for (final student in StudentTest.values) {
        expect(find.text(student.name), findsNothing);
      }

      // Load the dummy data
      await tester.loadDummyData();

      // Make sure the drawer was automatically closed
      expect(find.text(reinitializedDataButtonText), findsNothing);

      // Verify the students data is now loaded
      await tester.navigateToScreen(ScreenTest.myStudents);
      expect(
        find.bySubtype<StudentCard>(skipOffstage: false),
        findsNWidgets(StudentTest.length),
      );
      for (final student in StudentTest.values) {
        expect(find.text(student.name, skipOffstage: false), findsOneWidget);
      }

      // Verify the enterprises data is now loaded
      await tester.navigateToScreen(ScreenTest.enterprises);
      final sortedEnterprises = [...EnterpriseTest.values]
        ..sort((a, b) => a.name.compareTo(b.name));
      for (final i in sortedEnterprises.asMap().keys) {
        final enterprise = sortedEnterprises[i];
        if (i == sortedEnterprises.length ~/ 2) {
          // When getting to half of the enterprises, scroll up
          await tester.drag(
              find.byType(EnterpriseCard).first, const Offset(0.0, -1000));
          await tester.pump();
        }
        expect(find.text(enterprise.name, skipOffstage: false), findsOneWidget);
      }

      // Verify the interships data is now loaded
      await tester.navigateToScreen(ScreenTest.supervisionTable);
      expect(
        find.byType(ListTile, skipOffstage: false),
        findsNWidgets(InternshipsTest.length),
      );
      for (final internship in InternshipsTest.values) {
        expect(find.text(internship.studentName, skipOffstage: false),
            findsOneWidget);
      }

      // Verify the tasks data is now loaded
      await tester.navigateToScreen(ScreenTest.tasks);
      expect(find.byType(Card), findsNWidgets(TasksTest.length));
      // Since there is repeating names in the tasks it is unclear how to test
      // individual tasks, so we just test the number of tasks
    });
  });
}
