import 'package:crcrme_banque_stages/common/widgets/disponibility_circle.dart';
import 'package:crcrme_banque_stages/common/widgets/numbered_tablet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  group('Disponibility circle', () {
    testWidgets('Disponibility circle has tooltip', (widgetTester) async {
      await widgetTester.pumpWidget(addOverlay(const DisponibilityCircle(
          positionsOccupied: 1, positionsOffered: 3)));

      final tooltip =
          find.byTooltip('Nombre de places disponibles pour ce métier');
      expect(tooltip, findsOneWidget);
    });

    testWidgets('Disponibility circle is green when there are places',
        (tester) async {
      await tester.pumpWidget(addOverlay(const DisponibilityCircle(
          positionsOccupied: 1, positionsOffered: 3)));

      final tablet = find.byType(NumberedTablet);
      expect(tablet, findsOneWidget);
      expect((tester.firstWidget(tablet) as NumberedTablet).color,
          Colors.green[800]);
    });

    testWidgets('Disponibility circle is red when there are no places',
        (tester) async {
      await tester.pumpWidget(addOverlay(const DisponibilityCircle(
          positionsOccupied: 3, positionsOffered: 3)));

      final tablet = find.byType(NumberedTablet);
      expect(tablet, findsOneWidget);
      expect((tester.firstWidget(tablet) as NumberedTablet).color,
          Colors.red[800]);
    });

    testWidgets('Disponibility circle shows the right number', (tester) async {
      await tester.pumpWidget(addOverlay(const DisponibilityCircle(
          positionsOccupied: 1, positionsOffered: 3)));

      final tablet = find.byType(NumberedTablet);
      expect(tablet, findsOneWidget);
      expect((tester.firstWidget(tablet) as NumberedTablet).number, 2);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('Disponibility is shown if empty when should show',
        (tester) async {
      await tester.pumpWidget(
          addOverlay(const NumberedTablet(number: 0, hideIfEmpty: false)));

      final tablet = find.byType(NumberedTablet);
      expect(tablet, findsOneWidget);
      expect((tester.firstWidget(tablet) as NumberedTablet).number, 0);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('Disponibility is not shown if empty when should not show',
        (tester) async {
      await tester.pumpWidget(
          addOverlay(const NumberedTablet(number: 0, hideIfEmpty: true)));

      final tablet = find.byType(NumberedTablet);
      expect(tablet, findsOneWidget);
      expect((tester.firstWidget(tablet) as NumberedTablet).number, 0);
      expect(find.text('0'), findsNothing);
    });
  });
}
