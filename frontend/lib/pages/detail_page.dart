import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/journal.dart';
import '../models/comment.dart';
import '../providers/journal_provider.dart';
import '../providers/comment_provider.dart';
import '../providers/auth_provider.dart';

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
  final ScrollController _scrollController = ScrollController();
  final Map<String, TextEditingController> _replyControllers = {};
  final Map<String, bool> _showReplyBox = {};
  final Map<String, TextEditingController> _editControllers = {};
  final Map<String, bool> _isEditing = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Setup scroll controller for pagination
    _scrollController.addListener(_onScroll);

    // Listen for tab changes to refresh comments
    _tabController.addListener(() {
      if (_tabController.index == 1 && mounted) {
        // Use Future.microtask to ensure the widget is mounted and context is available
        Future.microtask(() {
          context.read<CommentProvider>().loadComments(widget.journal.id);
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load comments when the page is built and dependencies are available
    if (_tabController.index == 1) {
      context.read<CommentProvider>().loadComments(widget.journal.id);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      final commentProvider = context.read<CommentProvider>();
      if (commentProvider.hasMoreComments && !commentProvider.loading) {
        commentProvider.loadMoreComments();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    
    // Dispose all reply and edit controllers
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    for (var controller in _editControllers.values) {
      controller.dispose();
    }
    
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
          _buildDetailsTab(),
          _buildCommentsTab(),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image (placeholder)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1455390582262-044cdead277a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1073&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.journal.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'By ${widget.journal.authorName}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Created: ${widget.journal.formattedCreatedAt}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            widget.journal.content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          
          // Review/Comment input section
          const Text(
            'Add Your Review',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Your review',
              border: OutlineInputBorder(),
              hintText: 'Share your thoughts about this journal...',
            ),
            maxLines: 4,
            maxLength: 500,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _submitReview(context),
              child: const Text('Submit Review'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsTab() {
    return Consumer<CommentProvider>(
      builder: (context, commentProvider, child) {
        // Load comments when this tab is built
        if (commentProvider.comments.isEmpty && !commentProvider.loading) {
          Future.microtask(() {
            commentProvider.loadComments(widget.journal.id);
          });
        }

        if (commentProvider.loading && commentProvider.comments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Comment input section
            _buildCommentInputSection(commentProvider),
            
            // Error display
            if (commentProvider.error.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        commentProvider.error,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: commentProvider.clearError,
                      color: Colors.red[700],
                    ),
                  ],
                ),
              ),

            // Comments list
            Expanded(
              child: commentProvider.comments.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.comment_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No comments yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Be the first to comment!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: commentProvider.comments.length + 
                          (commentProvider.hasMoreComments ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == commentProvider.comments.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
                        final comment = commentProvider.comments[index];
                        return _buildCommentItem(comment, commentProvider);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentInputSection(CommentProvider commentProvider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add a Comment',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Write your comment here...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _submitComment(commentProvider),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, CommentProvider commentProvider) {
    final isReplying = _showReplyBox[comment.id] ?? false;
    final isEditing = _isEditing[comment.id] ?? false;
    
    // Initialize controllers if they don't exist
    if (!_replyControllers.containsKey(comment.id)) {
      _replyControllers[comment.id] = TextEditingController();
    }
    if (!_editControllers.containsKey(comment.id)) {
      _editControllers[comment.id] = TextEditingController(text: comment.content);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comment header with user info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    comment.authorName.isNotEmpty 
                      ? comment.authorName[0].toUpperCase() 
                      : 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        comment.formattedCreatedAt,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit/Delete buttons (if user owns the comment)
                FutureBuilder<bool>(
                  future: commentProvider.canModifyComment(comment),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == true) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => _toggleEditMode(comment.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18),
                            onPressed: () => _deleteComment(commentProvider, comment.id),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Comment content (editable if in edit mode)
            if (isEditing)
              TextField(
                controller: _editControllers[comment.id],
                maxLines: 3,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () => _updateComment(commentProvider, comment.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _toggleEditMode(comment.id),
                      ),
                    ],
                  ),
                ),
              )
            else
              Text(
                comment.content,
                style: const TextStyle(fontSize: 14),
              ),
            
            if (comment.isEdited)
              Text(
                'Edited',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            
            const SizedBox(height: 8),
            
            // Reply button and action buttons
            Row(
              children: [
                TextButton(
                  onPressed: () => _toggleReplyBox(comment.id),
                  child: Text(isReplying ? 'Cancel' : 'Reply'),
                ),
                const Spacer(),
                // Like and other actions can be added here
              ],
            ),
            
            // Reply input box
            if (isReplying)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: _replyControllers[comment.id],
                  decoration: InputDecoration(
                    hintText: 'Write your reply...',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _submitReply(commentProvider, comment.id),
                    ),
                  ),
                  maxLines: 2,
                ),
              ),
            
            // Replies list
            if (comment.replies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: Column(
                  children: comment.replies.map((reply) => 
                    _buildReplyItem(reply, commentProvider)
                  ).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyItem(Comment reply, CommentProvider commentProvider) {
    return Card(
      color: Colors.grey[50],
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[100],
                  radius: 12,
                  child: Text(
                    reply.authorName.isNotEmpty 
                      ? reply.authorName[0].toUpperCase() 
                      : 'U',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reply.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        reply.formattedCreatedAt,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit/Delete buttons for reply
                FutureBuilder<bool>(
                  future: commentProvider.canModifyComment(reply),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == true) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 16),
                            onPressed: () => _toggleEditMode(reply.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 16),
                            onPressed: () => _deleteComment(commentProvider, reply.id),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              reply.content,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _submitReview(BuildContext context) {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a review before submitting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final commentProvider = Provider.of<CommentProvider>(context, listen: false);
    _submitComment(commentProvider);
  }

  void _submitComment(CommentProvider commentProvider) async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    final success = await commentProvider.createComment(
      widget.journal.id, 
      _commentController.text.trim()
    );

    if (success) {
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add comment: ${commentProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitReply(CommentProvider commentProvider, String parentCommentId) async {
    final replyController = _replyControllers[parentCommentId];
    if (replyController == null || replyController.text.trim().isEmpty) {
      return;
    }

    final success = await commentProvider.replyToComment(
      widget.journal.id, 
      parentCommentId, 
      replyController.text.trim()
    );

    if (success) {
      replyController.clear();
      _toggleReplyBox(parentCommentId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add reply: ${commentProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateComment(CommentProvider commentProvider, String commentId) async {
    final editController = _editControllers[commentId];
    if (editController == null || editController.text.trim().isEmpty) {
      return;
    }

    final success = await commentProvider.updateComment(
      commentId, 
      editController.text.trim()
    );

    if (success) {
      _toggleEditMode(commentId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update comment: ${commentProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteComment(CommentProvider commentProvider, String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await commentProvider.deleteComment(commentId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete comment: ${commentProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleReplyBox(String commentId) {
    setState(() {
      _showReplyBox[commentId] = !(_showReplyBox[commentId] ?? false);
    });
  }

  void _toggleEditMode(String commentId) {
    setState(() {
      _isEditing[commentId] = !(_isEditing[commentId] ?? false);
    });
  }
}