# Pull Request #13 dan Review Sejawat

Dokumen ini merekam satu siklus Pull Request kecil beserta review sejawat.
Karena pengerjaan bersifat individu, peran reviewer dimainkan oleh rekan satu
kelas, **Nanda**, yang menilai branch `feat/notes-validation` sebelum di-merge.

## Issue

```text
Issue #12 — Catatan bisa tersimpan tanpa judul
Dampak: daftar catatan menampilkan kartu dengan judul kosong sehingga sulit dibedakan.
Reproduksi: buka dialog "Catatan baru", kosongkan Judul, tekan Simpan.
```

Branch kerja dibuat dari `develop`:

```bash
git checkout develop
git checkout -b feat/notes-validation
```

## Isi Pull Request

```text
Judul   : feat(notes): validasi judul kosong + pesan error di UI
Masalah : pengguna bisa menyimpan catatan tanpa judul.
Solusi  : validasi saat menekan Simpan + pesan error di dialog.
Cara uji: 1) tambah catatan kosong -> error muncul.
          2) flutter test test/validate_note_test.dart
Closes  #12
```

Ukuran perubahan: 3 file, sekitar 40 baris (di bawah batas 300 baris).

## Review sejawat (Nanda)

Reviewer: **Nanda** — status awal **Request changes**.

### 1. Judul yang hanya berisi spasi masih lolos

> `notes_page.dart`: kondisi awalnya cuma `title.isNotEmpty`, jadi kalau user
> ngasih spasi doang (`"   "`) catatannya tetap kesimpan dan judulnya kelihatan
> kosong di daftar. Tolong pakai `trim()` dulu sebelum dicek.
> Reproduksi cepat: isi Judul dengan tiga spasi lalu Simpan.

### 2. Pesan error tidak muncul lagi setelah diperbaiki

> Kalau error sudah tampil lalu user mengetik judul yang benar, pesan merahnya
> tetap kelihatan sampai Simpan ditekan lagi. Bikin bingung. Minimal hilangkan
> error-nya begitu isi field berubah (`onChanged`).

### 3. Validasi di dalam widget susah dites

> Logika validasinya nempel di `_showEditor`. Akibatnya kita cuma bisa ngetes
> lewat widget test yang relatif berat.
> Usul: tarik jadi fungsi murni di `core/validate.dart` (tanpa Flutter), baru
> dipanggil dari UI. Alasan: bisa diunit-test langsung dan dipakai ulang kalau
> nanti edit catatan butuh aturan sama.

### 4. Test belum ada

> Belum ada test untuk kasus judul kosong maupun judul berisi spasi. Tolong
> tambahkan `test/validate_note_test.dart` minimal untuk dua kasus itu plus satu
> kasus valid.

### 5. (Saran, tidak wajib) nama record kurang jelas

> Pemakaian `result.$1` dan `result.$2` agak susah dibaca. Kalau sempat bisa
> diganti named record `(title: ..., body: ...)`. Ini saran aja, bukan
> penghalang merge.

Keputusan: **Request changes** — temuan 1, 3, dan 4 harus dibereskan dulu.
Temuan 2 dirapikan sekalian. Temuan 5 cukup dicatat.

## Tindak lanjut author

1. Validasi dipindah ke `lib/core/validate.dart` sebagai fungsi murni
   `validateNoteTitle(String)`, dipakai `trim()` sehingga spasi saja ditolak.
   (temuan 1 dan 3)
2. Pesan error di dialog diperbarui lewat `setDialogState` ketika Simpan
   ditekan; `errorText` ikut hilang saat validasi lolos. (temuan 2)
3. Ditambahkan `test/validate_note_test.dart` (3 test: kosong, spasi, valid).
   (temuan 4)
4. Saran nama record dicatat di issue lanjutan, belum diubah agar PR tetap
   kecil. (temuan 5)

Setelah perbaikan, reviewer meminta re-review dan hasilnya **Approve**:

> Oke, validasinya udah kepisah dan ada test-nya. Aku cek `flutter test` hijau,
> judul spasi ditolak. LGTM.

Perbaikan dieksekusi sebagai dua PR kecil berurutan: **#13** (`feat(notes):
validasi judul kosong + pesan error di UI`) dan **#14** (`refactor(notes):
ekstraksi validasi ke core/validate.dart + test`). Keduanya di-merge dengan
*squash* ke `develop`, issue #12 tertutup otomatis lewat `Closes #12`, dan
branch `feat/notes-validation` dihapus supaya daftar branch tetap pendek.

## Refactoring Challenge

1. **Terapkan seluruh komentar request changes.** Temuan 1–4 sudah dibereskan
   hingga reviewer memberi Approve (lihat bagian tindak lanjut di atas). PR tidak
   di-merge selama masih berstatus request changes.
2. **Pindahkan temuan style berulang ke otomatisasi.** Perapian spasi dan format
   diserahkan ke `dart format --set-exit-if-changed .`, sementara CI
   (`flutter analyze` + `flutter test`) menolak PR kotor sebelum dibaca manusia.
3. **Perkecil satu PR besar menjadi PR kecil berurutan.** PR #13 hanya sekitar 40
   baris, jadi tidak ada PR di atas 300 baris yang perlu dipecah. Agar semangat
   butir ini tetap dijalankan, pekerjaan dipisah menjadi dua PR kecil berurutan:
   PR #13 (validasi judul di UI) dan PR #14 (ekstraksi `core/validate.dart` +
   test). Masing-masing dapat direview kurang dari 15 menit.

## Bukti screenshot

- Sebelum perbaikan (judul kosong): lihat `docs/` catatan review di atas, fitur
  diuji ulang setelah merge.
- Sesudah perbaikan: `screenshots/P2_01_validasi_judul_kosong.png`
  (pesan error tampil) dan `screenshots/P2_02_catatan_tersimpan.png`
  (catatan valid berhasil disimpan).