# AI Log - Week 10 Integrasi Fitur AI

| Item | Keterangan |
|---|---|
| Nama | Fikar Bahrul Santoso |
| NIM | 244107020160 |
| Fitur | Chat Asisten Kampus AI |
| Provider aplikasi | Google Gemini REST (`gemini-3.5-flash-lite`) |
| Model uji prompt | `qwen3.5:4b` melalui Ollama lokal |

## 1. Fitur yang dipilih

Fitur yang diintegrasikan adalah **chat asisten kampus**. Fitur ini dipilih
karena paling dekat dengan project Offline Notes dan bisa diuji tanpa kamera
atau mikrofon. Pengguna dapat bertanya singkat tentang perkuliahan atau meminta
ringkasan judul catatan yang tersimpan.

Batasan yang disengaja:

- Jawaban maksimal dua kalimat.
- Percakapan hanya mengirim pertanyaan terbaru, bukan seluruh riwayat, agar
  biaya token tetap kecil.
- Data pribadi seperti NIK dan nomor telepon diblokir sebelum dikirim.
- Jika API gagal atau kunci belum diatur, aplikasi memakai fallback lokal.

## 2. Prompt design

| Komponen | Isi | Tujuan |
|---|---|---|
| System prompt | Asisten Kampus yang ramah, Bahasa Indonesia, maksimal 2 kalimat | Menetapkan persona dan panjang jawaban |
| User prompt | Pertanyaan pengguna, misalnya "Jadwal kampus hari Senin?" | Input utama |
| Konteks | Judul catatan lokal hanya untuk fallback, bukan dikirim ke API | Menjaga privasi |
| Batas | Tidak meminta NIK, nomor telepon, atau alamat | Keamanan dan privasi |
| Output | `maxOutputTokens : 256`, `temperature : 0.4` | Jawaban singkat dan stabil |

### Prompt sistem yang dipakai di kode

```text
Kamu adalah Asisten Kampus yang ramah. Jawab dalam Bahasa Indonesia, singkat,
maksimal 2 kalimat. Jangan meminta atau mengulang NIK, nomor telepon, alamat,
atau data pribadi. Jika pertanyaan membutuhkan data pribadi, sarankan pengguna
memeriksa aplikasi kampus secara langsung.
```

### User prompt uji

1. `Jadwal kampus hari Senin?`
2. `Ringkas catatan saya: Belanja mingguan, Jadwal Kuliah.`

## 3. Output awal AI

Output di bawah dihasilkan sebelum integrasi ke aplikasi. Uji prompt memakai
model lokal `qwen3.5:4b` melalui Ollama dengan system prompt yang sama. Model
lokal dipakai karena kunci Gemini pribadi belum tersedia saat pengujian awal.
Tujuannya untuk menilai panjang, gaya bahasa, dan relevansi jawaban.

### Output untuk prompt 1

```text
Silakan cek jadwal kuliah di aplikasi resmi kampus Anda untuk informasi terbaru hari Senin.
```

### Output untuk prompt 2

```text
Catatan Anda mencakup rencana belanja mingguan dan jadwal kuliah. Untuk detail lengkapnya, silakan cek aplikasi kampus secara langsung.
```

Kedua jawaban sudah memenuhi batas dua kalimat dan tidak meminta data pribadi.
Kalimat "cek aplikasi kampus" dipakai sebagai arahan aman ketika data jadwal
tidak tersedia di aplikasi.

## 4. Verifikasi kode

| Bagian | Verifikasi |
|---|---|
| Endpoint | `POST https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:streamGenerateContent` |
| Streaming | Respons `text/event-stream` dibaca per baris `data:`, lalu potongan teks digabung |
| Kunci API | Disimpan di `flutter_secure_storage` dengan nama `ai_api_key` |
| Kunci di repo | Tidak ada kunci, token, atau file `.env` di project |
| Privasi | `containsSensitiveData` menolak NIK 16 digit dan nomor telepon Indonesia |
| Error | Kode 400/401/403, 429, dan 5xx dipetakan ke pesan yang mudah dipahami |
| Fallback | Jika kunci kosong atau API gagal, jawaban lokal memakai judul catatan |
| Riwayat | Hanya pertanyaan terbaru yang dikirim untuk menghemat biaya |

Bukti otomatis:

```text
dart format --output=none --set-exit-if-changed lib test  => 0 file berubah
flutter analyze                                           => No issues found
flutter test                                              => 27 test lulus
```

## 5. Pengujian live

Uji live dilakukan pada APK release di emulator Medium_Phone dengan kunci dari
Google AI Studio yang diisi lewat **Pengaturan > Kunci API Gemini**. Server
membalas `HTTP 200` dan jawaban datang bertahap lewat SSE. Tidak ada label
"Jawaban lokal" pada jawaban live.

Model yang dipakai: `gemini-3.5-flash-lite`.

Catatan pemilihan model:

- `gemini-flash-latest` menghasilkan `503 UNAVAILABLE` karena permintaan tinggi.
- `gemini-2.5-flash-lite` menghasilkan `404 NOT_FOUND` karena sudah tidak tersedia.
- `gemini-3.5-flash-lite` menghasilkan `200 OK` dan jawaban streaming tampil normal.

Contoh output live:

```text
Pertanyaan : Jelaskan singkat manfaat belajar pemrograman mobile
Jawaban    : Belajar pemrograman mobile melatih keterampilan logika sekaligus
             membuka peluang karier yang luas di era digital. Kamu juga bisa
             mewujudkan ide kreatifmu menjadi aplikasi nyata yang mudah diakses
             siapa saja lewat smartphone.
```

```text
Pertanyaan : Beri tips belajar pemrograman mobile
Jawaban    : Pilih satu bahasa dasar seperti Kotlin untuk Android atau Swift
             untuk iOS, lalu pelajari konsep dasarnya secara konsisten. Perbanyak
             latihan dengan membuat proyek kecil secara mandiri agar kemampuan
             coding-mu cepat berkembang!
```

Screenshot bukti: `screenshots/P1_07_chat_live_gemini.png` dan
`screenshots/P1_08_chat_live_tips.png`. Kunci tidak pernah ditulis ke kode
sumber maupun log.