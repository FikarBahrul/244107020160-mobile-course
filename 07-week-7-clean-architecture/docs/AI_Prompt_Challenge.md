# AI Prompt Challenge — Week 7

Dokumen ini memuat prompt, ringkasan output awal AI, tabel usulan-versus-keputusan
final, dan hasil tiga grep verifikasi. AI hanya dipakai untuk mengusulkan
reorganisasi; keputusan akhir dan justifikasinya ada di tangan saya.

## 1. Prompt yang digunakan

> Project Flutter saya: `week5_offline_notes` (catatan offline + pengaturan +
> cache posts). Kondisi kini: `lib/{data, pages}` dan `main.dart`, repository
> bercampur dengan implementasi, entity juga menyimpan mapping.
> Tugas: (1) usulkan struktur feature-first Clean Architecture
> (presentation/domain/data) untuk fitur notes dan settings; (2) untuk tiap file
> lama sebutkan tujuan barunya (pindah/pecah/hapus); (3) tandai bagian yang
> over-engineering bila diterapkan ke CRUD sederhana, dan kapan use case
> benar-benar dibutuhkan versus repository langsung; (4) tunjukkan wiring DI
> dengan Riverpod tanpa package DI tambahan. Jelaskan trade-off setiap keputusan.

## 2. Ringkasan output awal AI

AI mengusulkan struktur feature-first dengan tiga layer dan DI Riverpod, serta
memindahkan `Note` menjadi entity tanpa mapping. Namun AI awalnya juga membuat
use case untuk **setiap** operasi CRUD (`AddNote`, `UpdateNote`, `DeleteNote`)
dan menaruh pembuka database di `core/`.

## 3. Tabel usulan versus keputusan final

| Usulan AI | Keputusan final | Alasan |
|---|---|---|
| Struktur feature-first `presentation/domain/data` | Diterima | Project punya >1 fitur (notes, settings, posts) |
| Interface repository di `domain`, implementasi di `data` | Diterima | Menegakkan dependency rule |
| Entity murni, mapping di `model` | Diterima | Entity harus bebas Flutter/SQLite |
| Use case untuk tiap CRUD satu-baris | **Ditolak** | Over-engineering; cukup repository langsung ke notifier |
| Use case `GetNotes` dan `SyncNotes` | Diterima | `SyncNotes` memuat aturan bisnis (hitung dirty → upload → tandai bersih) |
| Pembuka database di `core/` | **Ditolak** | `core` harus steril framework (grep B); dipindah ke `data/datasources` |
| Wiring DI dengan Riverpod tanpa package DI tambahan | Diterima | Cukup `Provider`/`AsyncNotifierProvider` |

## 4. Perbaikan manual

1. **Pembuka database dipindah** dari `core/` ke
   `features/notes/data/datasources/local_database.dart` agar `core` bersih dari
   `sqflite` (grep B nol).
2. **`Dio()` dihilangkan dari presentation**: dibuat di dalam
   `PostRepositoryImpl` sehingga `posts_providers.dart` tidak menyentuh `Dio`
   (grep A nol).
3. **Use case CRUD dihapus**; `AddNote`/`UpdateNote`/`DeleteNote` tidak dibuat,
   sesuai checklist Jobsheet.
4. **Navigasi antar fitur lewat rute bernama** (`AppRoutes.settings`) agar
   `notes` tidak mengimpor widget milik `settings`.

## 5. AI Verification Checklist

| Butir verifikasi | Hasil |
|---|---|
| Interface repository di `domain`, implementasi di `data` | [Berhasil] |
| `domain` bebas import Flutter/Dio/SQLite/Firebase (grep B) | [Berhasil] — 0 hasil |
| Tidak membuat use case untuk tiap CRUD satu-baris | [Berhasil] — hanya GetNotes & SyncNotes |
| Entity bebas mapping (`toMap/fromMap` hanya di model) | [Berhasil] |
| Wiring DI terpusat di provider, widget tidak `new Repository()` | [Berhasil] |

## 6. Hasil tiga grep verifikasi

```text
# A. Presentation steril dari data mentah
rg "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode" \
   lib/features/*/presentation
=> 0 hasil

# B. Domain steril dari framework & package
rg "import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase" \
   lib/features/*/domain lib/core
=> 0 hasil

# C. Static analysis + test
flutter analyze  => No issues found!
flutter test     => All tests passed! (6 test)
```

## 7. Catatan

Keputusan paling penting adalah **menolak use case per CRUD satu-baris**. Untuk
aplikasi sekecil ini, lapisan use case pada setiap operasi hanya menambah file
dan indireksi tanpa nilai bisnis. Use case tetap dipertahankan untuk operasi yang
punya aturan (`SyncNotes`) dan operasi baca yang memang dijadikan contoh di
Jobsheet (`GetNotes`).