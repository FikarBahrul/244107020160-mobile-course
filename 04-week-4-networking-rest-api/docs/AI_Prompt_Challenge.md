Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error
  ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.

## Implementasi

Implementasi dibuat dalam beberapa lapisan agar UI tidak berkomunikasi dengan Dio secara langsung.

- `lib/data/models/comment.dart` berisi model `Comment`. `Comment.fromJson` menggunakan `num?` untuk ID dan `?.toString() ?? ''` untuk teks, sehingga field yang hilang atau `null` memakai nilai aman.
- `lib/data/repositories/comment_repository.dart` berisi `CommentRepository.fetchComments(postId)`. Repository memanggil `GET /comments` dengan `queryParameters: {'postId': postId}` dan mengubah daftar JSON menjadi `List<Comment>`.
- `lib/data/api_client.dart` menjadi satu-satunya tempat konfigurasi `baseUrl` JSONPlaceholder dan timeout 10 detik (`connectTimeout`, `sendTimeout`, serta `receiveTimeout`). Repository menerima client ini melalui dependency injection.
- `lib/data/comment_providers.dart` mendaftarkan Dio dan repository dengan Riverpod. `commentListProvider` adalah `AsyncNotifierProvider.family`, sehingga state terpisah berdasarkan `postId`. Exception dari `build` otomatis menjadi `AsyncError`; `retry` dimatikan agar pesan error dapat langsung ditampilkan.
- `lib/data/network_errors.dart` menyediakan `friendlyErrorMessage`. Timeout, connection error, bad certificate, cancel, 404, 500, status server lain, dan error Dio lain dipetakan ke pesan pengguna.
- `test/comment_test.dart` menguji JSON dengan field hilang, seluruh field bernilai `null`, serta pemetaan pesan untuk timeout, 404, dan 500.

Contoh pemakaian provider di UI:

```dart
final state = ref.watch(commentListProvider(postId));

return state.when(
  loading: () => const CircularProgressIndicator(),
  error: (error, stackTrace) => Text(friendlyErrorMessage(error)),
  data: (comments) => CommentList(comments: comments),
);
```

## Hasil Verifikasi

- `flutter analyze`: **lulus**, `No issues found!`.
- `flutter test`: **lulus**, `8` test passed.