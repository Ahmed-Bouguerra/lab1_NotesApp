import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  const Note({required this.id, required this.content});

  factory Note.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) => Note(
        id: doc.id,
        content: (doc.data()?['content'] as String?) ?? '',
      );

  final String id;
  final String content;
}
