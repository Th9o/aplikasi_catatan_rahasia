import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/note_service.dart';

class NoteEditorPage extends StatefulWidget {
  final String? existingNoteId;
  final String? existingNoteContent;

  const NoteEditorPage({
    super.key,
    this.existingNoteId,
    this.existingNoteContent,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _noteService = NoteService();

  @override
  void initState() {
    super.initState();

    final content = widget.existingNoteContent ?? '';
    final title = content.split('\n').first;
    final body = content.split('\n').skip(1).join('\n');

    _titleController = TextEditingController(text: title);
    _contentController = TextEditingController(text: body);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul dan isi catatan tidak boleh kosong.")),
      );
      return;
    }

    try {
      final userId = await AuthService().getCurrentUserId();
      if (userId == null) throw Exception("User ID tidak ditemukan");

      final fullNote = "$title\n$content";

      if (widget.existingNoteId != null) {
        // Mode edit
        await _noteService.updateNote(userId, widget.existingNoteId!, fullNote);
      } else {
        // Mode tambah
        await _noteService.saveNote(userId, fullNote);
      }

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan catatan: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingNoteId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Catatan' : 'Tambah Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Simpan Catatan',
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
