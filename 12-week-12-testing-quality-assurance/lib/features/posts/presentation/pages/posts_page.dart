import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/post.dart';
import '../providers/posts_providers.dart';

class PostsPage extends ConsumerStatefulWidget {
  const PostsPage({super.key});

  @override
  ConsumerState<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends ConsumerState<PostsPage> {
  final _scrollController = ScrollController();
  final _items = <Post>[];
  var _page = 1;
  var _isLoading = false;
  var _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadPage();
    }
  }

  Future<void> _loadPage() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    try {
      final result = await ref.read(postRepositoryProvider).fetchPage(_page);
      final failure = result.failure;
      if (failure != null && _items.isEmpty) {
        _showError(failure.message);
        _hasMore = false;
        return;
      }
      final newItems = result.posts;
      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        _items.addAll(newItems);
        _page++;
      }
    } finally {
      _isLoading = false;
      if (mounted) setState(() {});
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jelajah Post')),
      body: RefreshIndicator(
        onRefresh: () async {
          _items.clear();
          _page = 1;
          _hasMore = true;
          await _loadPage();
        },
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          itemCount: _items.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _items.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return RepaintBoundary(child: PostTile(item: _items[index]));
          },
        ),
      ),
    );
  }
}

class PostTile extends StatelessWidget {
  const PostTile({super.key, required this.item});

  final Post item;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: SizedBox(
          width: 56,
          height: 56,
          child: CachedNetworkImage(
            imageUrl: 'https://picsum.photos/seed/${item.id}/300/300',
            placeholder: (context, url) => const ColoredBox(
              color: Color(0xFFE0E0E0),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (context, url, error) => const ColoredBox(
              color: Color(0xFFE0E0E0),
              child: Icon(Icons.image_not_supported_outlined),
            ),
            memCacheWidth: 168,
            memCacheHeight: 168,
            fadeInDuration: const Duration(milliseconds: 200),
            fit: BoxFit.cover,
          ),
        ),
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(item.body, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
