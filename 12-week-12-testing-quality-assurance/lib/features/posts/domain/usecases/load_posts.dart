import '../../../../core/failures.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class LoadPosts {
  const LoadPosts(this._repository);

  final PostRepository _repository;

  Future<({List<Post> posts, Failure? failure})> call({
    bool forceOffline = false,
  }) {
    return _repository.loadPosts(forceOffline: forceOffline);
  }
}
