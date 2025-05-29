import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'note_editor_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Rahasia'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(113, 104, 104, 1),
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Color.fromARGB(108, 255, 255, 255),
                    fontSize: 25,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notes),
              title: const Text('Semua Catatan'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigasi ke semua catatan
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Sampah'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigasi ke halaman Sampah
              },
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
      body: const Center(
        child: Text("Selamat datang di Catatan Rahasia!"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteEditorPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Catatan',
      ),
    );
  }
}
