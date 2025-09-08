class CommentModel {
  final String id;
  final String username;
  final String content;
  final DateTime date;

  CommentModel({
    required this.id,
    required this.username,
    required this.content,
    required this.date,
  });

  factory CommentModel.fromJson(Map<String, dynamic> j) => CommentModel(
    id: j['id'].toString(),
    username: j['username'],
    content: j['content'],
    date: DateTime.parse(j['date']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'content': content,
    'date': date.toIso8601String(),
  };
}
