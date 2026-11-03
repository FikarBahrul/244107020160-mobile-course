import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/load_posts.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl();
});

final loadPostsProvider = Provider<LoadPosts>(
  (ref) => LoadPosts(ref.watch(postRepositoryProvider)),
);

final postsProvider = FutureProvider<List<Post>>((ref) async {
  final result = await ref.watch(loadPostsProvider).call();
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.posts;
});
