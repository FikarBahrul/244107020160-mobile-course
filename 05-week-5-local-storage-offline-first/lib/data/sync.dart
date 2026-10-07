import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:sqflite/sqflite.dart'; // Added import for SQLite

import 'local/db.dart';

class CachedPost {
  const CachedPost({required this.id, required this.title, required this.body});

  final int id;
  final String title;
  final String body;
}

Future<List<CachedPost>> loadPostsCacheFirst({
  bool forceOffline = false,
}) async {
  final cached = await _readCachedPosts();
  if (!forceOffline) {
    _refreshPostsInBackground();
  }
  return cached;
}

Future<List<CachedPost>> _readCachedPosts() async {
  final db = await openNotesDb();
  final rows = await db.query('cached_posts', orderBy: 'cached_at DESC');
  return rows.map((row) {
    final payload =
        jsonDecode(row['payload']! as String) as Map<String, dynamic>;
    return CachedPost(
      id: (payload['id'] as num?)?.toInt() ?? 0,
      title: payload['title'] as String? ?? '',
      body: payload['body'] as String? ?? '',
    );
  }).toList();
}

Future<void> _refreshPostsInBackground() async {
  try {
    final response = await Dio().get<List<dynamic>>(
      'https://jsonplaceholder.typicode.com/posts',
      queryParameters: {'_limit': 10},
    );
    final db = await openNotesDb();
    for (final item in response.data ?? const []) {
      final post = item as Map<String, dynamic>;
      await db.insert('cached_posts', {
        'id': post['id'],
        'payload': jsonEncode(post),
        'cached_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  } catch (_) {
    // Cache tetap dipakai ketika refresh jaringan gagal.
  }
}
