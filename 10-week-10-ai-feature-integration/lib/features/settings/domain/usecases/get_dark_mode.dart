import '../../../../core/failures.dart';
import '../repositories/settings_repository.dart';

class GetDarkMode {
  const GetDarkMode(this._repository);

  final SettingsRepository _repository;

  Future<({bool value, Failure? failure})> call() {
    return _repository.getDarkMode();
  }
}
