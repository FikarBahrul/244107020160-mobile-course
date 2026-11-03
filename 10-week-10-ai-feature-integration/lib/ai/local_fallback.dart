String localFallbackAnswer(String question, List<String> noteTitles) {
  final text = question.toLowerCase();

  if (RegExp(r'\b(halo|hai|hi)\b').hasMatch(text)) {
    return 'Halo! Layanan AI sedang tidak aktif, jadi saya menjawab dengan '
        'mode lokal. Tanyakan "ringkas catatan saya" untuk melihat data lokal.';
  }

  final asksAboutNotes =
      text.contains('catatan') ||
      text.contains('note') ||
      text.contains('ringkas');

  if (asksAboutNotes) {
    if (noteTitles.isEmpty) {
      return 'Mode lokal : belum ada catatan yang bisa dirangkum.';
    }
    final sample = noteTitles.take(3).join(', ');
    final rest = noteTitles.length > 3
        ? ' dan ${noteTitles.length - 3} catatan lain'
        : '';
    return 'Mode lokal : Anda memiliki ${noteTitles.length} catatan, yaitu '
        '$sample$rest.';
  }

  return 'Mode lokal : layanan AI belum aktif. Saya bisa merangkum catatan '
      'jika Anda bertanya "ringkas catatan saya".';
}
