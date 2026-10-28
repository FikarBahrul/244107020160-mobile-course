# AI Challenge - Review Kode Search

AI dipakai sebagai reviewer awal untuk kode pencarian. Hasil review tidak
diterima mentah: setiap temuan dicek dengan kode, `grep`, atau test. Dokumen ini
memuat prompt, output mentah review AI, temuan, keputusan, dan buktinya.

## 1. Prompt review

```text
Review kode search Flutter ini sebagai senior dev.
Konteks: feature-first (presentation -> domain <- data), Riverpod, SQLite.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Beri 3 temuan + level blocker/saran + alasan.
```

File yang direview:

- `lib/features/notes/domain/usecases/search_notes.dart`
- `lib/features/notes/presentation/providers/notes_providers.dart`
- `lib/features/notes/presentation/pages/notes_page.dart`

## 2. Output mentah review AI

Kutipan berikut disalin dari jawaban reviewer AI, tanpa dirapikan. Output ini
masih berupa usulan, jadi belum tentu benar.

```text
Review kode search Offline Notes (feature-first, Riverpod, SQLite).
Fokus: kebenaran, arsitektur, dan test. Style diabaikan.

1. [blocker] SearchNotes hanya memeriksa query.isEmpty. Query berisi spasi
   ("   ") ikut diproses sehingga hasilnya bisa kosong padahal pengguna tidak
   mencari apa pun. Usulanku : final keyword = query.trim().toLowerCase();
   if (keyword.isEmpty) return notes;

2. [blocker] Pastikan aturan filter tidak ikut ditulis di widget. Kalau widget
   memanggil toLowerCase().contains() langsung, aturan sulit diuji dan mudah
   berbeda antar layar. Usulanku : pertahankan filter di use case murni SearchNotes
   dan tambahkan test unit untuk aturannya.

3. [saran] Gabungkan query ke NotesNotifier supaya semua state ada di satu
   tempat. Usulanku : tambah field query dan hasil filter pada notifier.

4. [saran] Pindahkan pencarian ke SQL dengan WHERE title LIKE ? agar database
   yang menyaring. Usulanku : tambah method searchNotes(query) di repository.

5. [saran] Gunakan package fuzzy search agar pencarian lebih toleran salah
   ketik. Usulanku : tambah dependency baru dan ganti contains().
```

## 3. Temuan AI dan keputusan

| # | Temuan AI | Level | Keputusan | Alasan teknis |
|---|---|---|---|---|
| 1 | Query hanya dicek `isEmpty`, sehingga spasi saja dianggap pencarian valid | blocker | **Diterima** | `trim()` membuat spasi saja dianggap kosong; dibuktikan test merah |
| 2 | Filter masih berpotensi tinggal di widget sehingga sulit diuji | blocker | **Diterima + refactor** | Filter dipindah ke `SearchNotes` di domain; widget hanya mengirim query |
| 3 | Gabungkan query ke `NotesNotifier` agar semua state di satu tempat | saran | **Ditolak** | Query adalah state sementara UI, sedangkan `NotesNotifier` menyimpan `AsyncValue<List<Note>>`; menggabungkan keduanya membuat bentuk state rumit dan memicu rebuild data saat mengetik |
| 4 | Pindahkan pencarian ke SQL (`WHERE title LIKE ?`) | saran | **Ditolak** | Daftar catatan sudah ada di memori; query SQL per ketikan menambah I/O dan mengikat aturan UI ke repository, padahal datanya kecil |
| 5 | Tambahkan package fuzzy search | saran | **Ditolak** | Kebutuhan hanya substring judul; menambah dependency berarti menambah ukuran aplikasi dan risiko versi tanpa manfaat nyata |

Jumlah: **2 diterima** dan **3 ditolak**. Dua-duanya punya alasan yang bisa
dijelaskan tanpa membuka AI.

## 4. Bukti temuan yang diterima

### Temuan 1 - spasi dianggap pencarian

Sebelum diperbaiki, test ini gagal:

```text
query berisi spasi saja dianggap kosong [E]
  Expected: an object with length of <3>
  Actual: []
```

