import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'models/comment.dart';
import 'repositories/comment_repository.dart';

/// Satu Dio terpusat agar baseUrl dan timeout tidak tersebar di repository.
final commentDioProvider = Provider<Dio>((ref) => createDio());

/// Menyediakan repository dengan client Dio yang sama untuk seluruh aplikasi.
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(commentDioProvider)),
);

/// AsyncNotifier family membuat state komentar terpisah untuk setiap postId.
class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  CommentListNotifier(this.postId);

  final int postId;

  @override
  Future<List<Comment>> build() {
    // Exception dari repository ditangkap Riverpod menjadi AsyncError otomatis.
    return ref.watch(commentRepositoryProvider).fetchComments(postId);
  }

  /// Memuat ulang komentar dan tetap membiarkan error menjadi AsyncError.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Provider utama untuk membaca komentar berdasarkan ID post.
final commentListProvider =
    AsyncNotifierProvider.family<CommentListNotifier, List<Comment>, int>(
  (postId) => CommentListNotifier(postId),
  // Retry otomatis dimatikan agar error jaringan dapat langsung ditampilkan.
  retry: (retryCount, error) => null,
);
