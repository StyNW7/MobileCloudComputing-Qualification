import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/journal.dart';
import '../providers/journal_provider.dart';

class DetailPage extends StatefulWidget {
  final Journal journal;

  const DetailPage({super.key, required this.journal});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.journal.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.description), text: 'Details'),
            Tab(icon: Icon(Icons.comment), text: 'Comments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Details Tab
          _buildDetailsTab(),
          // Comments Tab
          _buildCommentsTab(),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.journal.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Created: ${widget.journal.createdAt.toString().split('.').first}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            widget.journal.content,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          const Text(
            'Add Comment:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Write your comment here...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_commentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Comment cannot be empty'),
                  ),
                );
              } else {
                // In a real app, you would save the comment to your backend
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Comment added: ${_commentController.text}'),
                  ),
                );
                _commentController.clear();
              }
            },
            child: const Text('Add Comment'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsTab() {
    // This would normally come from your backend
    final dummyComments = [
      {'user': 'User1', 'comment': 'Great journal entry!'},
      {'user': 'User2', 'comment': 'I enjoyed reading this.'},
      {'user': 'User3', 'comment': 'Very insightful.'},
    ];

    return ListView.builder(
      itemCount: dummyComments.length,
      itemBuilder: (context, index) {
        final comment = dummyComments[index];
        return Card(
          child: ListTile(
            title: Text(comment['user']!),
            subtitle: Text(comment['comment']!),
          ),
        );
      },
    );
  }
}