/// Model satu komentar dari endpoint JSONPlaceholder.
class Comment {
  /// Semua field memiliki nilai fallback agar JSON null atau tidak lengkap aman.
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  /// Mengubah JSON menjadi model tanpa cast langsung yang dapat crash saat null.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: (json['postId'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
    );
  }

  /// Mengubah model kembali ke bentuk JSON untuk kebutuhan serialisasi.
  Map<String, dynamic> toJson() => {
        'postId': postId,
        'id': id,
        'name': name,
        'email': email,
        'body': body,
      };
}
