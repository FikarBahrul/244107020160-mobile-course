import '../../../../core/failures.dart';
import '../repositories/settings_repository.dart';

class MarkOpened {
  const MarkOpened(this._repository);

  final SettingsRepository _repository;

  Future<({bool ok, Failure? failure})> call() {
    return _repository.markOpenedNow();
  }
}
