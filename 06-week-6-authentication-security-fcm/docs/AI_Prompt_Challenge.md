# AI Prompt Challenge — Week 6

Dokumen ini memuat prompt, ringkasan output awal AI, daftar perbaikan manual, dan
hasil pengujian tiga app state. Sesuai kebijakan codelab, AI hanya dipakai untuk
membuat kerangka awal; perilaku FCM tetap diverifikasi manual di perangkat fisik.

## 1. Prompt yang digunakan

> Aplikasi Flutter Campus Notification App. Stack: `firebase_messaging`,
> `flutter_local_notifications`, `flutter_secure_storage`, `go_router`, Riverpod.
> Buatkan `PushService` dengan: `requestPermission` + `getToken` + `onTokenRefresh`
> (kirim ke POST /devices); `onMessage` (tampilkan local notification manual);
> `onMessageOpenedApp` + `getInitialMessage` (navigasi ke `data.route`);
> `subscribe`/`unsubscribe` topik `pengumuman-kampus`; background handler
> top-level dengan `@pragma('vm:entry-point')`. Tandai bagian yang BERBEDA untuk
> Android 13+ vs iOS, dan bagian yang tidak boleh mengakses `BuildContext`.

## 2. Ringkasan output awal AI

AI menghasilkan kerangka: `TokenStore` (flutter_secure_storage), `AuthRepository`
(mock login/refresh), `buildApiClient` (Dio + interceptor 401 → refresh sekali),
`AuthNotifier` (Riverpod `AsyncNotifier`), `PushService`, dan guard `GoRouter`.
Strukturnya sudah mengikuti pola Jobsheet, tetapi perlu penyesuaian pada beberapa
titik karena perbedaan versi package dan kebutuhan pengujian nyata.

## 3. Perbaikan manual dan keputusan teknis

1. **`flutter_local_notifications` versi 22** — `initialize` dan `show` memakai
   parameter bernama (`settings:`, `id:`, `notificationDetails:`), berbeda dari
   contoh Jobsheet yang masih posisional. Disesuaikan ke API versi terpasang.
2. **Klik banner foreground** — Jobsheet hanya menyimpan `pendingDeepLink`. Karena
   `handleTerminated` hanya dipanggil sekali saat start, ditambahkan
   `deepLinkHandler` agar klik banner foreground langsung menuju `data.route`.
3. **Guard route** — `redirect` membaca `authStateProvider` yang awalnya masih
   `AsyncLoading`. Ditambahkan `refreshListenable` (`ValueNotifier`) supaya router
   mengevaluasi ulang setelah status login selesai dibaca dari secure storage.
4. **Plugin `google-services`** — diterapkan secara kondisional (hanya bila
   `android/app/google-services.json` ada) agar aplikasi tetap dapat dibuild
   sebelum konfigurasi Firebase terpasang.
5. **Core library desugaring** — diaktifkan (`desugar_jdk_libs 2.1.4`) karena
   disyaratkan `flutter_local_notifications` versi 22.
6. **Keamanan token** — token tidak dicetak ke log. Di layar debug hanya
   ditampilkan 12 karakter pertama (`cnsxsiDZQRQy...`).

## 4. AI Verification Checklist

| Butir verifikasi | Hasil |
|---|---|
| Background handler berupa fungsi top-level `@pragma('vm:entry-point')` | [Berhasil] |
| `onTokenRefresh` benar-benar mengirim token ke backend (POST /devices), bukan hanya log | [Berhasil] |
| Foreground memakai local notification manual | [Berhasil] |
| Klik dari 3 state masuk ke rute yang benar | [Berhasil] — lihat tabel |
| Token/secret tidak di-hardcode dan tidak di-log penuh | [Berhasil] |

## 5. Tabel hasil uji tiga app state

Payload yang dikirim (FCM HTTP v1): `notification {title, body}` +
`data {route: /pengumuman/3, id: 3}`, target topik `pengumuman-kampus`.

| State | Yang diharapkan | Cara uji | Hasil |
|---|---|---|---|
| Foreground | Banner lokal muncul, klik masuk `/pengumuman/3` | Aplikasi terbuka, kirim dari FCM API | [Berhasil] |
| Background | Banner sistem muncul, klik masuk rute benar | Tekan Home, kirim, klik banner | [Berhasil] |
| Terminated | Aplikasi terbuka ke rute benar via `getInitialMessage` | Tutup aplikasi (`am kill`), kirim, klik banner | [Berhasil] |

## 6. Catatan tanggung jawab teknis

Bagian yang tidak tersedia di Jobsheet dan ditambahkan sendiri adalah
`deepLinkHandler`, `refreshListenable`, penerapan `google-services` kondisional,
dan desugaring. Sisanya mengikuti pola dan penamaan Jobsheet.