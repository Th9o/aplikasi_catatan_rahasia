
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
        await _noteService.updateNote(userId, widget.existingNoteId!, fullNote);
      } else {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditMode = widget.existingNoteId != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Catatan' : 'Tambah Catatan'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Judul',
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(minHeight: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 20,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _contentController,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Tulis isi catatan di sini...',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _saveNote,
                child: Text(
                  'Simpan',
                  style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

