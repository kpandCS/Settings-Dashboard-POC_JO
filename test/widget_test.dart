import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:settings_screen_poc/main.dart';
import 'package:settings_screen_poc/viewmodel/settings_viewmodel.dart';

void main() {
  testWidgets('Settings screen renders without error', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SettingsViewModel(),
        child: const PocketLinkSettingsPOC(),
      ),
    );
    await tester.pump();
    expect(find.text('Settings'), findsOneWidget);
  });
}
