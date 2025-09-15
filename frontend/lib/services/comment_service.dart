import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';
import '../models/comment.dart';

class CommentService {
  final String baseUrl = dotenv.env['BASE_URL_PROD']!;
  final AuthService _authService = AuthService();

  // Get comments for a specific journal
  Future<Map<String, dynamic>> getJournalComments(String journalId, {int page = 1, int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/journals/$journalId/comments?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Get comments response status: ${response.statusCode}');
      print('Get comments response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        List<Comment> comments = [];
        if (data['comments'] != null) {
          comments = (data['comments'] as List)
              .map((commentJson) => Comment.fromJson(commentJson))
              .toList();
        }

        return {
          'success': true,
          'comments': comments,
          'pagination': data['pagination'] ?? {},
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load comments: ${response.statusCode} - ${response.body}',
          'comments': <Comment>[],
          'pagination': {},
        };
      }
    } catch (e) {
      print('Error in getJournalComments: $e');
      return {
        'success': false,
        'error': 'Error loading comments: $e',
        'comments': <Comment>[],
        'pagination': {},
      };
    }
  }

  // Create a new comment
  Future<Map<String, dynamic>> createComment(String journalId, String content, {String? parentCommentId}) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'error': 'Authentication token not found',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/journals/$journalId/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'content': content,
          if (parentCommentId != null) 'parentCommentId': parentCommentId,
        }),
      );

      print('Create comment response status: ${response.statusCode}');
      print('Create comment response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'comment': Comment.fromJson(data['comment']),
          'message': data['message'],
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Authentication failed. Please login again.',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to create comment',
        };
      }
    } catch (e) {
      print('Error in createComment: $e');
      return {
        'success': false,
        'error': 'Error creating comment: $e',
      };
    }
  }

  // Update a comment
  Future<Map<String, dynamic>> updateComment(String commentId, String content) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'error': 'Authentication token not found',
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/comments/$commentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'content': content,
        }),
      );

      print('Update comment response status: ${response.statusCode}');
      print('Update comment response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'comment': Comment.fromJson(data['comment']),
          'message': data['message'],
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Authentication failed. Please login again.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Comment not found or you don\'t have permission to edit it',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to update comment',
        };
      }
    } catch (e) {
      print('Error in updateComment: $e');
      return {
        'success': false,
        'error': 'Error updating comment: $e',
      };
    }
  }

  // Delete a comment
  Future<Map<String, dynamic>> deleteComment(String commentId) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'error': 'Authentication token not found',
        };
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/comments/$commentId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete comment response status: ${response.statusCode}');
      print('Delete comment response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Authentication failed. Please login again.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Comment not found or you don\'t have permission to delete it',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to delete comment',
        };
      }
    } catch (e) {
      print('Error in deleteComment: $e');
      return {
        'success': false,
        'error': 'Error deleting comment: $e',
      };
    }
  }

  // Get user's own comments
  Future<Map<String, dynamic>> getUserComments({int page = 1, int limit = 20}) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'error': 'Authentication token not found',
          'comments': <Comment>[],
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/comments?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get user comments response status: ${response.statusCode}');
      print('Get user comments response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        List<Comment> comments = [];
        if (data['comments'] != null) {
          comments = (data['comments'] as List)
              .map((commentJson) => Comment.fromJson(commentJson))
              .toList();
        }

        return {
          'success': true,
          'comments': comments,
          'pagination': data['pagination'] ?? {},
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Authentication failed. Please login again.',
          'comments': <Comment>[],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load user comments: ${response.statusCode} - ${response.body}',
          'comments': <Comment>[],
        };
      }
    } catch (e) {
      print('Error in getUserComments: $e');
      return {
        'success': false,
        'error': 'Error loading user comments: $e',
        'comments': <Comment>[],
      };
    }
  }
}