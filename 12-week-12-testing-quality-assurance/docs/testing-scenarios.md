# Skenario Pengujian Minggu 12

Dokumen ini mencatat perilaku yang diuji pada fitur utama, yaitu daftar
catatan. Skenario disusun dari logika sampai alur aplikasi.

## 1. Perilaku yang diuji

| No | Perilaku | Jenis | Hasil yang diharapkan |
|---|---|---|---|
| 1 | Judul catatan berisi teks | Unit | Valid, tidak ada pesan error |
| 2 | Judul kosong, spasi saja, atau tab dan baris baru | Unit (kasus tepi) | Ditolak dengan pesan yang sama |
| 3 | Sinkronisasi dengan antrean dirty | Unit (asinkron) | Jumlah tersinkron sesuai antrean |
| 4 | Sinkronisasi saat antrean kosong | Unit (asinkron) | Tidak memanggil penandaan |
| 5 | Gagal menghitung antrean | Unit (kegagalan) | Failure diteruskan, antrean tidak ditandai |
| 6 | Halaman awal tanpa catatan | Widget | Empty state tampil |
| 7 | Simpan dengan judul tidak valid | Widget | Pesan error tampil, dialog tetap terbuka |
| 8 | Simpan catatan yang valid | Widget | Catatan muncul di daftar |
| 9 | Tambah catatan dari awal sampai daftar | Integrasi | Catatan baru terlihat di perangkat |

## 2. Pembagian lapisan pengujian

| Lapisan | Berkas | Fokus |
|---|---|---|
| Unit | `test/validate_note_edge_cases_test.dart` | Aturan validasi judul |
| Unit asinkron | `test/sync_notes_test.dart` | Use case dengan fake repository |
| Widget | `test/notes_widget_test.dart` | Tampilan dan interaksi dialog |
| Integrasi | `integration_test/app_test.dart` | Alur tambah catatan pada perangkat |

## 3. Fake repository

Fake dipakai agar pengujian tidak bergantung pada SQLite asli.

- `FakeSyncRepository` mengatur jumlah antrean dan kegagalan secara langsung.
- `FakeNotesRepository` menyimpan catatan di memori dan menambah data saat
  `addNote` dipanggil.

Dengan cara ini hasil sukses dan kegagalan dapat diuji tanpa koneksi atau
perangkat tambahan.

## 4. Temuan saat pengujian

Pengujian widget untuk alur simpan sempat gagal karena controller dialog
di-dispose sebelum animasi dialog selesai. Pesan kegagalannya
`A TextEditingController was used after being disposed`. Perbaikan dilakukan
dengan memindahkan controller ke `_NoteEditorDialog`, sehingga controller baru
di-dispose setelah dialog benar-benar dilepas.