import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../providers/fcm_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupPush());
  }

  Future<void> _setupPush() async {
    if (Firebase.apps.isEmpty) return;
    try {
      await requestNotificationPermission();
      await initFcmToken(onToken: _sendTokenToBackend);
      listenForeground((route) {
        if (mounted) context.go(route);
      });
      deepLinkHandler = (route) {
        if (mounted) context.go(route);
      };
      await handleTerminated((route) {
        if (mounted) context.go(route);
      });
    } catch (e) {
      debugPrint('FCM belum aktif: $e');
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    ref.read(fcmTokenProvider.notifier).set(token);
    try {
      await ref
          .read(apiClientProvider)
          .post('/devices', data: {'fcm_token': token, 'platform': 'android'});
    } catch (_) {
      // Endpoint kampus belum tersedia; token tetap diperbarui di layar debug.
    }
  }

  Future<void> _subscribe() async {
    if (Firebase.apps.isEmpty) return;
    await subscribeAnnouncementTopic();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscribed pengumuman-kampus')),
      );
    }
  }

  Future<void> _unsubscribe() async {
    if (Firebase.apps.isEmpty) return;
    await unsubscribeAnnouncementTopic();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unsubscribed pengumuman-kampus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(fcmTokenProvider);
    final shortToken = token == null
        ? 'menunggu token...'
        : '${token.substring(0, token.length < 12 ? token.length : 12)}...';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.key),
              title: const Text('FCM Token (debug)'),
              subtitle: Text(shortToken),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.notifications_active),
                  title: Text('Langganan topik'),
                  subtitle: Text('pengumuman-kampus'),
                ),
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _subscribe,
                      child: const Text('Subscribe'),
                    ),
                    TextButton(
                      onPressed: _unsubscribe,
                      child: const Text('Unsubscribe'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.announcementFor('3')),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Buka /pengumuman/3'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Status: login berhasil. Token disimpan di secure storage '
            'dan dikirim ke backend (POST /devices).',
          ),
        ],
      ),
    );
  }
}
