# AI Prompt Challenge — Week 5

## Prompt

```text
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift untuk dua kebutuhan ini.
Gunakan kriteria kompleksitas query, kebutuhan relasi, reaktivitas (stream), type-safety,
ukuran boilerplate, dan kemudahan testing. Beri rekomendasi final dalam satu tabel,
tunjukkan skema untuk 1000+ catatan, dan jelaskan trade-off setiap pilihan.
```

## Perbandingan Storage

| Storage | Preferensi kecil | Catatan 1000+ item | Kelebihan | Kekurangan |
|---|---|---|---|---|
| SharedPreferences | Sangat sesuai | Tidak disarankan | API sederhana dan ringan | Tidak cocok untuk query koleksi dan update parsial |
| Hive | Bisa | Bisa untuk object sederhana | NoSQL cepat dan boilerplate kecil | Query relasi dan type-safety lebih terbatas |
| SQLite / sqflite | Tidak diperlukan | Sesuai | Query relasional, indeks, update parsial, dan mudah dipahami | Mapping serta migrasi ditulis manual |
| Drift | Tidak diperlukan | Sangat sesuai | Type-safe, reaktif, query kompleks, dan stream | Boilerplate serta konfigurasi lebih besar |

## Keputusan Final

Project menggunakan **SharedPreferences untuk preferensi** dan **SQLite melalui sqflite untuk catatan**. SharedPreferences menyimpan `dark_mode` dan `last_opened_at`, sedangkan SQLite menyimpan tabel `notes` dengan `id`, `title`, `body`, `updated_at`, dan `dirty`.

## Skema Catatan

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);
```

Skema tersebut mendukung lebih dari 1000 catatan karena setiap catatan menjadi baris terpisah. Kolom `updated_at` dipakai untuk pengurutan dan aturan konflik last-write-wins, sedangkan `dirty` menandai data yang menunggu sinkronisasi.

## AI Verification Checklist
Sebelum rekomendasi AI diterima, verifikasi dan catat temuan Anda di README:

- Apakah AI menempatkan daftar catatan di SharedPreferences? (menolak: rapuh untuk koleksi).
- Apakah skema AI mendukung antrean sync (dirty flag / updated_at) atau hanya CRUD polos?
- Apakah klaim "real-time" AI didukung stream (Drift/watch) atau hanya asumsi?
- Apakah estimasi boilerplate AI masuk akal setelah Anda mencoba instalasinya (flutter pub add + migrasi skema)?
- Keputusan final Anda beserta alasannya, boleh berbeda dari rekomendasi AI selama berargumen. 

## Hasil Verifikasi Hasil AI

- Daftar catatan tidak disimpan sebagai JSON di SharedPreferences.
- Skema mendukung `dirty` dan `updated_at` untuk antrean sinkronisasi.
- Implementasi cache-first membaca cache lokal sebelum refresh jaringan.
- Sinkronisasi saat ini disimulasikan karena Jobsheet belum menyediakan backend tulis.
- Repository menerima dependency `openDb` agar test dapat menggunakan repository palsu.

## Catatan Implementasi

Struktur aplikasi mempertahankan repository sebagai satu-satunya pintu data. Widget hanya membaca provider Riverpod dan mengirim aksi pengguna kepada notifier. Pilihan sqflite digunakan karena merupakan pilihan yang diminta dalam Jobsheet dan cukup untuk CRUD catatan offline.