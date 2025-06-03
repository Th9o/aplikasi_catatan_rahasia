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
        emailController.clear();
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
      backgroundColor: const Color(0xFFF7F3FF),
      appBar: AppBar(
        title: const Text('Lupa Password'),
        backgroundColor: const Color(0xFF6A5AE0),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.lock_reset_rounded,
                size: 72,
                color: Color(0xFF6A5AE0),
              ),
              const SizedBox(height: 16),
              Text(
                'Reset Password',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukkan email akun Anda untuk mengirimkan link reset.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              if (message != null)
                Text(
                  message!,
                  style: TextStyle(
                    color:
                        message!.contains("dikirim")
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A5AE0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : handleReset,
                  child:
                      isLoading
                          ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                          : const Text(
                            'Kirim Link Reset',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
