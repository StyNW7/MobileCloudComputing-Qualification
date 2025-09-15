import 'package:flutter/foundation.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import 'auth_provider.dart';

class CommentProvider with ChangeNotifier {
  final AuthProvider auth;
  final CommentService _commentService = CommentService();

  CommentProvider(this.auth);

  List<Comment> _comments = [];
  bool _loading = false;
  String _error = '';
  Map<String, dynamic> _pagination = {};
  String? _currentJournalId;

  List<Comment> get comments => _comments;
  bool get loading => _loading;
  String get error => _error;
  Map<String, dynamic> get pagination => _pagination;

  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Load comments for a specific journal
  Future<void> loadComments(String journalId, {int page = 1, int limit = 20}) async {
    _loading = true;
    _error = '';
    _currentJournalId = journalId;
    notifyListeners();

    try {
      final result = await _commentService.getJournalComments(journalId, page: page, limit: limit);

      if (result['success']) {
        if (page == 1) {
          _comments = result['comments'] ?? [];
        } else {
          _comments.addAll(result['comments'] ?? []);
        }
        _pagination = result['pagination'] ?? {};
        _error = '';
        if (kDebugMode) {
          print('Successfully loaded ${_comments.length} comments for journal $journalId');
        }
      } else {
        _error = result['error'] ?? 'Failed to load comments';
        if (page == 1) {
          _comments = [];
        }
      }
    } catch (e) {
      _error = 'Error loading comments: $e';
      if (page == 1) _comments = [];
      if (kDebugMode) print('Error in loadComments: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Create a new comment
  Future<bool> createComment(String journalId, String content, {String? parentCommentId}) async {
    if (content.trim().isEmpty) {
      _error = 'Comment content cannot be empty';
      notifyListeners();
      return false;
    }

    try {
      final result = await _commentService.createComment(journalId, content.trim(), parentCommentId: parentCommentId);

      if (result['success']) {
        await loadComments(journalId);
        _error = '';
        return true;
      } else {
        _error = result['error'] ?? 'Failed to create comment';
        if (_error.contains('Authentication failed')) await auth.logout();
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error creating comment: $e';
      if (kDebugMode) print('Error in createComment: $e');
      notifyListeners();
      return false;
    }
  }

  // Update a comment
  Future<bool> updateComment(String commentId, String content) async {
    if (content.trim().isEmpty) {
      _error = 'Comment content cannot be empty';
      notifyListeners();
      return false;
    }

    try {
      final result = await _commentService.updateComment(commentId, content.trim());

      if (result['success']) {
        final commentIndex = _comments.indexWhere((c) => c.id == commentId);
        if (commentIndex != -1) {
          _comments[commentIndex] = result['comment'];
        } else {
          for (int i = 0; i < _comments.length; i++) {
            final replyIndex = _comments[i].replies.indexWhere((r) => r.id == commentId);
            if (replyIndex != -1) {
              final updatedReplies = List<Comment>.from(_comments[i].replies);
              updatedReplies[replyIndex] = result['comment'];
              _comments[i] = _comments[i].copyWith(replies: updatedReplies);
              break;
            }
          }
        }
        _error = '';
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Failed to update comment';
        if (_error.contains('Authentication failed')) await auth.logout();
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error updating comment: $e';
      if (kDebugMode) print('Error in updateComment: $e');
      notifyListeners();
      return false;
    }
  }

  // Delete a comment
  Future<bool> deleteComment(String commentId) async {
    try {
      final result = await _commentService.deleteComment(commentId);

      if (result['success']) {
        _comments.removeWhere((c) => c.id == commentId);

        for (int i = 0; i < _comments.length; i++) {
          final updatedReplies = _comments[i].replies.where((r) => r.id != commentId).toList();
          if (updatedReplies.length != _comments[i].replies.length) {
            _comments[i] = _comments[i].copyWith(replies: updatedReplies);
          }
        }

        _error = '';
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Failed to delete comment';
        if (_error.contains('Authentication failed')) await auth.logout();
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error deleting comment: $e';
      if (kDebugMode) print('Error in deleteComment: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> replyToComment(String journalId, String parentCommentId, String content) async {
    return await createComment(journalId, content, parentCommentId: parentCommentId);
  }

  Future<String?> getCurrentUserId() async => await auth.getUserId();
  Future<String?> getCurrentUsername() async => await auth.getUsername();

  Future<bool> canModifyComment(Comment comment) async {
    final currentUserId = await getCurrentUserId();
    return currentUserId == comment.authorId;
  }

  void clearComments() {
    _comments = [];
    _currentJournalId = null;
    _pagination = {};
    _error = '';
    notifyListeners();
  }

  int get totalComments => _pagination['totalComments'] ?? _comments.length;
  bool get hasMoreComments => _pagination['hasNext'] ?? false;

  Future<void> loadMoreComments() async {
    if (_currentJournalId != null && hasMoreComments && !_loading) {
      final currentPage = _pagination['currentPage'] ?? 1;
      await loadComments(_currentJournalId!, page: currentPage + 1);
    }
  }
}
