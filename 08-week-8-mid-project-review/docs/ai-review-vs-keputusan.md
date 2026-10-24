# AI Review versus Keputusan Final — Week 8

Dokumen ini memuat prompt review, ringkasan temuan awal AI, tabel
usulan-versus-keputusan, dan bukti untuk setiap temuan. AI dipakai sebagai
reviewer awal; keputusan akhir tetap milik saya.

## 1. Prompt yang dipakai

> Review PR Flutter ini sebagai senior Flutter dev.
> Konteks: feature-first Clean Architecture (presentation -> domain <- data),
> Riverpod, GoRouter, SQLite + Dio.
> Fokus: kebenaran, arsitektur, dan test. Abaikan style.
> Berikan 5 temuan teratas + level (blocker/saran) + alasan + usulan potongan
> kode perbaikan.

## 2. Ringkasan output awal AI

AI menyoroti validasi judul pada dialog catatan, resiko judul kosong, dan
kelengkapan test. Selain itu AI juga mengusulkan penambahan use case per CRUD
dan penggantian provider Riverpod — dua usulan yang kemudian saya tolak karena
bertabrakan dengan keputusan Minggu 7.

### Kutipan output awal AI

```text
1. [blocker] Judul berisi spasi saja masih bisa tersimpan karena pengecekan
   memakai title.isNotEmpty tanpa trim(). Usul: title.trim().isEmpty lalu
   tampilkan pesan error.
2. [saran] Validasi diletakkan di dalam widget (_showEditor) sehingga sulit
   diunit-test. Usul: pindahkan ke fungsi murni core/validate.dart.
3. [saran] Pesan error tidak hilang saat pengguna mengetik ulang. Usul: reset
   errorText lewat onChanged.
4. [saran] Tambahkan use case AddNote/UpdateNote agar konsisten dengan layer
   domain.
5. [saran] Ganti AsyncNotifierProvider dengan StateNotifierProvider.
```

## 3. Tabel usulan versus keputusan final

| # | Temuan AI | Level | Keputusan | Alasan / bukti |
|---|---|---|---|---|
| 1 | Judul berisi spasi saja masih bisa tersimpan | blocker | **Diterima** | Dicek `title.isNotEmpty` tanpa `trim()`. Diperbaiki dengan `trim()` |
| 2 | Validasi di dalam widget sulit diunit-test | saran | **Diterima** | Dipindah ke `core/validate.dart` sebagai fungsi murni |
| 3 | Pesan error tidak hilang saat input diperbaiki | saran | **Diterima** | `errorText` direset lewat `setDialogState` saat Simpan lolos |
| 4 | Tambahkan use case `AddNote`/`UpdateNote` agar konsisten | saran | **Ditolak** | Melanggar keputusan Minggu 7: use case per CRUD satu-baris = over-engineering |
| 5 | Ganti `AsyncNotifierProvider` ke `StateNotifierProvider` | saran | **Ditolak** | Riverpod 3 sudah menghapus pola `StateProvider`/`StateNotifier`; provider sekarang valid dan analyze bersih |

## 4. Bukti temuan yang diterima

Temuan 1 dan 2 dibuktikan lewat test:

```text
# sebelum perbaikan: judul "   " mengembalikan null (lolos)
# sesudah perbaikan:
test/validate_note_test.dart
  ✓ judul kosong mengembalikan pesan error
  ✓ judul yang hanya berisi spasi dianggap kosong
  ✓ judul berisi teks dinyatakan valid
All tests passed! (9 test)
```

Temuan 3 diverifikasi manual di perangkat (emulator Medium_Phone):
`screenshots/P2_01_validasi_judul_kosong.png` menampilkan pesan error, dan
`screenshots/P2_02_catatan_tersimpan.png` membuktikan judul valid tersimpan.

## 5. Bukti penolakan

- **Temuan 4 ditolak.** Use case untuk CRUD satu-baris menambah file dan
  indireksi tanpa aturan bisnis. Minggu 7 sudah memutuskan CRUD langsung ke
  repository; `domain` tetap berisi hanya `GetNotes` dan `SyncNotes`.
- **Temuan 5 ditolak.** Mengganti `AsyncNotifierProvider` akan membuat
  `notesProvider` kehilangan status `AsyncValue` (loading/error/data) yang
  dipakai halaman. `flutter analyze` bersih dengan provider sekarang, jadi
  tidak ada alasan teknis untuk menggantinya.

## 6. Checklist verifikasi

| Butir | Hasil |
|---|---|
| Temuan benar-benar ada (dibuktikan test/reproduksi) | [Berhasil] temuan 1, 2, 3 |
| Usulan tidak melanggar dependency rule | [Berhasil] `domain`/`core` tetap tanpa import Flutter/Dio/SQLite |
| AI bukan hanya nitpick style | [Berhasil] formatter tetap menangani style |
| Minimal 2 temuan benar + 1 ditolak | [Berhasil] 3 diterima, 2 ditolak |
| Keputusan final punya alasan teknis | [Berhasil] |

## 7. Catatan

Temuan paling berharga dari AI adalah pemindahan validasi ke fungsi murni
`core/validate.dart`, karena hal itu langsung membuka jalan untuk unit test
tanpa widget. Sebaliknya, usulan yang menambah lapisan (use case per CRUD) saya
tolak: menambah kode bukan berarti menambah mutu.