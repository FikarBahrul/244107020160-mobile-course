import 'package:flutter_riverpod/flutter_riverpod.dart';

class FcmTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String token) => state = token;
}

final fcmTokenProvider = NotifierProvider<FcmTokenNotifier, String?>(
  FcmTokenNotifier.new,
);
