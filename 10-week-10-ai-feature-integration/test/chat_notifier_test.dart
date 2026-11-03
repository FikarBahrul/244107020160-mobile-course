import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week10_ai_feature_integration/ai/ai_providers.dart';
import 'package:week10_ai_feature_integration/ai/ai_service.dart';
import 'package:week10_ai_feature_integration/ai/ai_service_provider.dart';
import 'package:week10_ai_feature_integration/features/notes/domain/entities/note.dart';
import 'package:week10_ai_feature_integration/features/notes/presentation/providers/notes_providers.dart';

import 'fakes.dart';

ProviderContainer buildContainer(FakeAiClient service) {
  final container = ProviderContainer(
    overrides: [
      aiServiceProvider.overrideWithValue(service),
      noteRepositoryProvider.overrideWithValue(
        FakeNoteRepository(
          items: [
            Note(title: 'Belanja mingguan', updatedAt: DateTime(2026, 11, 1)),
            Note(title: 'Jadwal kuliah', updatedAt: DateTime(2026, 11, 2)),
          ],
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('streaming menggabungkan potongan jawaban AI', () async {
    final service = FakeAiClient(chunks: const ['Halo', ' dari ', 'Gemini.']);
    final container = buildContainer(service);

    await container.read(chatProvider.notifier).send('Halo kampus');

    final state = container.read(chatProvider);
    expect(state.sending, isFalse);
    expect(state.error, isNull);
    expect(state.messages.last.text, 'Halo dari Gemini.');
    expect(state.messages.last.local, isFalse);
    expect(service.asked, ['Halo kampus']);
  });

  test('tanpa API key memakai fallback lokal dan error ramah', () async {
    final service = FakeAiClient(hasKey: false);
    final container = buildContainer(service);

    await container.read(chatProvider.notifier).send('ringkas catatan saya');

    final state = container.read(chatProvider);
    expect(state.sending, isFalse);
    expect(state.fallbackUsed, isTrue);
    expect(state.messages.last.local, isTrue);
    expect(state.messages.last.text, contains('Mode lokal'));
    expect(state.messages.last.text, contains('2 catatan'));
    expect(state.error, contains('Kunci API belum diatur'));
    expect(service.asked, isEmpty);
  });

  test('AI error memakai fallback lokal tanpa melempar', () async {
    final service = FakeAiClient(
      error: const AiException('Layanan AI sedang sibuk.'),
    );
    final container = buildContainer(service);

    await container.read(chatProvider.notifier).send('Jadwal Senin?');

    final state = container.read(chatProvider);
    expect(state.sending, isFalse);
    expect(state.fallbackUsed, isTrue);
    expect(state.error, 'Layanan AI sedang sibuk.');
    expect(state.messages.last.local, isTrue);
  });

  test('data pribadi diblokir sebelum dikirim ke AI', () async {
    final service = FakeAiClient();
    final container = buildContainer(service);

    await container
        .read(chatProvider.notifier)
        .send('NIK saya 1234567890123456');

    final state = container.read(chatProvider);
    expect(service.asked, isEmpty);
    expect(state.messages.last.local, isTrue);
    expect(state.messages.last.text, contains('data pribadi'));
    expect(state.error, isNull);
  });

  test('clear mengembalikan percakapan ke pesan pembuka', () async {
    final service = FakeAiClient();
    final container = buildContainer(service);

    await container.read(chatProvider.notifier).send('Halo');
    container.read(chatProvider.notifier).clear();

    final state = container.read(chatProvider);
    expect(state.messages.length, 1);
    expect(state.messages.first.text, contains('Asisten Kampus'));
  });
}
