import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/journal.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

class JournalProvider extends ChangeNotifier {
  List<Journal> _journals = [];
  Map<String, List<CommentModel>> _comments = {};
  bool loading = false;

  List<Journal> get journals => _journals;
  List<CommentModel> commentsFor(String journalId) => _comments[journalId] ?? [];

  Future<void> loadJournals() async {
    loading = true;
    notifyListeners();
    try {
      final data = await ApiService.fetchJournals();
      _journals = data;
    } catch (e) {
      // fallback sample data jika API belum tersedia
      _journals = [
        Journal(
          id: 'sample-1',
          title: 'Hari Pertama Journaling',
          content: 'Mulai journaling hari ini. Menulis apa yang saya syukuri...',
          date: DateTime.now().subtract(const Duration(days: 1)),
          author: 'user',
        ),
        Journal(
          id: 'sample-2',
          title: 'Refleksi Minggu',
          content: 'Minggu ini berjalan baik, project hampir selesai...',
          date: DateTime.now(),
          author: 'user',
        ),
      ];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addJournal({required String title, required String content, required String author}) async {
    final j = Journal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      date: DateTime.now(),
      author: author,
    );
    // coba ke API, jika gagal simpan lokal
    try {
      final created = await ApiService.createJournal(j);
      _journals.insert(0, created);
    } catch (e) {
      _journals.insert(0, j);
    }
    notifyListeners();
  }

  Future<void> updateJournal(Journal newJournal) async {
    try {
      final updated = await ApiService.updateJournal(newJournal);
      final idx = _journals.indexWhere((e) => e.id == updated.id);
      if (idx != -1) _journals[idx] = updated;
    } catch (e) {
      final idx = _journals.indexWhere((e) => e.id == newJournal.id);
      if (idx != -1) _journals[idx] = newJournal;
    }
    notifyListeners();
  }

  Future<void> deleteJournal(String id) async {
    try {
      await ApiService.deleteJournal(id);
      _journals.removeWhere((e) => e.id == id);
    } catch (e) {
      _journals.removeWhere((e) => e.id == id);
    }
    notifyListeners();
  }

  void addComment(String journalId, CommentModel comment) {
    _comments.putIfAbsent(journalId, () => []).add(comment);
    notifyListeners();
  }

  String prettyDate(DateTime d) => DateFormat.yMMMd().add_Hm().format(d);
}
