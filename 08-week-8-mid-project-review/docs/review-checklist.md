# Review Checklist — Week 8

Dokumen ini mencatat hasil Praktikum 1 (higiene branch dan commit) dan
Praktikum 3 (static analysis serta penilaian kesiapan paruh semester).

## Praktikum 1 — Audit riwayat dan higiene branch

Riwayat awal repository (sebelum ditata):

```text
965c7d0 Jobsheet 7
43b3212 Jobsheet 6
849a8cb Jobsheet 5
fe9c00d Jobsheet 5
4215294 Jobsheet 4
cfca691 Jobsheet 3
2638856 Jobsheet 2
a7841eb Jobsheet 1
e37c79e Initial commit
```

Temuan audit:

- Semua pekerjaan langsung masuk ke `main`, tidak ada `develop` maupun
  `feature/*`.
- Pesan commit hanya menandai minggu ("Jobsheet 5" dua kali), tidak
  menjelaskan **apa** dan **di mana** yang berubah.
- Tidak ada issue maupun PR, sehingga tidak ada jejak review.

Perbaikan struktur branch (dibuat dari `main`):

```bash
git checkout -b develop main
git checkout -b feat/notes-validation develop
git checkout main
```

Hasil `git branch -a` setelah penataan:

```text
  develop
  feat/notes-validation
* main
  remotes/origin/HEAD -> origin/main
  remotes/origin/main
```

Setelah ini `main` tidak disentuh lagi; semua Pull Request menargetkan
`develop`, dan `main` hanya menerima hasil rilis.

### Tabel commit sebelum dan sesudah

Format yang dipakai: `tipe(scope): deskripsi singkat` dengan tipe `feat`,
`fix`, `refactor`, `test`, `docs`, `chore`.

| Pesan lama | Pesan konvensional | Alasan |
|---|---|---|
| `Jobsheet 7` | `refactor(notes): terapkan Clean Architecture feature-first + test` | Menyebut jenis perubahan, fitur yang disentuh, dan bukti (test) |
| `Jobsheet 4` | `feat(posts): cache-first JSONPlaceholder via Dio + sqflite` | Menjelaskan fitur dan sumber data, bukan sekadar nomor minggu |
| `Jobsheet 6` | `feat(auth): login aman + token FCM` | Cakupan jelas sehingga mudah di-revert bila bermasalah |
| `Jobsheet 5` (dua kali) | `feat(notes): catatan offline dengan badge dirty` | Dua commit identik disatukan jadi satu perubahan logis |
| `Initial commit` | `chore: inisialisasi project Flutter` | Menandai commit fondasi tanpa nilai bisnis |

Catatan: pesan commit di atas ditulis ulang pada dokumentasi. Commit dan push
nyata dilakukanmanual oleh mahasiswa melalui GitHub, sesuai kebijakan repository
portfolio.

## Praktikum 3 — Static analysis dan penilaian paruh semester

Tiga pemeriksaan mesin pada project:

```text
flutter analyze                       => No issues found!
dart format --set-exit-if-changed .   => tidak ada file berubah setelah dirapikan
flutter test                          => All tests passed! (9 test)
```

Penolakan otomatis lewat CI (`.github/workflows/ci.yml`) membuat PR kotor
ditolak mesin sebelum dibaca manusia:

```yaml
name: ci
on: [pull_request, push]
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter analyze
      - run: flutter test
```

### Penilaian kesiapan tengah semester

| Butir penilaian | Status | Bukti |
|---|---|---|
| Struktur feature-first terbukti | [Berhasil] | Tiga grep sterilitas Minggu 7, nol hasil |
| `flutter analyze` bersih | [Berhasil] | `No issues found!` |
| `flutter test` hijau | [Berhasil] | 9 test lulus |
| PR kecil + commit jelas | [Berhasil] | PR #13 < 300 baris, judul `feat(notes): ...` |
| README + screenshot + cara menjalankan | [Berhasil] | README minggu 8 |
| Semua komentar review ditindaklanjuti | [Berhasil] | `docs/peer-review.md` |

Kesimpulan: fondasi paruh semester layak dilanjutkan. Perilaku aplikasi
identik dengan akhir Minggu 7, tiga pemeriksaan mesin hijau, dan satu PR kecil
sudah melewati review sejawat sebelum di-merge.