import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note.dart';

class NotesService {
  final _notes = FirebaseFirestore.instance.collection('notes');

  Future<List<Note>> list() async {
    final snapshot =
        await _notes.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map(Note.fromDoc).toList();
  }

  Future<Note> create(String content) async {
    final ref = await _notes.add({
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return Note(id: ref.id, content: content);
  }

  Future<Note> update(String id, String content) async {
    await _notes.doc(id).update({
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return Note(id: id, content: content);
  }

  Future<void> delete(String id) async {
    await _notes.doc(id).delete();
  }
}

final notesService = NotesService();
