import 'package:flutter_test/flutter_test.dart';
import 'package:week10_ai_feature_integration/core/validate.dart';

void main() {
  test('judul kosong mengembalikan pesan error', () {
    expect(validateNoteTitle(''), 'Judul catatan tidak boleh kosong.');
  });

  test('judul yang hanya berisi spasi dianggap kosong', () {
    expect(validateNoteTitle('   '), isNotNull);
  });

  test('judul berisi teks dinyatakan valid', () {
    expect(validateNoteTitle('Belanja mingguan'), isNull);
  });
}
