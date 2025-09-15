import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  String _username = '';
  String _email = '';
  String _token = '';
  bool _loading = false;
  String _error = '';

  String get username => _username;
  String get email => _email;
  String get token => _token;
  bool get loading => _loading;
  String get error => _error;
  String get baseUrl => dotenv.env['BASE_URL_PROD']!;

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = '';
    notifyListeners();
    
    try {
      final success = await _authService.login(email, password);
      if (success != null) {
        _token = (await _authService.getToken()) ?? '';
        // You might want to fetch user profile here to get username
        return true;
      } else {
        _error = 'Login failed';
        return false;
      }
    } catch (e) {
      _error = 'Login error: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _username = '';
    _email = '';
    _token = '';
    _error = '';
    notifyListeners();
  }

  Future<String?> getToken() async {
    return await _authService.getToken();
  }
}