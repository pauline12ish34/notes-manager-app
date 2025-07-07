class Note {
  final String? id;
  final String text;
  final DateTime createdAt;

  Note({
    this.id,
    required this.text,
    required this.createdAt,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      text: map['text'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}