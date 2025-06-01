//settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isFingerprintEnabled = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
            value: isDarkMode,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) => themeProvider.toggleTheme(value),
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
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              setState(() {
                _isFingerprintEnabled = value;
              });
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
          ),
        ],
      ),
    );
  }
}
