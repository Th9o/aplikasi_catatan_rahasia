import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/note_service.dart';
import '../models/note_model.dart';

import 'login_screen.dart';
import 'note_editor_page.dart';
import 'settings_screen.dart';
import 'recycle_bin_screen.dart';
import 'edit_profile_screen.dart';
import 'favorite_screen.dart'; // pastikan import ini ada

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _noteService = NoteService();
  final _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String _userName = 'Pengguna';
  String _userEmail = 'Email tidak tersedia';
  final TextEditingController _searchController = TextEditingController();

  Future<void> _loadNotes() async {
    try {
      setState(() => _isLoading = true);
      final user = _auth.currentUser;

      if (user == null) throw Exception('User tidak ditemukan.');

      setState(() {
        _userName = user.displayName ?? 'Pengguna';
        _userEmail = user.email ?? 'Email tidak tersedia';
      });

      final notes = await _noteService.getDecryptedNotes(user.uid);

      // Jika model Note belum ada isFavorite, pastikan sudah ada atau tambahkan di sini
      // Misal, setiap note dengan property isFavorite = false secara default

      setState(() {
        _notes = notes;
        _filteredNotes = notes;
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
    _searchController.addListener(_filterNotes);
  }

  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes =
          _notes
              .where(
                (note) =>
                    (note.decryptedContent ?? '').toLowerCase().contains(query),
              )
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Catatan Rahasia'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      drawer: Drawer(
        backgroundColor: theme.cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ).then((result) {
                  if (result == true) {
                    _showSnackBar('Profil berhasil diperbarui');
                    _loadNotes();
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.only(
                  top: 48,
                  bottom: 24,
                  left: 20,
                  right: 20,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: theme.textTheme.titleLarge!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userEmail,
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDrawerItem(
              icon: Icons.note_alt_outlined,
              title: 'Semua Catatan',
              color: colorScheme.primary,
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Icons.star,
              title: 'Favorit',
              color: Colors.amber,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoriteScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.delete_sweep_outlined,
              title: 'Sampah',
              color: Colors.redAccent,
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecycleBinScreen()),
                );
                _loadNotes();
              },
            ),
            _buildDrawerItem(
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              color: Colors.teal,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.cardColor,
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Konfirmasi Logout'),
                          content: const Text(
                            'Apakah Anda yakin ingin logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                  );

                  if (shouldLogout == true) {
                    await AuthService().logout();

                    // Hapus status login biometrik
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('is_logged_in');

                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  }
                },

                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadNotes,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari catatan...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child:
                          _filteredNotes.isEmpty
                              ? Center(
                                child: Text(
                                  "Catatan tidak ditemukan.",
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: _filteredNotes.length,
                                itemBuilder: (context, index) {
                                  final note = _filteredNotes[index];
                                  final title =
                                      note.decryptedContent
                                          ?.split('\n')
                                          .first ??
                                      'Tanpa Judul';
                                  final body =
                                      note.decryptedContent
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
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
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
                                            builder:
                                                (_) => NoteEditorPage(
                                                  existingNoteId: note.id,
                                                  existingNoteContent:
                                                      note.decryptedContent,
                                                ),
                                          ),
                                        );
                                        _loadNotes();
                                      },
                                      trailing: PopupMenuButton<String>(
                                        onSelected: (value) async {
                                          final user = _auth.currentUser;
                                          if (user == null) return;

                                          switch (value) {
                                            case 'toggle_favorite':
                                              final newFavoriteStatus =
                                                  !note.isFavorite;
                                              setState(() {
                                                note.isFavorite =
                                                    newFavoriteStatus;
                                              });
                                              await _noteService.updateFavorite(
                                                user.uid,
                                                note.id,
                                                newFavoriteStatus,
                                              );
                                              _showSnackBar(
                                                newFavoriteStatus
                                                    ? 'Catatan ditambahkan ke Favorit'
                                                    : 'Catatan dihapus dari Favorit',
                                              );
                                              _loadNotes();

                                              break;

                                            case 'delete_note':
                                              final confirm = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                builder:
                                                    (_) => AlertDialog(
                                                      title: const Text(
                                                        'Hapus Catatan',
                                                      ),
                                                      content: const Text(
                                                        'Yakin ingin memindahkan catatan ke Sampah?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  ),
                                                          child: const Text(
                                                            'Batal',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  ),
                                                          child: const Text(
                                                            'Hapus',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                              if (confirm == true) {
                                                await _noteService.moveToTrash(
                                                  user.uid,
                                                  note.id,
                                                );
                                                _showSnackBar(
                                                  'Catatan berhasil dihapus',
                                                );
                                                _loadNotes();
                                              }
                                              break;
                                          }
                                        },
                                        itemBuilder:
                                            (context) => [
                                              PopupMenuItem(
                                                value: 'toggle_favorite',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      note.isFavorite
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      color:
                                                          note.isFavorite
                                                              ? Colors.amber
                                                              : null,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      note.isFavorite
                                                          ? 'Hapus dari Favorit'
                                                          : 'Tambah ke Favorit',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete_note',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.delete,
                                                      color: Colors.redAccent,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text('Hapus Catatan'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
      floatingActionButton: Container(
        margin: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
        ),
        child: FloatingActionButton(
          backgroundColor: colorScheme.secondary,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NoteEditorPage()),
            );
            if (result != null) {
              _showSnackBar('Catatan berhasil ditambahkan');
            }
            _loadNotes();
          },
          tooltip: 'Tambah Catatan',
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      splashColor: color.withOpacity(0.1),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              title,
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
