import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool loading = false;
  String? errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
    final re = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!re.hasMatch(v)) return 'Format email tidak valid';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
    if (v.length < 8) return 'Password minimal 8 karakter';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Password harus mengandung angka';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
      errorMessage = null;
    });

    final success = await AuthService().login(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
    );

    setState(() => loading = false);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      setState(() {
        errorMessage = "Email atau password salah!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JourNWal — Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // ✅ Custom Logo Bisnis
            Image.asset(
              "assets/logo.png",
              height: 100,
            ),
            const SizedBox(height: 12),
            const Text(
              'Welcome to JourNWal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),

            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              ),

            const SizedBox(height: 12),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passCtrl,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
