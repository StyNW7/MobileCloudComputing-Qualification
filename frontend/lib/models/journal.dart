class Journal {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String author;

  Journal({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.author,
  });

  factory Journal.fromJson(Map<String, dynamic> json) => Journal(
    id: json['id'].toString(),
    title: json['title'],
    content: json['content'],
    date: DateTime.parse(json['date']),
    author: json['author'] ?? 'Anonymous',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'date': date.toIso8601String(),
    'author': author,
  };
}
