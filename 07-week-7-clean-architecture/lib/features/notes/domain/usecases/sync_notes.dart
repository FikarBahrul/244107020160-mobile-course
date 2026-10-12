import '../../../../core/failures.dart';
import '../repositories/note_repository.dart';

// Use case untuk aturan bisnis sync: hitung dirty, simulasi upload, tandai bersih.
class SyncNotes {
  const SyncNotes(this._repository);

  final NoteRepository _repository;

  Future<({int synced, Failure? failure})> call() async {
    final counted = await _repository.countDirty();
    if (counted.failure != null) {
      return (synced: 0, failure: counted.failure);
    }
    if (counted.count == 0) {
      return (synced: 0, failure: null);
    }
    await Future<void>.delayed(const Duration(seconds: 1));
    final marked = await _repository.markAllSynced();
    if (marked.failure != null) {
      return (synced: 0, failure: marked.failure);
    }
    return (synced: counted.count, failure: null);
  }
}
