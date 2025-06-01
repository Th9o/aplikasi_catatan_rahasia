import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isFingerprintEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: const Color(0xFF6A5AE0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tampilan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Mode Gelap'),
            value: _isDarkMode,
            activeColor: const Color(0xFF6A5AE0),
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              // Tambahkan logika ganti tema jika menggunakan Theme Provider
            },
            secondary: const Icon(Icons.dark_mode_outlined),
          ),
          const Divider(height: 32),

          const Text(
            'Keamanan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Gunakan Sidik Jari'),
            value: _isFingerprintEnabled,
            activeColor: const Color(0xFF6A5AE0),
            onChanged: (value) {
              setState(() {
                _isFingerprintEnabled = value;
              });
              // Tambahkan logika autentikasi biometrik bila perlu
            },
            secondary: const Icon(Icons.fingerprint),
          ),
          const Divider(height: 32),

          const Text(
            'Tentang',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Versi Aplikasi'),
            subtitle: const Text('1.0.0'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
