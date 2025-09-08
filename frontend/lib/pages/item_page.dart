import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';
import '../widgets/journal_card.dart';
import 'detail_page.dart';

class ItemPage extends StatefulWidget {
  final String? initialJournalId;
  const ItemPage({super.key, this.initialJournalId});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _showAddDialog() async {
    final prov = Provider.of<JournalProvider>(context, listen: false);
    final auth = Provider.of(context, listen: false);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Journal'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
          TextField(controller: _content, decoration: const InputDecoration(labelText: 'Content'), maxLines: 4),
        ]),
        actions: [
          TextButton(onPressed: () { _title.clear(); _content.clear(); Navigator.pop(context); }, child: const Text('Batal')),
          ElevatedButton(onPressed: () async {
            if (_title.text.trim().isEmpty || _content.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title & Content tidak boleh kosong')));
              return;
            }
            await prov.addJournal(title: _title.text.trim(), content: _content.text.trim(), author: 'you');
            _title.clear(); _content.clear();
            Navigator.pop(context);
          }, child: const Text('Simpan')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<JournalProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Journals')),
      body: prov.loading
          ? const Center(child: CircularProgressIndicator())
          : prov.journals.isEmpty
              ? const Center(child: Text('Belum ada journal'))
              : ListView.builder(
                  itemCount: prov.journals.length,
                  itemBuilder: (context, i) {
                    final j = prov.journals[i];
                    return JournalCard(
                      journal: j,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(journal: j))),
                    );
                  }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
