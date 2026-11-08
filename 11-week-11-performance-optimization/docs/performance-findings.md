# Temuan Profiling Performa

Dokumen ini mencatat hasil profiling aplikasi Offline Notes pada Minggu 11.
Pengujian dilakukan di emulator Medium_Phone (1080 x 2400) memakai
`flutter run --profile` dan Flutter DevTools.

## Metode

1. Aplikasi dijalankan dengan `flutter run --profile -d emulator-5554`.
2. DevTools dibuka pada tab **Performance**.
3. Database diisi 60 catatan agar daftar cukup panjang untuk diuji.
4. Skenario yang dipakai sama untuk baseline dan hasil optimasi:
   - buka daftar catatan,
   - scroll cepat 10 kali ke bawah,
   - scroll cepat 10 kali ke atas.
5. Panel **Flutter frames** dihentikan (pause), lalu screenshot dan detail
   frame disimpan.

## Baseline Week 10

Hasil rekaman sebelum optimasi:

- FPS rata-rata : 38 FPS
- Badge jank : 284 frame
- Contoh frame 17 : UI 2.1 ms, Raster 13.3 ms

Bukti tampilan : [before-profile.png](../screenshots/before-profile.png) dan
[before-frame-detail.png](../screenshots/before-frame-detail.png).

## Temuan

### 1. Widget ikut rebuild karena watch provider terlalu luas

`main.dart` membaca seluruh `AsyncValue` dari `darkModeProvider`, dan halaman
catatan membaca seluruh query pencarian. Akibatnya widget di luar kebutuhan
ikut dibangun ulang ketika status loading atau error berubah.

Perbaikan yang dipilih : `ref.watch(provider.select(...))` agar widget hanya
dibangun ulang saat nilai yang dipakai benar-benar berubah.

### 2. Paint dan layout berulang saat daftar di-scroll

Setiap kartu catatan berada dalam satu area paint yang sama. Ketika satu kartu
berubah, area sekitarnya berpotensi ikut digambar ulang. Hal yang sama terjadi
pada bubble chat saat teks streaming diperbarui.

Perbaikan yang dipilih : `RepaintBoundary` pada item daftar catatan, bubble
chat, dan kartu post.

### 3. Daftar panjang belum memakai lazy loading dan pagination

Daftar catatan sudah memakai `ListView.builder`, tetapi daftar post dari API
belum punya halaman. Semua data diambil sekaligus dan tidak ada batas jumlah.

Perbaikan yang dipilih : `ListView.builder` dengan `ScrollController`,
pagination 10 item per halaman, dan `RefreshIndicator`.

### 4. Gambar jaringan belum di-cache dan belum dibatasi ukurannya

Gambar post diambil dengan ukuran penuh. Ini membebani Raster Thread karena
proses decode gambar besar berulang kali.

Perbaikan yang dipilih : `CachedNetworkImage` dengan `memCacheWidth` dan
`memCacheHeight` sebesar 168 piksel, placeholder, dan `fadeInDuration`.

### 5. Request jaringan berulang tanpa fallback cache

Halaman post memanggil API setiap kali dibuka tanpa menyimpan hasil ke database
lokal. Ketika jaringan gagal, layar tidak punya data cadangan.

Perbaikan yang dipilih : metode `fetchPage` pada repository dengan strategi
network-first. Hasil API disimpan ke tabel `cached_posts`, lalu dipakai sebagai
fallback ketika jaringan gagal.

## Rencana Verifikasi

Setelah perbaikan diterapkan, skenario yang sama diulang. Hasilnya dibandingkan
pada FPS rata-rata, jumlah frame jank, dan waktu UI/Raster pada frame yang
dipilih. Detail hasil ada di [performance-report.md](performance-report.md).