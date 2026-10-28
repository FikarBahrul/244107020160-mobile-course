# AI Log - Week 9

Dokumen ini mencatat prompt, konteks, output awal AI, cara verifikasi, dan
keputusan akhir untuk fitur **pencarian judul catatan**. AI dipakai sebagai
pembuat draf dan reviewer awal; keputusan tetap diambil setelah kode dibaca,
diuji, dan dijelaskan.

## 1. Prompt yang dipakai (formula 5 slot)

```text
Peran: senior Flutter developer yang disiplin soal Clean Architecture.
Konteks: project Offline Notes feature-first (presentation -> domain <- data),
  Riverpod 3.4.3, sqflite, Dio. Entity Note dan NoteRepository sudah ada.
Tugas: tambah pencarian judul catatan + empty state saat hasil kosong.
Batas: jangan ubah arsitektur, jangan panggil SQLite dari widget,
  jangan tambah package baru, maksimal 80 baris.
Output: kode + minimal 3 test case + cara menguji.
```

## 2. Konteks yang ditempel

Yang diberikan ke AI hanya potongan yang relevan, bukan seluruh repo:

```text
lib/features/notes/
├── domain/
│   ├── entities/note.dart
│   ├── repositories/note_repository.dart
│   └── usecases/get_notes.dart, sync_notes.dart
├── data/
│   ├── datasources/local_database.dart
│   ├── models/note_model.dart
│   └── repositories/note_repository_impl.dart
└── presentation/
    ├── pages/notes_page.dart
    └── providers/notes_providers.dart
```

Kontrak yang tidak boleh berubah:

```dart
class Note {
  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;
}
```

Versi package dari `pubspec.yaml`: `flutter_riverpod 3.4.3`, `sqflite
2.4.4+1`, `dio 5.11.1`, `shared_preferences 2.5.6`, `go_router 18.0.2`.

Tidak ada token, API key, atau secret yang ditempel. Nilai rahasia selalu
diganti placeholder.

## 3. Output awal AI

AI mengusulkan satu use case murni di layer domain:

```dart
class SearchNotes {
  const SearchNotes();

  List<Note> call(List<Note> notes, String query) {
    if (query.isEmpty) return notes;
    return notes
        .where((note) => note.title.contains(query, caseSensitive: false))
        .toList();
  }
}
```

Draf ini **tidak langsung diterima**. Ada satu API yang tidak ada di Dart dan
satu aturan yang belum benar.

## 4. Verifikasi 6 langkah

| Langkah | Yang dilakukan | Hasil |
|---|---|---|
| 1 | Baca tiap baris, tandai yang belum dipahami | `caseSensitive` dan `query.isEmpty` ditandai |
| 2 | Cek import | `domain/usecases/search_notes.dart` hanya mengimpor `../entities/note.dart`; tidak ada Flutter, Dio, atau sqflite |
| 3 | Cek API nyata | `String.contains` di Dart SDK tidak punya parameter `caseSensitive` |
| 4 | `flutter analyze` | Gagal pada draf, lalu bersih setelah diperbaiki |
| 5 | Test | 4 unit test search + 1 widget test empty state |
| 6 | Uji manual | Query kosong, cocok, dan tidak cocok di emulator |

## 5. Halusinasi yang ditemukan dan buktinya

**Method fiktif:** AI memakai `title.contains(query, caseSensitive: false)`.
Parameter `caseSensitive` tidak pernah ada pada `String.contains`.

Bukti dari `flutter analyze` (log mentah:
[`evidence/analyze-halusinasi.txt`](evidence/analyze-halusinasi.txt)):

```text
error - The named parameter 'caseSensitive' isn't defined.
lib/features/notes/domain/usecases/search_notes.dart:11:53
- undefined_named_parameter
1 issue found.
```

Bukti dari kode sumber Dart SDK di mesin ini:

```text
lib/core/string.dart:500
bool contains(Pattern other, [int startIndex = 0]);
```

Artinya parameter hanya `other` dan `startIndex`. Tidak ada `caseSensitive`.
Perbaikannya bukan menambah parameter, tetapi mengubah huruf besar/kecil
sebelum dibandingkan.

## 6. Debug dengan test merah

Setelah error kompilasi dibereskan, AI masih meninggalkan dua bug logika:

- `query` tidak diubah ke huruf kecil, sehingga `"Belanja"` tidak cocok dengan
  `"belanja"`.
- `query` berisi spasi (`"   "`) dianggap tidak kosong, sehingga hasilnya
  kosong padahal seharusnya semua catatan tampil.

