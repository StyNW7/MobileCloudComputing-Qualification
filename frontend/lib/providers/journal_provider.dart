import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/journal.dart';
import 'auth_provider.dart';

class JournalProvider with ChangeNotifier {
  final AuthProvider auth;
  
  JournalProvider(this.auth);
  
  List<Journal> _journals = [];
  bool _loading = false;
  String _error = '';
  int _totalCount = 0;

  List<Journal> get journals => _journals;
  bool get loading => _loading;
  String get error => _error;
  int get totalCount => _totalCount;

  void clearError() {
    _error = '';
    notifyListeners();
  }

  Future<void> loadJournals() async {
    _loading = true;
    _error = '';
    notifyListeners();
    
    try {
      final token = await auth.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated - please login again');
      }

      print('Loading journals with token: ${token.substring(0, 20)}...');
      
      final response = await http.get(
        Uri.parse('${auth.baseUrl}/journals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        List<dynamic> journalsData;
        
        // Handle both response formats
        if (responseData is Map<String, dynamic>) {
          // New format with count and journals
          _totalCount = responseData['count'] ?? 0;
          journalsData = responseData['journals'] ?? [];
        } else if (responseData is List) {
          // Old format - direct array
          journalsData = responseData;
          _totalCount = journalsData.length;
        } else {
          throw Exception('Unexpected response format');
        }
        
        _journals = journalsData.map((json) {
          try {
            return Journal.fromJson(json);
          } catch (e) {
            print('Error parsing journal: $e');
            print('Journal data: $json');
            rethrow;
          }
        }).toList();
        
        _error = '';
        print('Successfully loaded ${_journals.length} journals');
      } else if (response.statusCode == 401) {
        _error = 'Authentication failed. Please login again.';
        // Optionally trigger logout
        await auth.logout();
      } else {
        _error = 'Failed to load journals: ${response.statusCode}';
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            _error = errorData['message'] ?? _error;
          } catch (e) {
            _error += ' - ${response.body}';
          }
        }
      }
    } catch (e) {
      _error = 'Error loading journals: $e';
      print('Error in loadJournals: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  Future<bool> addJournal(String title, String content) async {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      _error = 'Title and content cannot be empty';
      notifyListeners();
      return false;
    }

    try {
      final token = await auth.getToken();
      if (token == null || token.isEmpty) {
        _error = 'Not authenticated - please login again';
        notifyListeners();
        return false;
      }
      
      final response = await http.post(
        Uri.parse('${auth.baseUrl}/journals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': title.trim(),
          'content': content.trim(),
        }),
      );
      
      print('Add journal response: ${response.statusCode}');
      print('Add journal body: ${response.body}');
      
      if (response.statusCode == 201) {
        await loadJournals(); // Reload the list
        _error = '';
        return true;
      } else if (response.statusCode == 401) {
        _error = 'Authentication failed. Please login again.';
        await auth.logout();
        notifyListeners();
        return false;
      } else {
        try {
          final errorData = json.decode(response.body);
          _error = errorData['message'] ?? 'Failed to add journal';
        } catch (e) {
          _error = 'Failed to add journal: ${response.statusCode}';
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error adding journal: $e';
      print('Error in addJournal: $e');
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateJournal(String id, String title, String content) async {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      _error = 'Title and content cannot be empty';
      notifyListeners();
      return false;
    }

    try {
      final token = await auth.getToken();
      if (token == null || token.isEmpty) {
        _error = 'Not authenticated - please login again';
        notifyListeners();
        return false;
      }
      
      final response = await http.put(
        Uri.parse('${auth.baseUrl}/journals/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': title.trim(),
          'content': content.trim(),
        }),
      );
      
      if (response.statusCode == 200) {
        await loadJournals(); // Reload the list
        _error = '';
        return true;
      } else if (response.statusCode == 401) {
        _error = 'Authentication failed. Please login again.';
        await auth.logout();
        notifyListeners();
        return false;
      } else if (response.statusCode == 404) {
        _error = 'Journal not found';
        notifyListeners();
        return false;
      } else {
        try {
          final errorData = json.decode(response.body);
          _error = errorData['message'] ?? 'Failed to update journal';
        } catch (e) {
          _error = 'Failed to update journal: ${response.statusCode}';
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error updating journal: $e';
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteJournal(String id) async {
    try {
      final token = await auth.getToken();
      if (token == null || token.isEmpty) {
        _error = 'Not authenticated - please login again';
        notifyListeners();
        return false;
      }
      
      final response = await http.delete(
        Uri.parse('${auth.baseUrl}/journals/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        await loadJournals(); // Reload the list
        _error = '';
        return true;
      } else if (response.statusCode == 401) {
        _error = 'Authentication failed. Please login again.';
        await auth.logout();
        notifyListeners();
        return false;
      } else if (response.statusCode == 404) {
        _error = 'Journal not found';
        notifyListeners();
        return false;
      } else {
        try {
          final errorData = json.decode(response.body);
          _error = errorData['message'] ?? 'Failed to delete journal';
        } catch (e) {
          _error = 'Failed to delete journal: ${response.statusCode}';
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error deleting journal: $e';
      notifyListeners();
      return false;
    }
  }

  // Helper method to get a single journal by ID
  Journal? getJournalById(String id) {
    try {
      return _journals.firstWhere((journal) => journal.id == id);
    } catch (e) {
      return null;
    }
  }
}