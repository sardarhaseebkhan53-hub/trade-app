import 'package:aurum/app/aurum_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows AURUM branding on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AurumApp()));

    expect(find.text('AURUM'), findsOneWidget);
    expect(find.text('Preparing your market workspace'), findsOneWidget);
  });
}
