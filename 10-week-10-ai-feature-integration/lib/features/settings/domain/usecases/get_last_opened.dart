import '../../../../core/failures.dart';
import '../repositories/settings_repository.dart';

class GetLastOpened {
  const GetLastOpened(this._repository);

  final SettingsRepository _repository;

  Future<({String? value, Failure? failure})> call() {
    return _repository.getLastOpened();
  }
}
