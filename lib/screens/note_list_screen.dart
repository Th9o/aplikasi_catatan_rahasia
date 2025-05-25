import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/note_service.dart';
import 'note_detail_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final _noteService = NoteService();
  final _userId = FirebaseAuth.instance.currentUser!.uid;
  bool _isLoading = true;
  List<Map<String, String>> _notes = [];

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await _noteService.getNotes(_userId);
    final result = <Map<String, String>>[];

    for (var note in notes) {
      final content = await _noteService.decryptNoteContent(
        note.encryptedContent,
      );
      result.add({'id': note.id, 'content': content});
    }

    setState(() {
      _notes = result;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Saya')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notes.isEmpty
              ? const Center(child: Text("Belum ada catatan."))
              : ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return ListTile(
                    title: Text(
                      note['content'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _noteService.deleteNote(_userId, note['id']!);
                        _loadNotes();
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteDetailScreen()),
          );
          _loadNotes(); // refresh setelah kembali
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
