import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pengumuman #$id')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.campaign, size: 64, color: Colors.indigo),
            const SizedBox(height: 16),
            Text(
              'Pengumuman kampus #$id',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'Jadwal kuliah berubah. Kelas Mobile pindah ke Ruang A2 jam 13.00.',
            ),
            const SizedBox(height: 24),
            const Text(
              'Halaman ini dibuka lewat deep link dari notifikasi FCM.',
            ),
          ],
        ),
      ),
    );
  }
}
