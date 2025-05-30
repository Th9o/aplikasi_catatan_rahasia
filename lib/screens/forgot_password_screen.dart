import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final auth = AuthService();
  String? message;
  bool isLoading = false;

  Future<void> handleReset() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        message = "Masukkan email terlebih dahulu.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = null;
    });

    try {
      await auth.resetPassword(email);
      setState(() {
        message = "Link reset password telah dikirim ke email.";
      });
    } catch (e) {
      final err = e.toString();
      if (err.contains('invalid-email')) {
        message = "Format email tidak valid.";
      } else if (err.contains('user-not-found')) {
        message = "Email tidak ditemukan.";
      } else {
        message = "Terjadi kesalahan: ${e.toString()}";
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Text(
              "Masukkan email akun Anda untuk mengirim link reset password.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (message != null)
              Text(
                message!,
                style: TextStyle(
                  color:
                      message!.contains("dikirim") ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : handleReset,
              child:
                  isLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Kirim Link Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
