import 'package:dio/dio.dart';

import '../models/comment.dart';

/// Repository yang menjadi satu-satunya lapisan pemanggil endpoint comments.
class CommentRepository {
  CommentRepository(this._dio);

  final Dio _dio;

  /// Mengambil komentar untuk post tertentu melalui query parameter postId.
  /// Timeout 10 detik berasal dari BaseOptions di api_client.dart.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List<dynamic>>(
      '/comments',
      queryParameters: {'postId': postId},
    );

    // Respons kosong dianggap sebagai daftar kosong, bukan null yang diteruskan.
    final data = response.data ?? const <dynamic>[];

    // Hanya objek JSON yang valid diubah menjadi Comment.
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
