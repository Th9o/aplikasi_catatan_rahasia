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

      if (userId == null) throw Exception('User ID tidak ditemukan.');

      final notes = await _noteService.getDecryptedNotes(userId);
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat catatan: $e');
      setState(() => _isLoading = false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
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
      appBar: AppBar(title: const Text('Catatan Rahasia')),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromRGBO(113, 104, 104, 1)),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 25),
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
              padding: const EdgeInsets.only(bottom: 5.0, right: 10.0),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? const Center(child: Text("Belum ada catatan."))
              : ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    final title = note.decryptedContent?.split('\n').first ?? 'Tanpa Judul';
                    final content = note.decryptedContent ?? '';

                    return ListTile(
                      title: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit Catatan',
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteEditorPage(
                                existingNoteId: note.id,
                                existingNoteContent: content,
                              ),
                            ),
                          );
                          _loadNotes(); // refresh setelah kembali dari edit
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteEditorPage()),
          );
          _loadNotes(); // Refresh setelah kembali dari tambah
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Catatan',
      ),
    );
  }
}
