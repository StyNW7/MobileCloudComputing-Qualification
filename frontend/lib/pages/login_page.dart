import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Provider.of<AuthProvider>(context, listen: false).login(_emailCtrl.text.trim());
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // form shows errors
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
            const FlutterLogo(size: 80),
            const SizedBox(height: 12),
            const Text('Welcome to JourNWal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(children: [
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
                  child: ElevatedButton(onPressed: _submit, child: const Text('Login')),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
