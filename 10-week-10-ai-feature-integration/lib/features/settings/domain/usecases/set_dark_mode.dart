import '../../../../core/failures.dart';
import '../repositories/settings_repository.dart';

class SetDarkMode {
  const SetDarkMode(this._repository);

  final SettingsRepository _repository;

  Future<({bool ok, Failure? failure})> call(bool value) {
    return _repository.setDarkMode(value);
  }
}
