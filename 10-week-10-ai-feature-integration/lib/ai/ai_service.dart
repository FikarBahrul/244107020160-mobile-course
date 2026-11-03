import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const aiSystemPrompt =
    'Kamu adalah Asisten Kampus yang ramah. Jawab dalam Bahasa Indonesia, '
    'singkat, maksimal 2 kalimat. Jangan meminta atau mengulang NIK, nomor '
    'telepon, alamat, atau data pribadi. Jika pertanyaan membutuhkan data '
    'pribadi, sarankan pengguna memeriksa aplikasi kampus secara langsung.';

const _model = 'gemini-3.5-flash-lite';
const _apiUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/'
    '$_model:streamGenerateContent';

class AiException implements Exception {
  const AiException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class AiClient {
  Future<bool> hasApiKey();

  Future<void> saveApiKey(String key);

  Future<void> deleteApiKey();

  Stream<String> askStream(String question);
}

class AiService implements AiClient {
  AiService({FlutterSecureStorage? storage, http.Client? client})
    : _storage = storage ?? const FlutterSecureStorage(),
      _client = client ?? http.Client();

  static const _apiKeyStorageKey = 'ai_api_key';

  final FlutterSecureStorage _storage;
  final http.Client _client;

  @override
  Future<bool> hasApiKey() async {
    final key = await _storage.read(key: _apiKeyStorageKey);
    return key != null && key.trim().isNotEmpty;
  }

  @override
  Future<void> saveApiKey(String key) async {
    final trimmed = key.trim();
    if (trimmed.isEmpty) {
      throw const AiException('Kunci API tidak boleh kosong.');
    }
    await _storage.write(key: _apiKeyStorageKey, value: trimmed);
  }

  @override
  Future<void> deleteApiKey() async {
    await _storage.delete(key: _apiKeyStorageKey);
  }

  @override
  Stream<String> askStream(String question) async* {
    final apiKey = await _storage.read(key: _apiKeyStorageKey);
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const AiException(
        'Kunci API belum diatur. Buka Pengaturan untuk menambahkan kunci.',
      );
    }

    final request = http.Request(
      'POST',
      Uri.parse('$_apiUrl?alt=sse&key=${Uri.encodeQueryComponent(apiKey)}'),
    );
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'systemInstruction': {
        'parts': [
          {'text': aiSystemPrompt},
        ],
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': question},
          ],
        },
      ],
      'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 256},
    });

    late final http.StreamedResponse response;
    try {
      response = await _client
          .send(request)
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw const AiException(
        'Layanan AI tidak merespons. Periksa koneksi lalu coba lagi.',
      );
    } on http.ClientException {
      throw const AiException(
        'Tidak dapat terhubung ke layanan AI. Periksa koneksi internet.',
      );
    }

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw AiException(_friendlyError(response.statusCode, body));
    }

    var received = false;
    await for (final line
        in response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
      if (!line.startsWith('data:')) continue;
      final payload = line.substring(5).trim();
      if (payload.isEmpty || payload == '[DONE]') continue;

      final chunk = _textFromChunk(payload);
      if (chunk != null && chunk.isNotEmpty) {
        received = true;
        yield chunk;
      }
    }

    if (!received) {
      throw const AiException(
        'AI tidak mengembalikan teks. Coba tulis pertanyaan dengan lebih jelas.',
      );
    }
  }

  String? _textFromChunk(String payload) {
    try {
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) return null;
      final content = candidates.first['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) return null;
      final text = parts.first['text'];
      return text?.toString();
    } on FormatException {
      return null;
    }
  }

  String _friendlyError(int statusCode, String body) {
    var detail = '';
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final error = decoded['error'] as Map<String, dynamic>?;
      detail = error?['message']?.toString() ?? '';
    } on FormatException {
      detail = '';
    }

    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return 'Kunci API tidak valid atau tidak punya akses. Periksa Pengaturan.';
    }
    if (statusCode == 429) {
      return 'Batas permintaan AI tercapai. Tunggu sebentar lalu coba lagi.';
    }
    if (statusCode >= 500) {
      return 'Layanan AI sedang sibuk. Coba lagi nanti atau gunakan mode lokal.';
    }
    if (detail.isNotEmpty) {
      return 'Gagal memanggil AI API : $detail';
    }
    return 'Gagal memanggil AI API (kode $statusCode).';
  }
}
