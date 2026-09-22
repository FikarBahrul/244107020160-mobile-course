import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier untuk mengatur state data statistik tugas.
// State yang digunakan adalah AsyncValue<List<String>>
// karena proses pengambilan data bersifat asynchronous.
class StatsNotifier extends AsyncNotifier<List<String>> {
  // Fungsi build() dijalankan saat provider pertama kali digunakan.
  // Fungsi ini bertugas mengambil dan mengembalikan data statistik.
  @override
  Future<List<String>> build() async {
    // Simulasi proses mengambil data dari server selama 2 detik.
    await Future.delayed(
      const Duration(seconds: 2),
    );

    // Membuat objek Random untuk menghasilkan angka secara acak.
    final random = Random();

    // Simulasi kemungkinan gagal mengambil data.
    // Angka acak 0-9 dibuat, kemudian jika hasilnya kurang dari 3
    // maka akan terjadi error.
    if (random.nextInt(10) < 3) {
      throw Exception(
        'Gagal mengambil data statistik',
      );
    }

    // Data statistik dikembalikan jika proses berhasil.
    return [
      'Total tugas: 10',
      'Tugas selesai: 6',
      'Tugas belum selesai: 4',
    ];
  }

  // Fungsi retry() digunakan untuk mencoba mengambil data kembali
  // ketika terjadi error.
  Future<void> retry() async {
    // Mengubah state menjadi loading agar UI menampilkan
    // indikator proses loading kembali.
    state = const AsyncLoading();

    // Menjalankan kembali fungsi build().
    // AsyncValue.guard() digunakan untuk menangani hasil sukses
    // maupun error secara otomatis.
    state = await AsyncValue.guard(
          () => build(),
    );
  }
}

// Provider yang menyediakan StatsNotifier ke dalam aplikasi.
// Provider ini menghasilkan state berupa List<String>.
final statsProvider = AsyncNotifierProvider<
    StatsNotifier,
    List<String>>(
  StatsNotifier.new,
);