import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class JournalService {
  final String baseUrl = dotenv.env['BASE_URL_PROD']!;

  Future<Map<String, dynamic>> getJournals() async {
    try {
      final token = await AuthService().getToken();
      
      if (token == null) {
        throw Exception("No authentication token found");
      }

      print('Making request to: $baseUrl/journals');
      print('Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse("$baseUrl/journals"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Handle both old format (direct array) and new format (object with journals array)
        if (data.containsKey('journals')) {
          return {
            'count': data['count'] ?? 0,
            'journals': data['journals'] ?? [],
          };
        } else {
          // If response is directly an array (old format)
          return {
            'count': (data as List).length,
            'journals': data,
          };
        }
      } else if (response.statusCode == 401) {
        throw Exception("Authentication failed. Please login again.");
      } else {
        throw Exception("Failed to load journals: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print('Error in getJournals: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addJournal(String title, String content) async {
    try {
      final token = await AuthService().getToken();
      
      if (token == null) {
        throw Exception("No authentication token found");
      }

      final response = await http.post(
        Uri.parse("$baseUrl/journals"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"title": title, "content": content}),
      );

      print('Add journal response status: ${response.statusCode}');
      print('Add journal response body: ${response.body}');

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to add journal: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error adding journal: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateJournal(String id, String title, String content) async {
    try {
      final token = await AuthService().getToken();
      
      if (token == null) {
        throw Exception("No authentication token found");
      }

      final response = await http.put(
        Uri.parse("$baseUrl/journals/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"title": title, "content": content}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to update journal: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error updating journal: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteJournal(String id) async {
    try {
      final token = await AuthService().getToken();
      
      if (token == null) {
        throw Exception("No authentication token found");
      }

      final response = await http.delete(
        Uri.parse("$baseUrl/journals/$id"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Journal deleted successfully',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to delete journal: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error deleting journal: $e',
      };
    }
  }
}