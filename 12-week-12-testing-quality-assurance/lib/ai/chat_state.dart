enum ChatRole { user, assistant }

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    this.local = false,
  });

  final ChatRole role;
  final String text;
  final bool local;
}

class ChatState {
  const ChatState({
    this.messages = const [],
    this.sending = false,
    this.error,
    this.fallbackUsed = false,
  });

  final List<ChatMessage> messages;
  final bool sending;
  final String? error;
  final bool fallbackUsed;

  static const initial = ChatState(
    messages: [
      ChatMessage(
        role: ChatRole.assistant,
        text:
            'Halo! Saya Asisten Kampus. Tanyakan hal singkat tentang '
            'perkuliahan atau catatan Anda.',
      ),
    ],
  );

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? sending,
    String? error,
    bool clearError = false,
    bool? fallbackUsed,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
      error: clearError ? null : (error ?? this.error),
      fallbackUsed: fallbackUsed ?? this.fallbackUsed,
    );
  }
}
