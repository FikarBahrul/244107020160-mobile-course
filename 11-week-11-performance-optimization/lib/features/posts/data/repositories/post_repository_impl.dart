import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../../notes/data/datasources/local_database.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({Future<Database> Function()? openDb, Dio? dio})
    : _openDb = openDb ?? openNotesDb,
      _dio = dio ?? Dio();

  final Future<Database> Function() _openDb;
  final Dio _dio;

  static const _pageSize = 10;

  @override
  Future<({List<Post> posts, Failure? failure})> loadPosts({
    bool forceOffline = false,
  }) async {
    try {
      final db = await _openDb();
      final rows = await db.query('cached_posts', orderBy: 'cached_at DESC');
      final posts = rows.map((row) {
        final payload =
            jsonDecode(row['payload']! as String) as Map<String, dynamic>;
        return PostModel.fromJson(payload).toEntity();
      }).toList();
      if (!forceOffline) {
        unawaited(_refreshInBackground());
      }
      return (posts: posts, failure: null);
    } catch (e) {
      return (
        posts: const <Post>[],
        failure: LocalFailure('Gagal membaca posts: $e'),
      );
    }
  }

  @override
  Future<({List<Post> posts, Failure? failure})> fetchPage(
    int page, {
    bool forceOffline = false,
  }) async {
    var networkFailed = false;
    if (!forceOffline) {
      try {
        final response = await _dio.get<List<dynamic>>(
          'https://jsonplaceholder.typicode.com/posts',
          queryParameters: {'_page': page, '_limit': _pageSize},
        );
        final db = await _openDb();
        final posts = <Post>[];
        for (final item in response.data ?? const []) {
          final json = item as Map<String, dynamic>;
          await db.insert('cached_posts', {
            'id': json['id'],
            'payload': jsonEncode(json),
            'cached_at': DateTime.now().toIso8601String(),
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          posts.add(PostModel.fromJson(json).toEntity());
        }
        return (posts: posts, failure: null);
      } catch (_) {
        networkFailed = true;
      }
    }

    try {
      final db = await _openDb();
      final rows = await db.query(
        'cached_posts',
        orderBy: 'id ASC',
        limit: _pageSize,
        offset: (page - 1) * _pageSize,
      );
      final posts = rows.map((row) {
        final payload =
            jsonDecode(row['payload']! as String) as Map<String, dynamic>;
        return PostModel.fromJson(payload).toEntity();
      }).toList();
      if (posts.isEmpty && networkFailed) {
        return (
          posts: const <Post>[],
          failure: const NetworkFailure(
            'Gagal memuat post. Periksa koneksi internet.',
          ),
        );
      }
      return (posts: posts, failure: null);
    } catch (e) {
      return (
        posts: const <Post>[],
        failure: LocalFailure('Gagal membaca cache posts: $e'),
      );
    }
  }

  Future<void> _refreshInBackground() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        'https://jsonplaceholder.typicode.com/posts',
        queryParameters: {'_limit': 10},
      );
      final db = await _openDb();
      for (final item in response.data ?? const []) {
        final json = item as Map<String, dynamic>;
        await db.insert('cached_posts', {
          'id': json['id'],
          'payload': jsonEncode(json),
          'cached_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (_) {
      // Cache tetap dipakai ketika refresh jaringan gagal.
    }
  }
}
