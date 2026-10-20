import React, { useCallback, useEffect, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
} from "react-native";
import NoteItem from "../components/NoteItem";
import NoteInput from "../components/NoteInput";
import { errorMessage } from "../lib/errors";
import {
  listNotes,
  createNote,
  updateNote,
  deleteNote as deleteNoteFromDb,
} from "../services/notes";

export default function NotesScreen() {
  const [notes, setNotes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [modalVisible, setModalVisible] = useState(false);
  const [noteText, setNoteText] = useState("");
  const [editingNote, setEditingNote] = useState(null);

  // Load notes from Firestore
  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setNotes(await listNotes());
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  // Function to add or update a note
  const saveNote = async () => {
    const text = noteText.trim();
    if (text === "") return;

    try {
      if (editingNote) {
        const updated = await updateNote(editingNote.id, text);
        setNotes((current) =>
          current.map((n) => (n.id === updated.id ? updated : n))
        );
      } else {
        const created = await createNote(text);
        setNotes((current) => [created, ...current]);
      }
      closeModal();
    } catch (e) {
      // The modal stays open so the text is not lost
      Alert.alert("Could not save the note", errorMessage(e));
    }
  };

  // Function to delete a note (with confirmation)
  const deleteNote = (id) => {
    const note = notes.find((n) => n.id === id);
    Alert.alert("Delete note", `Delete "${note ? note.content : ""}"?`, [
      { text: "Cancel", style: "cancel" },
      {
        text: "Delete",
        style: "destructive",
        onPress: async () => {
          try {
            await deleteNoteFromDb(id);
            setNotes((current) => current.filter((n) => n.id !== id));
          } catch (e) {
            Alert.alert("Could not delete the note", errorMessage(e));
          }
        },
      },
    ]);
  };

  // Function to open edit mode
  const editNote = (note) => {
    setEditingNote(note);
    setNoteText(note.content);
    setModalVisible(true);
  };

  // Function to close the modal
  const closeModal = () => {
    setModalVisible(false);
    setNoteText("");
    setEditingNote(null);
  };

  const renderBody = () => {
    if (loading && notes.length === 0) {
      return (
        <View style={styles.emptyContainer}>
          <ActivityIndicator size="large" color="#3498db" />
        </View>
      );
    }

    if (error) {
      return (
        <View style={styles.emptyContainer}>
          <Text style={styles.errorText}>{error}</Text>
          <TouchableOpacity onPress={load}>
            <Text style={styles.retryText}>Retry</Text>
          </TouchableOpacity>
        </View>
      );
    }

    return (
      <FlatList
        data={notes}
        renderItem={({ item }) => (
          <NoteItem note={item} onEdit={editNote} onDelete={deleteNote} />
        )}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.notesList}
        refreshing={loading}
        onRefresh={load}
        ListEmptyComponent={
          <Text style={styles.emptyText}>No notes yet. Create one!</Text>
        }
      />
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>My Notes</Text>
        <TouchableOpacity
          style={styles.addButton}
          onPress={() => setModalVisible(true)}
        >
          <Text style={styles.addButtonText}>+</Text>
        </TouchableOpacity>
      </View>

      {renderBody()}

      <NoteInput
        visible={modalVisible}
        onClose={closeModal}
        onSave={saveNote}
        noteText={noteText}
        setNoteText={setNoteText}
        isEditing={!!editingNote}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#f5f5f5",
  },
  header: {
    height: 100,
    backgroundColor: "#3498db",
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-end",
    paddingBottom: 15,
    paddingHorizontal: 20,
  },
  headerTitle: {
    color: "white",
    fontSize: 24,
    fontWeight: "bold",
  },
  addButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: "white",
    justifyContent: "center",
    alignItems: "center",
  },
  addButtonText: {
    fontSize: 24,
    color: "#3498db",
    fontWeight: "bold",
    marginTop: -2,
  },
  notesList: {
    padding: 15,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    padding: 24,
  },
  emptyText: {
    fontSize: 18,
    color: "#7f8c8d",
    textAlign: "center",
    marginTop: 40,
  },
  errorText: {
    fontSize: 16,
    color: "#c0392b",
    textAlign: "center",
    marginBottom: 12,
  },
  retryText: {
    fontSize: 16,
    color: "#3498db",
    fontWeight: "bold",
  },
});
