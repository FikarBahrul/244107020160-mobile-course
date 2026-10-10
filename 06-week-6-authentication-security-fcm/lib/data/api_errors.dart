import 'package:dio/dio.dart';

// Refactoring: pemetaan DioException -> pesan ramah pengguna.
// UI hanya menerima pesan, bukan exception mentah.
String friendlyApiMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat, coba lagi sebentar.';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 401) return 'Sesi berakhir, silakan masuk ulang.';
        if (code == 403) return 'Akses ditolak.';
        if (code == 404) return 'Data tidak ditemukan.';
        if (code != null && code >= 500) return 'Server sedang bermasalah.';
        return 'Permintaan gagal (${code ?? '-'}).';
      default:
        return 'Terjadi kesalahan jaringan.';
    }
  }
  return 'Terjadi kesalahan tak terduga.';
}
