// models/journal.dart
class Journal {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String authorEmail;
  final DateTime createdAt;
  final DateTime updatedAt;

  Journal({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Journal.fromJson(Map<String, dynamic> json) {
    try {
      // Handle author data - it could be a string ID or a populated object
      dynamic authorData = json['author'];
      String authorId = '';
      String authorName = 'Unknown';
      String authorEmail = '';

      if (authorData != null) {
        if (authorData is String) {
          // Author is just an ID string
          authorId = authorData;
        } else if (authorData is Map<String, dynamic>) {
          // Author is a populated object
          authorId = authorData['_id']?.toString() ?? '';
          authorName = authorData['username']?.toString() ?? 'Unknown';
          authorEmail = authorData['email']?.toString() ?? '';
        }
      }

      return Journal(
        id: json['_id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        authorId: authorId,
        authorName: authorName,
        authorEmail: authorEmail,
        createdAt: _parseDate(json['createdAt']),
        updatedAt: _parseDate(json['updatedAt']),
      );
    } catch (e) {
      print('Error parsing journal from JSON: $e');
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
      'title': title,
      'content': content,
      'author': authorId, // Only send the author ID to backend
    };
  }

  // Helper method to get formatted date string
  String get formattedCreatedAt {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  String get formattedUpdatedAt {
    return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year} ${updatedAt.hour}:${updatedAt.minute.toString().padLeft(2, '0')}';
  }

  // Helper method to get content preview
  String get contentPreview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  // Copy with method for updating
  Journal copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    String? authorEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Journal(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Journal{id: $id, title: $title, authorName: $authorName, createdAt: $createdAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Journal &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}