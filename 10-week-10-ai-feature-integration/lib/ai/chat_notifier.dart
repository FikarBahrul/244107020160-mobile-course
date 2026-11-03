import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/notes/presentation/providers/notes_providers.dart';
import 'ai_service.dart';
import 'ai_service_provider.dart';
import 'chat_state.dart';
import 'local_fallback.dart';
import 'privacy_guard.dart';

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => ChatState.initial;

  Future<void> send(String rawQuestion) async {
    final question = rawQuestion.trim();
    if (question.isEmpty || state.sending) return;

    if (containsSensitiveData(question)) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(role: ChatRole.user, text: question),
          ChatMessage(
            role: ChatRole.assistant,
            text: privacyWarning(),
            local: true,
          ),
        ],
        clearError: true,
      );
      return;
    }

    final messages = [
      ...state.messages,
      ChatMessage(role: ChatRole.user, text: question),
      const ChatMessage(role: ChatRole.assistant, text: ''),
    ];
    state = ChatState(messages: messages, sending: true);

    try {
      final service = ref.read(aiServiceProvider);
      if (!await service.hasApiKey()) {
        throw const AiException(
          'Kunci API belum diatur. Buka Pengaturan untuk menambahkan kunci.',
        );
      }

      final buffer = StringBuffer();
      await for (final chunk in service.askStream(question)) {
        buffer.write(chunk);
        _replaceLastAssistant(buffer.toString(), local: false);
      }

      if (buffer.isEmpty) {
        throw const AiException(
          'AI tidak mengembalikan teks. Coba tulis pertanyaan dengan lebih jelas.',
        );
      }
      state = state.copyWith(sending: false, clearError: true);
    } catch (error) {
      final message = error is AiException
          ? error.message
          : 'Terjadi kesalahan saat menghubungi layanan AI.';
      final fallback = localFallbackAnswer(question, await _noteTitles());
      _replaceLastAssistant(
        '$fallback\n\nCatatan sistem : $message',
        local: true,
      );
      state = state.copyWith(
        sending: false,
        error: message,
        fallbackUsed: true,
      );
    }
  }

  Future<void> retryLast() async {
    final lastUserIndex = state.messages.lastIndexWhere(
      (message) => message.role == ChatRole.user,
    );
    if (lastUserIndex < 0 || state.sending) return;

    final question = state.messages[lastUserIndex].text;
    final trimmed = state.messages.sublist(0, lastUserIndex);
    state = ChatState(messages: trimmed);
    await send(question);
  }

  void clear() {
    state = ChatState.initial;
  }

  Future<List<String>> _noteTitles() async {
    try {
      final notes = await ref.read(notesProvider.future);
      return notes.map((note) => note.title).toList();
    } catch (_) {
      return const [];
    }
  }

  void _replaceLastAssistant(String text, {required bool local}) {
    if (state.messages.isEmpty) return;
    final messages = [...state.messages];
    messages[messages.length - 1] = ChatMessage(
      role: ChatRole.assistant,
      text: text,
      local: local,
    );
    state = state.copyWith(messages: messages);
  }
}
