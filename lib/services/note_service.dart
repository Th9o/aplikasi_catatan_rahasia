import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import 'encryption_service.dart';

class NoteService {
  final _db = FirebaseFirestore.instance;
  final _encryptor = EncryptionService();

  Future<void> saveNote(String userId, String plainContent) async {
    final encrypted = await _encryptor.encrypt(plainContent);
    final newNote = {
      'encryptedContent': encrypted,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _db.collection('users').doc(userId).collection('notes').add(newNote);
  }

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

  Future<void> deleteNote(String userId, String noteId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  Future<String> decryptNoteContent(String encryptedContent) async {
    return await _encryptor.decrypt(encryptedContent);
  }
}
