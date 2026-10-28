import 'package:flutter_test/flutter_test.dart';
import 'package:week9_ai_assisted_development/features/notes/domain/entities/note.dart';
import 'package:week9_ai_assisted_development/features/notes/domain/usecases/search_notes.dart';

void main() {
  const search = SearchNotes();
  final list = [
    Note(title: 'Belanja mingguan', updatedAt: DateTime(2026, 10, 20)),
    Note(title: 'belanja bulanan', updatedAt: DateTime(2026, 10, 21)),
    Note(title: 'Jadwal kuliah', updatedAt: DateTime(2026, 10, 22)),
  ];

  test('filter abaikan huruf besar/kecil', () {
    expect(search(list, 'belanja'), hasLength(2));
  });

  test('query tak cocok mengembalikan daftar kosong', () {
    expect(search(list, 'zzz-tak-ada'), isEmpty);
  });

  test('query kosong mengembalikan semua catatan', () {
    expect(search(list, ''), hasLength(3));
  });

  test('query berisi spasi saja dianggap kosong', () {
    expect(search(list, '   '), hasLength(3));
  });
}
