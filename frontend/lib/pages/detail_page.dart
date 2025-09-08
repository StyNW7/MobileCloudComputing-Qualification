import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/journal.dart';
import '../models/comment.dart';
import '../providers/journal_provider.dart';

class DetailPage extends StatefulWidget {
  final Journal journal;
  const DetailPage({super.key, required this.journal});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Komentar tidak boleh kosong')));
      return;
    }
    final prov = Provider.of<JournalProvider>(context, listen: false);
    final comment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: 'you',
      content: text,
      date: DateTime.now(),
    );
    prov.addComment(widget.journal.id, comment);
    _commentCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Komentar ditambahkan')));
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<JournalProvider>(context);
    final comments = prov.commentsFor(widget.journal.id);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.journal.title),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.article), text: 'Detail'),
            Tab(icon: Icon(Icons.comment), text: 'Comments'),
          ]),
        ),
        body: TabBarView(children: [
          // Tab 1: Detail + comment field
          ListView(padding: const EdgeInsets.all(12), children: [
            Text(widget.journal.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('By ${widget.journal.author} • ${widget.journal.date.toLocal().toString().split('.').first}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Text(widget.journal.content),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              decoration: const InputDecoration(
                labelText: 'Tambahkan komentar',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 4,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(onPressed: _submitComment, icon: const Icon(Icons.send), label: const Text('Kirim')),
          ]),

          // Tab 2: list comments
          comments.isEmpty
              ? const Center(child: Text('Belum ada komentar'))
              : ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, i) {
                    final c = comments[i];
                    return ListTile(
                      title: Text(c.username),
                      subtitle: Text(c.content),
                      trailing: Text(c.date.toLocal().toString().split('.').first, style: const TextStyle(fontSize: 11)),
                    );
                  },
                ),
        ]),
      ),
    );
  }
}
