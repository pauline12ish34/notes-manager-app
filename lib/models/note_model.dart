import 'package:cloud_firestore/cloud_firestore.dart';

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
      text: map['text'] ?? '', // Handle null text
      createdAt: _parseTimestamp(map['createdAt']),
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    if (timestamp is String) return DateTime.parse(timestamp);
    throw FormatException('Invalid timestamp format: $timestamp');
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'createdAt': FieldValue.serverTimestamp(), 
    };
  }
}