import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/journal.dart';

class ApiService {
  // Untuk Android emulator gunakan 10.0.2.2
  static const String baseUrl = 'http://10.0.2.2:5000/api/journals';

  static Future<List<Journal>> fetchJournals() async {
    final res = await http.get(Uri.parse('$baseUrl/journals'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Journal.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load journals');
    }
  }

  static Future<Journal> createJournal(Journal j) async {
    final res = await http.post(
      Uri.parse('$baseUrl/journals'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(j.toJson()),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return Journal.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to create journal');
    }
  }

  static Future<Journal> updateJournal(Journal j) async {
    final res = await http.put(
      Uri.parse('$baseUrl/journals/${j.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(j.toJson()),
    );
    if (res.statusCode == 200) {
      return Journal.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to update');
    }
  }

  static Future<void> deleteJournal(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/journals/$id'));
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete');
    }
  }
}
