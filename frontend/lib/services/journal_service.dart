import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class JournalService {
  final String baseUrl = "http://10.0.2.2:5000/api"; // sama kayak auth

  Future<List<dynamic>> getJournals() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/journals"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load journals");
    }
  }

  Future<bool> addJournal(String title, String content) async {
    final token = await AuthService().getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/journals"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"title": title, "content": content}),
    );
    return response.statusCode == 201;
  }

  Future<bool> updateJournal(String id, String title, String content) async {
    final token = await AuthService().getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/journals/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"title": title, "content": content}),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteJournal(String id) async {
    final token = await AuthService().getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/journals/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
    return response.statusCode == 200;
  }
}
