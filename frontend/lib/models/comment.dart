class Comment {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final String authorEmail;
  final String journalId;
  final String? parentCommentId;
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorEmail,
    required this.journalId,
    this.parentCommentId,
    this.isEdited = false,
    this.editedAt,
    required this.createdAt,
    required this.updatedAt,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    try {
      // Handle author data
      dynamic authorData = json['author'];
      String authorId = '';
      String authorName = 'Unknown';
      String authorEmail = '';

      if (authorData != null) {
        if (authorData is String) {
          authorId = authorData;
        } else if (authorData is Map<String, dynamic>) {
          authorId = authorData['_id']?.toString() ?? '';
          authorName = authorData['username']?.toString() ?? 'Unknown';
          authorEmail = authorData['email']?.toString() ?? '';
        }
      }

      // Handle replies
      List<Comment> replies = [];
      if (json['replies'] != null && json['replies'] is List) {
        replies = (json['replies'] as List)
            .map((reply) => Comment.fromJson(reply))
            .toList();
      }

      return Comment(
        id: json['_id']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        authorId: authorId,
        authorName: authorName,
        authorEmail: authorEmail,
        journalId: json['journal']?.toString() ?? '',
        parentCommentId: json['parentComment']?.toString(),
        isEdited: json['isEdited'] ?? false,
        editedAt: json['editedAt'] != null ? _parseDate(json['editedAt']) : null,
        createdAt: _parseDate(json['createdAt']),
        updatedAt: _parseDate(json['updatedAt']),
        replies: replies,
      );
    } catch (e) {
      print('Error parsing comment from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        print('Error parsing date: $dateValue');
        return DateTime.now();
      }
    }
    
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'parentCommentId': parentCommentId,
    };
  }

  // Helper methods
  String get formattedCreatedAt {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Comment copyWith({
    String? id,
    String? content,
    String? authorId,
    String? authorName,
    String? authorEmail,
    String? journalId,
    String? parentCommentId,
    bool? isEdited,
    DateTime? editedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      journalId: journalId ?? this.journalId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replies: replies ?? this.replies,
    );
  }

  @override
  String toString() {
    return 'Comment{id: $id, content: ${content.length > 20 ? content.substring(0, 20) + '...' : content}, authorName: $authorName}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}