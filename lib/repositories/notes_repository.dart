import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:note_system/models/note_model.dart';

class NotesRepository {
  final FirebaseFirestore _firestore;

  NotesRepository({FirebaseFirestore? firestore}) 
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> _checkConnection() async {
    try {
      // Test basic Firestore operation
      await _firestore.collection('connection_test').doc('ping').set({
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Firestore connection test successful');
    } catch (e) {
      debugPrint('❌ Firestore connection test failed: $e');
      rethrow;
    }
  }

  Future<List<Note>> fetchNotes(String userId) async {
    try {
      await _checkConnection();
      debugPrint('📥 Fetching notes for user: $userId');
      
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint('📥 Retrieved ${snapshot.docs.length} notes');
      return snapshot.docs.map((doc) => Note.fromMap({
            'id': doc.id,
            ...doc.data(),
          })).toList();
    } catch (e) {
      debugPrint('❌ Error fetching notes: $e');
      rethrow;
    }
  }

  Future<void> addNote(String userId, String text) async {
    try {
      await _checkConnection();
      debugPrint('➕ Adding note for user: $userId');
      debugPrint('📝 Note content: $text');

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .add({
            'text': text,
            'createdAt': FieldValue.serverTimestamp(), // Use server timestamp
          });

      debugPrint('✅ Note added successfully with ID: ${docRef.id}');
    } catch (e, stack) {
      debugPrint('''❌ CRITICAL ERROR ADDING NOTE:
      Error: $e
      Stack: $stack
      UserID: $userId
      NoteText: $text''');
      rethrow;
    }
  }

  Future<void> updateNote(String userId, String noteId, String text) async {
    try {
      await _checkConnection();
      debugPrint('✏️ Updating note $noteId for user $userId');
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(noteId)
          .update({
            'text': text,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      
      debugPrint('✅ Note updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating note: $e');
      rethrow;
    }
  }

  Future<void> deleteNote(String userId, String noteId) async {
    try {
      await _checkConnection();
      debugPrint('🗑️ Deleting note $noteId for user $userId');
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(noteId)
          .delete();
      
      debugPrint('✅ Note deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting note: $e');
      rethrow;
    }
  }
}