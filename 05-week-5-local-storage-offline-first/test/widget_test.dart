import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week5_offline_notes/main.dart';

void main() {
  testWidgets('menampilkan halaman Offline Notes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: OfflineNotesApp()));
    await tester.pumpAndSettle();
    expect(find.text('Offline Notes'), findsOneWidget);
    expect(find.text('Mode offline aktif'), findsOneWidget);
  });
}
