import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_system/models/note_model.dart';

class NotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Note>> fetchNotes(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Note.fromMap({
          'id': doc.id,
          ...doc.data(),
        })).toList();
  }

  Future<void> addNote(String userId, String text) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .add({
          'text': text,
          'createdAt': DateTime.now(),
        });
  }

  Future<void> updateNote(String userId, String noteId, String text) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .update({'text': text});
  }

  Future<void> deleteNote(String userId, String noteId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }
}