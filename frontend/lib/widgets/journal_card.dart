import 'package:flutter/material.dart';
import '../models/journal.dart';

class JournalCard extends StatelessWidget {
  final Journal journal;
  final VoidCallback? onTap;
  const JournalCard({super.key, required this.journal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final preview = journal.content.length > 80 ? '${journal.content.substring(0, 77)}...' : journal.content;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        onTap: onTap,
        title: Text(journal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(preview),
            const SizedBox(height: 6),
            Text('${journal.author} • ${journal.date.toLocal().toString().split('.').first}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
