import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/note_service.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _controller = TextEditingController();
  final _noteService = NoteService();
  final _userId = FirebaseAuth.instance.currentUser!.uid;
  bool _isSaving = false;

  Future<void> _saveNote() async {
    if (_controller.text.isNotEmpty) {
      setState(() => _isSaving = true);
      await _noteService.saveNote(_userId, _controller.text);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Baru')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: "Tulis catatan kamu di sini...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveNote,
              child:
                  _isSaving
                      ? const CircularProgressIndicator()
                      : const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
