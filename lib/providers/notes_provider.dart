import 'package:flutter/material.dart';
import 'package:note_system/models/note_model.dart';
import 'package:note_system/repositories/notes_repository.dart';

class NotesProvider with ChangeNotifier {
  final NotesRepository _repository = NotesRepository();
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotes(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _repository.fetchNotes(userId);
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch notes';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(String userId, String text) async {
    try {
      await _repository.addNote(userId, text);
      await fetchNotes(userId); // Refresh the list
    } catch (e) {
      _error = 'Failed to add note';
      notifyListeners();
    }
  }

  Future<void> updateNote(String userId, String noteId, String text) async {
    try {
      await _repository.updateNote(userId, noteId, text);
      await fetchNotes(userId); // Refresh the list
    } catch (e) {
      _error = 'Failed to update note';
      notifyListeners();
    }
  }

  Future<void> deleteNote(String userId, String noteId) async {
    try {
      await _repository.deleteNote(userId, noteId);
      await fetchNotes(userId); // Refresh the list
    } catch (e) {
      _error = 'Failed to delete note';
      notifyListeners();
    }
  }
}