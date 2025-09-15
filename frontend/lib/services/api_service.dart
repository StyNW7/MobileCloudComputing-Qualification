import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // For Android emulator use 10.0.2.2, for iOS use localhost
  // static const String baseUrl = 'http://10.0.2.2:5000/api';
  static final String baseUrl = dotenv.env['BASE_URL_PROD']!;
  
  // Helper method to get auth token
  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  static Future<List<Journal>> fetchJournals() async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      print('Fetching journals from: $baseUrl/journals');
      
      final response = await http.get(
        Uri.parse('$baseUrl/journals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Fetched ${data.length} journals');
        
        // Debug: print the first journal to see its structure
        if (data.isNotEmpty) {
          print('First journal: ${data[0]}');
        }
        
        return data.map((e) => Journal.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load journals: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in fetchJournals: $e');
      rethrow;
    }
  }

  static Future<Journal> createJournal(String title, String content) async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/journals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'content': content,
        }),
      );
      
      if (response.statusCode == 201) {
        return Journal.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create journal: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in createJournal: $e');
      rethrow;
    }
  }

  // Keep updateJournal and deleteJournal methods similar to createJournal
}