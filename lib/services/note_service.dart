import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import 'encryption_service.dart';

class NoteService {
  final _db = FirebaseFirestore.instance;
  final _encryptor = EncryptionService();

  // Simpan catatan terenkripsi (dengan IV acak)
  Future<void> saveNote(String userId, String plainContent) async {
    final encrypted = await _encryptor.encrypt(plainContent);
    final newNote = {
      'encryptedContent': encrypted['content'],
      'iv': encrypted['iv'], // wajib disimpan agar bisa dekripsi
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _db.collection('users').doc(userId).collection('notes').add(newNote);
  }

  // Ambil catatan terenkripsi (tanpa dekripsi)
  Future<List<Note>> getNotes(String userId) async {
    final query =
        await _db
            .collection('users')
            .doc(userId)
            .collection('notes')
            .orderBy('createdAt', descending: true)
            .get();

    return query.docs.map((doc) => Note.fromMap(doc.id, doc.data())).toList();
  }

  // Dekripsi satu konten catatan
  Future<String> decryptNoteContent(
    String encryptedText,
    String base64IV,
  ) async {
    return await _encryptor.decrypt(encryptedText, base64IV);
  }

  // Ambil dan dekripsi seluruh catatan
  Future<List<Note>> getDecryptedNotes(String userId) async {
    final query =
        await _db
            .collection('users')
            .doc(userId)
            .collection('notes')
            .orderBy('createdAt', descending: true)
            .get();

    final List<Note> decryptedNotes = [];

    for (var doc in query.docs) {
      final data = doc.data();
      final encrypted = data['encryptedContent'];
      final iv = data['iv'];

      try {
        final decrypted = await _encryptor.decrypt(encrypted, iv);
        decryptedNotes.add(
          Note(
            id: doc.id,
            encryptedContent: encrypted,
            decryptedContent: decrypted,
          ),
        );
      } catch (e) {
        print('❌ Gagal dekripsi catatan ${doc.id}: $e');
        // Bisa ditambahkan handling fallback di sini
      }
    }

    return decryptedNotes;
  }

  // Hapus catatan
  Future<void> deleteNote(String userId, String noteId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }
}
