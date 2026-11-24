import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:week12_testing_quality_assurance/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pengguna dapat menambahkan catatan baru', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('Offline Notes'), findsOneWidget);

    final title = 'Tugas integrasi ${DateTime.now().millisecondsSinceEpoch}';

    await tester.tap(find.byKey(const Key('add-note-fab')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('note-title-field')), title);
    await tester.tap(find.byKey(const Key('save-note-button')));
    await tester.pumpAndSettle();

    expect(find.text(title), findsOneWidget);
  });
}
