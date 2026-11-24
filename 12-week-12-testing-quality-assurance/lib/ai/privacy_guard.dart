final _nikPattern = RegExp(r'\b\d{16}\b');
final _phonePattern = RegExp(r'(\+62|62|0)8[1-9][0-9]{6,11}');

bool containsSensitiveData(String text) {
  return _nikPattern.hasMatch(text) || _phonePattern.hasMatch(text);
}

String privacyWarning() {
  return 'Pesan tidak dikirim karena berisi data pribadi seperti NIK atau '
      'nomor telepon. Hapus data tersebut lalu coba lagi.';
}
