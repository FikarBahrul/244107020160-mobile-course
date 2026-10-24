import '../../../../core/failures.dart';

abstract class SettingsRepository {
  Future<({bool value, Failure? failure})> getDarkMode();

  Future<({bool ok, Failure? failure})> setDarkMode(bool value);

  Future<({String? value, Failure? failure})> getLastOpened();

  Future<({bool ok, Failure? failure})> markOpenedNow();
}
