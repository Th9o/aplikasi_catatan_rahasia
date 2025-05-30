class Note {
  final String id;
  final String encryptedContent;
  final String? decryptedContent;

  Note({
    required this.id,
    required this.encryptedContent,
    this.decryptedContent,
  });

  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(id: id, encryptedContent: map['encryptedContent'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'encryptedContent': encryptedContent};
  }
}
