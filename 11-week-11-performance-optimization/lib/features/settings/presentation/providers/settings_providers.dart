import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/get_dark_mode.dart';
import '../../domain/usecases/get_last_opened.dart';
import '../../domain/usecases/mark_opened.dart';
import '../../domain/usecases/set_dark_mode.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(),
);

final getDarkModeProvider = Provider<GetDarkMode>(
  (ref) => GetDarkMode(ref.watch(settingsRepositoryProvider)),
);

final setDarkModeProvider = Provider<SetDarkMode>(
  (ref) => SetDarkMode(ref.watch(settingsRepositoryProvider)),
);

final getLastOpenedProvider = Provider<GetLastOpened>(
  (ref) => GetLastOpened(ref.watch(settingsRepositoryProvider)),
);

final markOpenedProvider = Provider<MarkOpened>(
  (ref) => MarkOpened(ref.watch(settingsRepositoryProvider)),
);

final darkModeProvider = AsyncNotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final result = await ref.watch(getDarkModeProvider).call();
    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }
    return result.value;
  }

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(setDarkModeProvider).call(next);
      if (result.failure != null) {
        throw Exception(result.failure!.message);
      }
      return next;
    });
  }
}

final lastOpenedProvider = FutureProvider<String?>((ref) async {
  final result = await ref.watch(getLastOpenedProvider).call();
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.value;
});
