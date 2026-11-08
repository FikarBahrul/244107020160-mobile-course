# Laporan Optimasi Performa

Laporan ini menjelaskan baseline, optimasi, dan hasil verifikasi pada project
Offline Notes Minggu 11. Pengujian memakai emulator Medium_Phone dengan mode
profile, bukan mode debug.

## Lingkungan Pengujian

| Komponen | Keterangan |
|---|---|
| Perangkat | Emulator Medium_Phone 1080 x 2400 |
| Flutter | 3.47.2 stable |
| Dart | 3.13.2 |
| Engine | Impeller OpenGLES |
| Mode | `flutter run --profile` |
| Alat | Flutter DevTools tab Performance |
| Data uji | 60 catatan lokal |

## Baseline Metrics

Baseline diambil dari project Minggu 10 sebelum optimasi, dengan skenario scroll
10 kali ke bawah dan 10 kali ke atas.

| Metrik | Baseline Week 10 |
|---|---|
| FPS rata-rata | 38 FPS |
| Frame jank | 284 |
| Frame contoh | UI 2.1 ms, Raster 13.3 ms |

Bukti : [before-profile.png](../screenshots/before-profile.png) dan
[before-frame-detail.png](../screenshots/before-frame-detail.png).

## Optimasi yang Diterapkan

### 1. Riverpod `select`

Lokasi : `lib/main.dart`, `lib/features/notes/presentation/pages/notes_page.dart`,
`lib/features/chat_screen.dart`.

Perubahan : status tema, query pencarian, dan status kunci API dibaca memakai
`select`. Widget hanya rebuild ketika nilai yang dipakai berubah.

Alasan : pada baseline, perubahan status loading atau error ikut membangun ulang
widget yang tidak membutuhkannya.

### 2. Ekstrak widget dan `const`

Lokasi : `lib/features/notes/presentation/pages/notes_page.dart` dan
`lib/features/posts/presentation/pages/posts_page.dart`.

Perubahan : `_EmptyNotes` dipisah menjadi `ConsumerWidget` yang membaca query
sendiri. `PostTile` dibuat sebagai widget terpisah dengan placeholder dan
error widget `const`.

Alasan : widget kecil yang mandiri mengurangi cakupan rebuild dan memudahkan
pemakaian `const`.

### 3. `RepaintBoundary`

Lokasi : daftar catatan, bubble chat, dan daftar post.

Perubahan : setiap item dibungkus `RepaintBoundary`.

Alasan : saat scroll atau saat teks chat streaming, hanya item yang berubah yang
digambar ulang. Area lain tidak ikut repaint.

### 4. `ListView.builder` dan pagination

Lokasi : `lib/features/posts/presentation/pages/posts_page.dart` dan
`lib/features/posts/data/repositories/post_repository_impl.dart`.

Perubahan : daftar post memakai `ListView.builder` dengan `ScrollController`.
Data diambil 10 per halaman melalui `fetchPage`, ditambah indikator loading di
bawah dan `RefreshIndicator`.

Alasan : item hanya dibangun saat terlihat dan data tidak diambil sekaligus.

### 5. `CachedNetworkImage`

Lokasi : `PostTile` pada halaman post.

Perubahan : gambar memakai `CachedNetworkImage` dengan `memCacheWidth` dan
`memCacheHeight` 168 piksel, placeholder abu-abu, `errorWidget`, dan
`fadeInDuration` 200 ms.

Alasan : decode gambar dibatasi pada ukuran tampil dan gambar yang sudah pernah
diunduh tidak diunduh ulang.

### 6. Cache repository

Lokasi : `lib/features/posts/data/repositories/post_repository_impl.dart`.

Perubahan : `fetchPage` memakai strategi network-first. Hasil API disimpan ke
tabel `cached_posts`. Jika jaringan gagal, data diambil dari cache. Jika cache
juga kosong, repository mengembalikan `NetworkFailure` yang ramah.

Alasan : aplikasi tetap menampilkan data saat offline dan tidak melakukan
request berulang tanpa menyimpan hasil.

## Hasil Verifikasi

Rekaman ulang dengan skenario yang sama pada project Minggu 11 menghasilkan:

| Metrik | Baseline Week 10 | Setelah Optimasi |
|---|---|---|
| FPS rata-rata | 38 FPS | 40 FPS |
| Frame jank | 284 | 228 |
| Waktu UI contoh | 2.1 ms | 1.2 ms |
| Waktu Raster contoh | 13.3 ms | 26.1 ms |

Bukti : [after-profile.png](../screenshots/after-profile.png) dan
[after-frame-detail.png](../screenshots/after-frame-detail.png).

## Keterbatasan Pengukuran

Angka di atas berasal dari emulator, bukan perangkat fisik. Raster Thread pada
emulator memakai renderer software sehingga waktunya naik turun dan tidak bisa
dijadikan patokan mutlak. Frame contoh yang dipilih juga berbeda, jadi
perbandingan UI dan Raster bersifat indikatif.

Meskipun begitu, arah perubahannya konsisten : jumlah frame jank turun, FPS
rata-rata naik, dan waktu UI pada frame contoh turun. Perbaikan struktur kode
juga bisa diverifikasi langsung, yaitu `select`, `RepaintBoundary`,
`ListView.builder`, pagination, `CachedNetworkImage`, dan fallback cache.

## Catatan Pengujian Unit

```text
dart format --output=none --set-exit-if-changed lib test  -> 0 file berubah
flutter analyze                                             -> No issues found
flutter test                                                -> 27 test lulus
```