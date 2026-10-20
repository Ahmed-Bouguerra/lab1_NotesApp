import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/note_item.dart';
import '../components/note_input_dialog.dart';
import '../models/note.dart';
import '../services/notes_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> notes = [];
  bool loading = true;
  String? error;

  TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  // Load notes from Firestore
  Future<void> loadNotes() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await notesService.list();
      if (!mounted) return;
      setState(() => notes = result);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => error = e.message ?? 'Could not load notes');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Open the dialog and return the typed text (null if cancelled)
  Future<String?> askText({Note? initial}) {
    noteController.text = initial?.content ?? '';
    return showDialog<String>(
      context: context,
      builder: (context) => NoteInputDialog(
        controller: noteController,
        isEditing: initial != null,
      ),
    );
  }

  // Add a new note
  Future<void> addNote() async {
    final text = await askText();
    if (text == null || text.isEmpty) return;
    try {
      final created = await notesService.create(text);
      if (!mounted) return;
      setState(() => notes.insert(0, created));
    } on FirebaseException catch (e) {
      showError(e.message ?? 'Could not save the note');
    }
  }

  // Edit an existing note
  Future<void> editNote(Note note) async {
    final text = await askText(initial: note);
    if (text == null || text.isEmpty) return;
    try {
      final updated = await notesService.update(note.id, text);
      if (!mounted) return;
      setState(() {
        final index = notes.indexWhere((n) => n.id == note.id);
        if (index != -1) notes[index] = updated;
      });
    } on FirebaseException catch (e) {
      showError(e.message ?? 'Could not update the note');
    }
  }

  // Delete a note (with confirmation)
  Future<void> deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete note'),
        content: Text('Delete "${note.content}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await notesService.delete(note.id);
      if (!mounted) return;
      setState(() => notes.removeWhere((n) => n.id == note.id));
    } on FirebaseException catch (e) {
      showError(e.message ?? 'Could not delete the note');
    }
  }

  Widget buildBody() {
    if (loading && notes.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error!, textAlign: TextAlign.center),
            SizedBox(height: 12),
            ElevatedButton(onPressed: loadNotes, child: Text('Retry')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadNotes,
      child: notes.isEmpty
          ? ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No notes yet. Create one!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: EdgeInsets.all(15),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteItem(
                  key: ValueKey(note.id),
                  note: note,
                  onEdit: () => editNote(note),
                  onDelete: () => deleteNote(note),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with title and add button
          Container(
            height: 100,
            color: Colors.blue,
            padding: EdgeInsets.only(
              bottom: 15,
              left: 20,
              right: 20,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Notes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: addNote,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        '+',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(child: buildBody()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
}
