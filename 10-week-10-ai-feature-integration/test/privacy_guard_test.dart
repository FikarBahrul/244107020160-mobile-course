import 'package:flutter_test/flutter_test.dart';
import 'package:week10_ai_feature_integration/ai/privacy_guard.dart';

void main() {
  test('NIK 16 digit terdeteksi sebagai data pribadi', () {
    expect(containsSensitiveData('NIK saya 1234567890123456'), isTrue);
  });

  test('nomor telepon Indonesia terdeteksi sebagai data pribadi', () {
    expect(containsSensitiveData('Hubungi 081234567890'), isTrue);
  });

  test('pertanyaan biasa tidak dianggap data pribadi', () {
    expect(
      containsSensitiveData('Jadwal kuliah hari Senin jam berapa?'),
      isFalse,
    );
  });
}
