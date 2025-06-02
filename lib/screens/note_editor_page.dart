import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/note_service.dart';

enum NoteType { plainText, checklist }

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
  late TextEditingController _plainTextController;
  final List<_ChecklistItem> _checklistItems = [];
  final _noteService = NoteService();

  NoteType _noteType = NoteType.checklist;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _plainTextController = TextEditingController();

    final content = widget.existingNoteContent ?? '';
    if (content.contains('[x]') || content.contains('[ ]')) {
      _noteType = NoteType.checklist;
      final lines = content.split('\n');
      if (lines.isNotEmpty) _titleController.text = lines.first;
      for (var line in lines.skip(1)) {
        final isChecked = line.startsWith('[x] ');
        final text = line.replaceFirst(RegExp(r'\[.\] '), '');
        _checklistItems.add(_ChecklistItem(
          controller: TextEditingController(text: text),
          checked: isChecked,
        ));
      }
    } else {
      _noteType = NoteType.plainText;
      final lines = content.split('\n');
      if (lines.isNotEmpty) {
        _titleController.text = lines.first;
        _plainTextController.text = lines.skip(1).join('\n');
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _plainTextController.dispose();
    for (var item in _checklistItems) {
      item.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || (_noteType == NoteType.checklist && _checklistItems.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul dan isi catatan tidak boleh kosong.")),
      );
      return;
    }

    try {
      final userId = await AuthService().getCurrentUserId();
      if (userId == null) throw Exception("User ID tidak ditemukan");

      String fullNote;
      if (_noteType == NoteType.plainText) {
        fullNote = "$title\n${_plainTextController.text.trim()}";
      } else {
        final checklistContent = _checklistItems.map((item) {
          final prefix = item.checked ? '[x] ' : '[ ] ';
          return '$prefix${item.controller.text.trim()}';
        }).join('\n');
        fullNote = "$title\n$checklistContent";
      }

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

  void _addChecklistItem() {
    setState(() {
      _checklistItems.add(
        _ChecklistItem(
          controller: TextEditingController(),
          checked: false,
        ),
      );
    });
  }

  Widget _buildNoteBody() {
  final theme = Theme.of(context);
  if (_noteType == NoteType.plainText) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _plainTextController,
          maxLines: null,
          expands: true,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: 'Tulis catatan...',
            border: InputBorder.none,
          ),
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  } else {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _checklistItems.length,
      itemBuilder: (context, index) {
        final item = _checklistItems[index];
        return Row(
          children: [
            Checkbox(
              value: item.checked,
              onChanged: (value) {
                setState(() => item.checked = value ?? false);
              },
            ),
            Expanded(
              child: TextField(
                controller: item.controller,
                enabled: !item.checked, // 🔒 disable editing saat dicentang
                decoration: const InputDecoration.collapsed(hintText: 'Tulis item...'),
                style: TextStyle(
                  decoration: item.checked ? TextDecoration.lineThrough : TextDecoration.none,
                  color: item.checked ? Colors.grey : null,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  item.controller.dispose();
                  _checklistItems.removeAt(index);
                });
              },
            ),
          ],
        );
      },
    );
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
        actions: [
  PopupMenuButton<NoteType>(
    icon: const Icon(Icons.more_vert),
    onSelected: (value) {
      setState(() {
        _noteType = value;
      });
    },
    itemBuilder: (context) => [
      PopupMenuItem(
        value: NoteType.plainText,
        child: const Text('Catatan Biasa'),
      ),
      PopupMenuItem(
        value: NoteType.checklist,
        child: const Text('Checklist'),
      ),
    ],
  ),
  if (_noteType == NoteType.checklist)
    IconButton(
      icon: const Icon(Icons.playlist_add_check),
      tooltip: 'Tambah Checklist',
      onPressed: _addChecklistItem,
    ),
],

      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
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
            ),
            Expanded(child: _buildNoteBody()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SizedBox(
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
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItem {
  final TextEditingController controller;
  bool checked;

  _ChecklistItem({
    required this.controller,
    this.checked = false,
  });
}
