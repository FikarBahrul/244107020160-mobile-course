// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:week4_api/main.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';

class FakeWidgetPostRepository extends PostRepository {
  FakeWidgetPostRepository() : super(Dio());

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    return const [
      Post(userId: 1, id: 1, title: 'Test post', body: 'Body'),
    ];
  }
}

void main() {
  testWidgets('aplikasi menampilkan halaman posts', (WidgetTester tester) async {
    // ProviderScope diperlukan karena halaman memakai provider Riverpod.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(FakeWidgetPostRepository()),
        ],
        child: MyApp(),
      ),
    );

    // Frame pertama harus menampilkan halaman aplikasi tanpa exception.
    await tester.pump();
    expect(find.text('Posts Paged'), findsOneWidget);
  });
}
