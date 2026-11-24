import 'package:flutter_test/flutter_test.dart';
import 'package:week12_testing_quality_assurance/core/validate.dart';

void main() {
  group('validateNoteTitle', () {
    test('menerima judul yang berisi teks', () {
      expect(validateNoteTitle('Belajar Flutter'), isNull);
    });

    test('menerima judul dengan spasi di awal dan akhir', () {
      expect(validateNoteTitle('  Belanja mingguan  '), isNull);
    });

    test('menolak teks kosong', () {
      expect(validateNoteTitle(''), 'Judul catatan tidak boleh kosong.');
    });

    test('menolak teks yang hanya berisi spasi', () {
      expect(validateNoteTitle('   '), isNotNull);
    });

    test('menolak teks yang hanya berisi tab dan baris baru', () {
      expect(validateNoteTitle('\t\n'), isNotNull);
    });
  });
}
