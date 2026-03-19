import 'package:flutter_test/flutter_test.dart';
import 'package:planner_desktop/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PlannerDesktopApp());
    expect(find.byType(PlannerDesktopApp), findsOneWidget);
  });
}
