import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String _username = '';

  bool get isLoggedIn => _username.isNotEmpty;
  String get username => _username;

  void login(String emailOrUser) {
    // Simplifikasi: ambil bagian sebelum @ untuk username
    if (emailOrUser.contains('@')) {
      _username = emailOrUser.split('@')[0];
    } else {
      _username = emailOrUser;
    }
    notifyListeners();
  }

  void logout() {
    _username = '';
    notifyListeners();
  }
}
