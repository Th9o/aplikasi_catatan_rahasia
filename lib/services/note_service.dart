import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import 'encryption_service.dart';

class NoteService {
  final _db = FirebaseFirestore.instance;
  final _encryptor = EncryptionService();

  Future<void> saveNote(String userId, String plainContent) async {
    final encrypted = await _encryptor.encrypt(plainContent);
    final newNote = {
      'encryptedContent': encrypted['content'],
      'iv': encrypted['iv'],
      'isDeleted': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _db.collection('users').doc(userId).collection('notes').add(newNote);
  }

  Future<void> updateNote(
    String userId,
    String noteId,
    String updatedContent,
  ) async {
    final encrypted = await _encryptor.encrypt(updatedContent);
    final updatedNote = {
      'encryptedContent': encrypted['content'],
      'iv': encrypted['iv'],
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .update(updatedNote);
  }

  Future<void> deleteNote(String userId, String noteId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  Future<void> moveToTrash(String userId, String noteId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .update({'isDeleted': true});
  }

  Future<void> restoreFromTrash(String userId, String noteId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .update({'isDeleted': false});
  }

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
      final isDeleted = data['isDeleted'] ?? false;

      if (isDeleted == true) continue; // Hanya tampilkan yang aktif

      final encrypted = data['encryptedContent'];
      final iv = data['iv'];

      try {
        final decrypted = await _encryptor.decrypt(encrypted, iv);
        decryptedNotes.add(
          Note(
            id: doc.id,
            encryptedContent: encrypted,
            decryptedContent: decrypted,
            isDeleted: isDeleted,
          ),
        );
      } catch (e) {
        print('❌ Gagal dekripsi catatan ${doc.id}: $e');
      }
    }

    return decryptedNotes;
  }

  Future<List<Note>> getDeletedNotes(String userId) async {
    final query =
        await _db
            .collection('users')
            .doc(userId)
            .collection('notes')
            .orderBy('createdAt', descending: true)
            .get();

    final List<Note> deletedNotes = [];

    for (var doc in query.docs) {
      final data = doc.data();
      final isDeleted = data['isDeleted'] ?? false;

      if (isDeleted == false) continue; // Hanya tampilkan yang terhapus

      final encrypted = data['encryptedContent'];
      final iv = data['iv'];

      try {
        final decrypted = await _encryptor.decrypt(encrypted, iv);
        deletedNotes.add(
          Note(
            id: doc.id,
            encryptedContent: encrypted,
            decryptedContent: decrypted,
            isDeleted: isDeleted,
          ),
        );
      } catch (e) {
        print('❌ Gagal dekripsi catatan ${doc.id}: $e');
      }
    }

    return deletedNotes;
  }
}