Setelah `query.trim()` ditambahkan, test hijau. Log lengkap:
[`evidence/test-merah.txt`](evidence/test-merah.txt) dan
[`evidence/test-hijau.txt`](evidence/test-hijau.txt).

### Temuan 2 - filter harus di domain

Hasil `grep` pada widget:

```text
lib/features/notes/presentation/pages/notes_page.dart
(kosong: tidak ada toLowerCase atau .where())
```

Hasil `grep` pada domain:

```text
lib/features/notes/domain/usecases/search_notes.dart:7
final keyword = query.trim().toLowerCase();

lib/features/notes/domain/usecases/search_notes.dart:10
.where((note) => note.title.toLowerCase().contains(keyword))
```

Artinya aturan pencarian hanya ada di satu tempat, yaitu use case murni.
Widget tidak tahu cara memfilter; ia hanya meminta hasil yang sudah disaring.

## 5. Bukti penolakan

- **Temuan 3 ditolak.** `NotesNotifier` sudah memegang `AsyncValue<List<Note>>`
  yang berisi loading, error, dan data. Kalau query dimasukkan ke sana, setiap
  ketikan akan mengubah state data dan berisiko memicu ulang pemuatan. Sekarang
  query punya provider sendiri, jadi perubahan huruf tidak menyentuh database.
- **Temuan 4 ditolak.** Pencarian SQL masuk akal untuk data besar, tetapi di
  sini seluruh catatan sudah dimuat untuk ditampilkan. Menambah query SQL per
  ketikan justru membuat aplikasi lebih lambat dan melanggar pemisahan: UI
  seharusnya tidak menentukan cara database mencari.
- **Temuan 5 ditolak.** Fuzzy search bisa berguna nanti, tetapi bukan kebutuhan
  codelab. Menambah package hanya untuk mencocokkan substring adalah
  over-engineering.

## 6. Keputusan per file

| File | Keputusan | Catatan |
|---|---|---|
| `search_notes.dart` | Diterima + refactor | Fungsi murni, tanpa Flutter/Dio/SQLite |
| `notes_providers.dart` | Diterima sebagian | Tambah provider query dan hasil filter; tidak menggabungkan ke notifier |
| `notes_page.dart` | Diterima + refactor | Search field dan empty state; tanpa logika filter |
| `search_filter_test.dart` | Diterima | Empat kasus: cocok, tidak cocok, kosong, spasi |
| `search_widget_test.dart` | Diterima | Empty state saat query tidak cocok |

## 7. Penjelasan Kausalitas

1. **Kenapa memakai use case?** "Supaya aturan pencarian tidak menempel di
   tampilan. Kalau aturannya salah, saya bisa mengujinya langsung tanpa
   menjalankan aplikasi."
2. **Kenapa query tidak dimasukkan ke notifier?** "Notifier itu tempat data
   catatan. Query hanya kata kunci sementara. Kalau dicampur, setiap ketikan
   bisa dianggap perubahan data dan memicu pekerjaan yang tidak perlu."
3. **Kenapa tidak mencari di SQL?** "Datanya sudah ada di layar. Mencari di
   memori lebih sederhana dan tidak menambah beban baca database."
4. **Kenapa menolak fuzzy search?** "Yang diminta hanya pencarian judul biasa.
   Menambah library berarti menambah berat aplikasi tanpa kebutuhan yang jelas."
5. **Apa halusinasi yang ditemukan?** "AI mengira `contains` punya parameter
   `caseSensitive`. Saya cek di SDK, parameternya hanya `other` dan
   `startIndex`. Setelah itu saya samakan huruf dengan `toLowerCase()`."

## 8. Checklist verifikasi

| Butir | Hasil |
|---|---|
| Minimal 1 temuan terbukti benar lalu diperbaiki | [Berhasil] temuan 1 dan 2 |
| Minimal 1 temuan ditolak dengan alasan teknis | [Berhasil] temuan 3, 4, dan 5 |
| Output mentah review AI tersimpan | [Berhasil] lihat bagian 2 |
| Keputusan tiap file tercatat | [Berhasil] lihat bagian 6 |
| Bisa menjelaskan tanpa membuka AI | [Berhasil] lihat bagian 7 |
| `flutter analyze` bersih dan test hijau | [Berhasil] lihat `docs/evidence/` |