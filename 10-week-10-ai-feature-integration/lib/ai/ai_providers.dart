import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_service_provider.dart';
import 'chat_notifier.dart';
import 'chat_state.dart';

final apiKeyStatusProvider = FutureProvider<bool>((ref) {
  return ref.watch(aiServiceProvider).hasApiKey();
});

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
