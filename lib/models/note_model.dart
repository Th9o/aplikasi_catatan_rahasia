class Note {
  final String id;
  final String encryptedContent;
  final String? decryptedContent; // Bisa null kalau belum didekripsi

  Note({
    required this.id,
    required this.encryptedContent,
    this.decryptedContent,
    required isDeleted,
  });

  // Parse dari Firebase
  factory Note.fromMap(String id, Map<String, dynamic> data) {
    return Note(
      id: id,
      encryptedContent: data['encryptedContent'] ?? '',
      decryptedContent: null,
      isDeleted: null, // Default null, nanti didekripsi terpisah
    );
  }

  Future<void>? get isDeleted => null;

  // Untuk disimpan ke Firebase (opsional, jika ingin dipakai)
  Map<String, dynamic> toMap(String iv) {
    return {
      'encryptedContent': encryptedContent,
      'iv': iv,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
