class Note {
  final String id;
  final String encryptedContent;
  final String? decryptedContent; // Bisa null kalau belum didekripsi
  bool isFavorite;
  DateTime? deletedAt; // waktu catatan masuk sampah

  Note({
    required this.id,
    required this.encryptedContent,
    this.decryptedContent,
    this.deletedAt,
    this.isFavorite = false,
  });

  // Properti getter untuk mengecek apakah catatan dihapus (deletedAt != null)
  bool get isDeleted => deletedAt != null;

  // Parse dari Firebase (Map) jadi Note object
  factory Note.fromMap(String id, Map<String, dynamic> data) {
    return Note(
      id: id,
      encryptedContent: data['encryptedContent'] ?? '',
      decryptedContent: null, // biasanya diisi saat dekripsi terpisah
      isFavorite: data['isFavorite'] ?? false,
      deletedAt: data['deletedAt'] != null
          ? DateTime.tryParse(data['deletedAt'])
          : null,
    );
  }

  // Convert Note object ke Map untuk disimpan ke Firebase
  Map<String, dynamic> toMap({required String iv}) {
    final map = {
      'encryptedContent': encryptedContent,
      'iv': iv,
      'isFavorite': isFavorite,
    };

    if (deletedAt != null) {
      map['deletedAt'] = deletedAt!.toIso8601String();
    }

    return map;
  }
}
