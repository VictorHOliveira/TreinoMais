import 'package:flutter_test/flutter_test.dart';

import 'package:fittrack/app.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FitTrackApp());
    expect(find.text('FitTrack'), findsWidgets);
  });
}
