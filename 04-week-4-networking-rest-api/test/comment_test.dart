import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/network_errors.dart';

void main() {
  test('fromJson aman saat field wajib hilang', () {
    // Hanya postId yang tersedia untuk memverifikasi fallback field lain.
    final comment = Comment.fromJson({'postId': 3});

    expect(comment.postId, 3);
    expect(comment.id, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });

  test('fromJson aman saat field berisi null', () {
    // Edge case tambahan memastikan nilai null tidak menyebabkan cast error.
    final comment = Comment.fromJson({
      'postId': null,
      'id': null,
      'name': null,
      'email': null,
      'body': null,
    });

    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });

  test('friendlyErrorMessage memetakan timeout, 404, dan 500', () {
    // Setiap error dibuat seperti error Dio nyata tanpa melakukan HTTP.
    final timeout = DioException(
      requestOptions: RequestOptions(path: '/comments'),
      type: DioExceptionType.receiveTimeout,
    );
    final notFound = DioException(
      requestOptions: RequestOptions(path: '/comments'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/comments'),
        statusCode: 404,
      ),
    );
    final serverError = DioException(
      requestOptions: RequestOptions(path: '/comments'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/comments'),
        statusCode: 500,
      ),
    );

    expect(friendlyErrorMessage(timeout), contains('timeout'));
    expect(friendlyErrorMessage(notFound), contains('404'));
    expect(friendlyErrorMessage(serverError), contains('500'));
  });
}
