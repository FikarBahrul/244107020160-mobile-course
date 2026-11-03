import 'package:flutter_test/flutter_test.dart';
import 'package:week10_ai_feature_integration/ai/local_fallback.dart';

void main() {
  test('fallback merangkum judul catatan lokal', () {
    final answer = localFallbackAnswer('ringkas catatan saya', [
      'Belanja mingguan',
      'Jadwal kuliah',
    ]);
    expect(answer, contains('2 catatan'));
    expect(answer, contains('Belanja mingguan'));
    expect(answer, contains('Jadwal kuliah'));
  });

  test('fallback memberi tahu saat catatan kosong', () {
    final answer = localFallbackAnswer('ringkas catatan saya', []);
    expect(answer, contains('belum ada catatan'));
  });

  test('fallback menjelaskan mode lokal untuk pertanyaan umum', () {
    final answer = localFallbackAnswer('Jadwal Senin?', []);
    expect(answer, contains('Mode lokal'));
    expect(answer, contains('ringkas catatan saya'));
  });
}
