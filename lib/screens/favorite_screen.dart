import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/note_service.dart';
import '../models/note_model.dart';
import 'note_editor_page.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final _noteService = NoteService();
  final _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  List<Note> _favoriteNotes = [];

  Future<void> _loadFavoriteNotes() async {
    try {
      setState(() => _isLoading = true);
      final user = _auth.currentUser;
      if (user == null) throw Exception('User tidak ditemukan.');

      final notes = await _noteService.getDecryptedNotes(user.uid);
      final favorites = notes.where((note) => note.isFavorite == true).toList();

      setState(() {
        _favoriteNotes = favorites;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat catatan favorit: $e');
      setState(() => _isLoading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  Future<void> _toggleFavorite(Note note) async {
  final user = _auth.currentUser;
  if (user == null) return;

  final newFavoriteStatus = !note.isFavorite;

  setState(() {
    note.isFavorite = newFavoriteStatus;
  });

  try {
    await _noteService.updateFavorite(user.uid, note.id, newFavoriteStatus);
    await _loadFavoriteNotes();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newFavoriteStatus
                ? 'Catatan ditambahkan ke Favorit'
                : 'Catatan dihapus dari Favorit',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    debugPrint('Gagal update favorit: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update favorit: $e')),
      );
    }
  }
}

  @override
  void initState() {
    super.initState();
    _loadFavoriteNotes();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Favorit'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteNotes.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada catatan favorit.',
                    style: theme.textTheme.bodyLarge!.copyWith(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favoriteNotes.length,
                  itemBuilder: (context, index) {
                    final note = _favoriteNotes[index];
                    final title =
                        note.decryptedContent?.split('\n').first ?? 'Tanpa Judul';
                    final body = note.decryptedContent
                            ?.split('\n')
                            .skip(1)
                            .join('\n') ??
                        '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: theme.cardColor,
                      elevation: 3,
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: IconButton(
                          icon: Icon(
                            note.isFavorite ? Icons.star : Icons.star_border,
                            color: note.isFavorite ? Colors.yellow : null,
                          ),
                          onPressed: () {
                            _toggleFavorite(note);
                          },
                          tooltip: note.isFavorite
                              ? 'Hapus dari Favorit'
                              : 'Tambahkan ke Favorit',
                        ),
                        title: Text(
                          title,
                          style: theme.textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteEditorPage(
                                existingNoteId: note.id,
                                existingNoteContent: note.decryptedContent,
                              ),
                            ),
                          );
                          _loadFavoriteNotes();
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
