import 'package:flutter/material.dart';

/// Returns the typed text with Navigator.pop, or null if the user cancels.
class NoteInputDialog extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditing;

  const NoteInputDialog({
    Key? key,
    required this.controller,
    required this.isEditing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Note' : 'Add New Note'),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Enter your note here...',
          border: OutlineInputBorder(),
        ),
        maxLines: 5,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: Text('Save'),
          style: TextButton.styleFrom(foregroundColor: Colors.blue),
        ),
      ],
    );
  }
}
