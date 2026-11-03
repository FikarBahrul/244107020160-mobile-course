import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week10_ai_feature_integration/ai/ai_service_provider.dart';
import 'package:week10_ai_feature_integration/features/chat_screen.dart';
import 'package:week10_ai_feature_integration/features/notes/domain/entities/note.dart';
import 'package:week10_ai_feature_integration/features/notes/presentation/providers/notes_providers.dart';

import 'fakes.dart';

void main() {
  testWidgets('banner muncul dan fallback lokal terjadi tanpa API key', (
    tester,
  ) async {
    final service = FakeAiClient(hasKey: false);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiServiceProvider.overrideWithValue(service),
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(
              items: [
                Note(
                  title: 'Belanja mingguan',
                  updatedAt: DateTime(2026, 11, 1),
                ),
              ],
            ),
          ),
        ],
        child: const MaterialApp(home: ChatScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Kunci API belum diatur. Jawaban akan memakai mode lokal.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('chat-input')),
      'ringkas catatan saya',
    );
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Mode lokal'), findsOneWidget);
    expect(find.text('Jawaban lokal'), findsOneWidget);
    expect(find.textContaining('Kunci API belum diatur'), findsWidgets);
  });

  testWidgets('jawaban streaming tampil tanpa label lokal', (tester) async {
    final service = FakeAiClient(
      hasKey: true,
      chunks: const ['Jadwal ', 'Senin ', 'dimulai pukul 07.00.'],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiServiceProvider.overrideWithValue(service),
          noteRepositoryProvider.overrideWithValue(FakeNoteRepository()),
        ],
        child: const MaterialApp(home: ChatScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('chat-input')),
      'Jadwal Senin?',
    );
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();

    expect(find.text('Jadwal Senin dimulai pukul 07.00.'), findsOneWidget);
    expect(find.text('Jawaban lokal'), findsNothing);
  });
}