Test dibuat lebih dulu, lalu dijalankan. Hasilnya merah (log mentah:
[`evidence/test-merah.txt`](evidence/test-merah.txt)):

```text
filter abaikan huruf besar/kecil [E]
  Expected: an object with length of <2>
  Actual: has length of <1>

query berisi spasi saja dianggap kosong [E]
  Expected: an object with length of <3>
  Actual: has length of <0>

Some tests failed.
```

Perbaikan kecil di use case:

```dart
List<Note> call(List<Note> notes, String query) {
  final keyword = query.trim().toLowerCase();
  if (keyword.isEmpty) return notes;
  return notes
      .where((note) => note.title.toLowerCase().contains(keyword))
      .toList();
}
```

Setelah itu keempat unit test hijau. Log akhir ada di
[`evidence/test-hijau.txt`](evidence/test-hijau.txt).

## 7. Uji manual dan screenshot

Data uji: **Belanja mingguan**, **Ide proyek**, dan **Jadwal kuliah**.

| Query | Hasil yang terlihat | Bukti |
|---|---|---|
| kosong | Ketiga catatan tampil | [`P2_01_query_kosong.png`](../screenshots/P2_01_query_kosong.png) |
| `belanja` | Hanya **Belanja mingguan** yang tampil | [`P2_02_query_cocok.png`](../screenshots/P2_02_query_cocok.png) |
| `zzz` | Empty state "Catatan tidak ditemukan" | [`P2_03_query_tidak_cocok.png`](../screenshots/P2_03_query_tidak_cocok.png) |

Query `belanja` memakai huruf kecil, sedangkan judul catatan memakai huruf
besar `B`. Hasilnya tetap cocok, jadi sifat abaikan huruf besar/kecil terbukti
di perangkat, bukan hanya di test.

## 8. Keputusan akhir per file

| File | Keputusan | Alasan |
|---|---|---|
| `domain/usecases/search_notes.dart` | **Terima + refactor** | Logika filter dipindah ke domain murni agar bisa diuji tanpa UI |
| `presentation/providers/notes_providers.dart` | **Terima sebagian** | Provider query dan hasil filter dipakai; usulan mengganti `AsyncNotifierProvider` ditolak |
| `presentation/pages/notes_page.dart` | **Terima + refactor** | Widget hanya menampilkan state dan mengirim query, bukan menghitung filter |
| `test/search_filter_test.dart` | **Terima** | Mengunci aturan huruf besar/kecil dan query kosong |
| `test/search_widget_test.dart` | **Terima** | Membuktikan empty state muncul di UI |

## 9. Penjelasan (tanpa membuka AI)

- **Pencarian itu menyaring, bukan mengambil ulang.** Semua catatan sudah ada
  di HP. Saat mengetik, aplikasi hanya memilih catatan yang judulnya memuat
  kata kunci. Tidak ada permintaan ulang ke database atau internet.
- **`trim()` membuang spasi di ujung.** Kalau pengguna hanya mengetik spasi,
  setelah dibuang isinya kosong, jadi aplikasi menampilkan semua catatan.
- **`toLowerCase()` menyamakan besar-kecil huruf.** `"Belanja"` dan `"belanja"
  dianggap sama, sehingga pencarian tidak gagal hanya karena huruf besar.
- **Halusinasi AI itu seperti menu yang tidak ada di restoran.** AI percaya ada
  parameter `caseSensitive`, padahal Dart tidak menyediakannya. Cara
  membuktikannya bukan dengan percaya, tetapi dengan `flutter analyze` dan
  melihat signature asli di SDK.
- **Use case murni memudahkan ujian.** Aturan pencarian dipindah ke fungsi
  yang tidak bergantung pada HP, UI, atau database. Karena itu bisa diuji
  cepat dan hasilnya pasti.
- **Empty state bukan hiasan.** Saat tidak ada hasil, pengguna perlu tahu
  bahwa pencariannya nihil, bukan aplikasi rusak atau datanya hilang.

## 10. Daftar bukti

- `docs/evidence/analyze-halusinasi.txt` - analyze gagal pada draf AI.
- `docs/evidence/test-merah.txt` - dua test gagal sebelum perbaikan.
- `docs/evidence/analyze-hijau.txt` - analyze bersih setelah perbaikan.
- `docs/evidence/test-hijau.txt` - seluruh test lulus.
- `docs/evidence/format-hijau.txt` - formatter tidak mengubah file.
- `screenshots/P2_01_query_kosong.png` sampai `P2_03_query_tidak_cocok.png` -
  uji manual tiga query.