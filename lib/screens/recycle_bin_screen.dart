import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({super.key});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  final _noteService = NoteService();
  final _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  List<Note> _deletedNotes = [];

  Future<void> _loadDeletedNotes() async {
    setState(() => _isLoading = true);
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final notes = await _noteService.getDeletedNotes(user.uid);
        setState(() {
          _deletedNotes = notes;
        });
      } catch (e) {
        debugPrint("❌ Gagal memuat catatan sampah: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
        }
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _restoreNote(Note note) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _noteService.restoreFromTrash(user.uid, note.id);
      await _loadDeletedNotes();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil dipulihkan')),
        );
      }
    }
  }

  Future<void> _deleteNotePermanently(Note note) async {
    final user = _auth.currentUser;
    if (user != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Hapus Permanen"),
              content: const Text("Catatan akan dihapus selamanya. Lanjutkan?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Batal"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    "Hapus",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );

      if (confirm == true) {
        await _noteService.deleteNote(user.uid, note.id);
        await _loadDeletedNotes();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Catatan dihapus secara permanen')),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDeletedNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sampah'),
        backgroundColor: const Color(0xFF6A5AE0),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _deletedNotes.isEmpty
              ? const Center(child: Text("Tidak ada catatan di sampah."))
              : ListView.builder(
                itemCount: _deletedNotes.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final note = _deletedNotes[index];
                  final title =
                      note.decryptedContent?.split('\n').first ?? 'Tanpa Judul';
                  final body =
                      note.decryptedContent?.split('\n').skip(1).join('\n') ??
                      '';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'restore') {
                            _restoreNote(note);
                          } else if (value == 'delete') {
                            _deleteNotePermanently(note);
                          }
                        },
                        itemBuilder:
                            (_) => [
                              const PopupMenuItem(
                                value: 'restore',
                                child: Text('Pulihkan'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Hapus Permanen',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
