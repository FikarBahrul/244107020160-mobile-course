// Validasi murni tanpa ketergantungan Flutter agar bisa diunit-test langsung.
// Mengembalikan pesan error bila judul tidak valid, atau null bila valid.
String? validateNoteTitle(String title) {
  if (title.trim().isEmpty) {
    return 'Judul catatan tidak boleh kosong.';
  }
  return null;
}
