import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_system/models/note_model.dart';
import 'package:provider/provider.dart';
import 'package:note_system/providers/notes_provider.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late final User _user;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadNotes();
      }
    });
  }

  Future<void> _loadNotes() async {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    await notesProvider.fetchNotes(_user.uid);
    if (!mounted) return;

    final error = notesProvider.error;
    if (error != null) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showAddNoteDialog() async {
    final textController = TextEditingController();
    final navigator = Navigator.of(context);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Enter your note'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final text = textController.text.trim();
                if (text.isNotEmpty) {
                  navigator.pop(text);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null) return;

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    await notesProvider.addNote(_user.uid, result);
    if (!mounted) return;

    _showResultSnackBar(
      successMessage: 'Note added successfully',
      error: notesProvider.error,
    );
  }

  Future<void> _showEditNoteDialog(Note note) async {
    final textController = TextEditingController(text: note.text);
    final navigator = Navigator.of(context);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Edit your note'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final text = textController.text.trim();
                if (text.isNotEmpty) {
                  navigator.pop(text);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null || result == note.text) return;

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    await notesProvider.updateNote(_user.uid, note.id!, result);
    if (!mounted) return;

    _showResultSnackBar(
      successMessage: 'Note updated successfully',
      error: notesProvider.error,
    );
  }

  Future<void> _showDeleteConfirmationDialog(Note note) async {
    final navigator = Navigator.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => navigator.pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (!mounted || confirm != true) return;

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    await notesProvider.deleteNote(_user.uid, note.id!);
    if (!mounted) return;

    _showResultSnackBar(
      successMessage: 'Note deleted successfully',
      error: notesProvider.error,
    );
  }

  void _showResultSnackBar({required String successMessage, String? error}) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(error ?? successMessage),
        backgroundColor: error == null ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.of(context).pushReplacementNamed('/login');
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddNoteDialog,
          child: const Icon(Icons.add),
        ),
        body: Consumer<NotesProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.notes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.notes.isEmpty) {
              return const Center(
                child: Text('Nothing here yet—tap ➕ to add a note.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.notes.length,
              itemBuilder: (context, index) {
                final note = provider.notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(note.text),
                    subtitle: Text(
                      'Created: ${note.createdAt.toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showEditNoteDialog(note),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () => _showDeleteConfirmationDialog(note),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}