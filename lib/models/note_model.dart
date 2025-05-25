class Note {
  final String id;
  final String encryptedContent;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.encryptedContent,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'encryptedContent': encryptedContent,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id: id,
      encryptedContent: map['encryptedContent'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
