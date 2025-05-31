import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/note_service.dart';
import '../models/note_model.dart';
import 'login_screen.dart';
import 'note_editor_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _noteService = NoteService();
  bool _isLoading = true;
  List<Note> _notes = [];

  Future<void> _loadNotes() async {
    try {
      setState(() => _isLoading = true);
      final userId = await AuthService().getCurrentUserId();

      if (userId == null) {
        throw Exception('User ID tidak ditemukan.');
      }

      final notes = await _noteService.getDecryptedNotes(userId);
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat catatan: $e');
      setState(() => _isLoading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      appBar: AppBar(
        title: const Text('Catatan Rahasia'),
        backgroundColor: const Color(0xFF6A5AE0),
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF6A5AE0)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menu',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notes),
              title: const Text('Semua Catatan'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Sampah'),
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10, right: 16),
              child: Align(
                alignment: Alignment.bottomRight,
                child: TextButton.icon(
                  onPressed: () async {
                    await AuthService().logout();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notes.isEmpty
              ? const Center(
                child: Text(
                  "Belum ada catatan.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  final title =
                      note.decryptedContent?.split('\n').first ?? 'Tanpa Judul';
                  final body =
                      note.decryptedContent?.split('\n').skip(1).join('\n') ??
                      '';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => NoteEditorPage(
                                  existingNoteId: note.id,
                                  existingNoteContent: note.decryptedContent,
                                ),
                          ),
                        );
                        _loadNotes();
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
        ),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFD8CFFF),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NoteEditorPage()),
            );
            _loadNotes();
          },
          child: const Icon(Icons.add, color: Colors.black),
          tooltip: 'Tambah Catatan',
        ),
      ),
    );
  }
}
