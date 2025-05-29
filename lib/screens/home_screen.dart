import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

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
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            // "Semua Catatan" langsung di bawah header
            ListTile(
              leading: const Icon(Icons.notes),
              title: const Text('Semua Catatan'),
              onTap: () {
                Navigator.pop(context);
                // Navigasi ke halaman Semua Catatan
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Sampah'),
              onTap: () {
                Navigator.pop(context);
                // Navigasi ke halaman Sampah
              },
            ),
            const Spacer(), // Mendorong Logout ke bawah
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
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
    );
  }
}
