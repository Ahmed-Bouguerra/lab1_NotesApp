import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDocs,
  orderBy,
  query,
  serverTimestamp,
  updateDoc,
} from "firebase/firestore";
import { db } from "../lib/firebase";

const notesRef = collection(db, "notes");

// Convert a Firestore document into the note object used by the app
const toNote = (snapshot) => {
  const data = snapshot.data();
  return {
    id: snapshot.id,
    content: data.content ?? "",
    createdAt: data.createdAt?.toDate?.().toISOString(),
    updatedAt: data.updatedAt?.toDate?.().toISOString(),
  };
}

export async function listNotes() {
  const snapshot = await getDocs(query(notesRef, orderBy("createdAt", "desc")));
  return snapshot.docs.map(toNote);
}

export async function createNote(content) {
  const ref = await addDoc(notesRef, {
    content,
    createdAt: serverTimestamp(),
  });
  return { id: ref.id, content, createdAt: new Date().toISOString() };
}

export async function updateNote(id, content) {
  await updateDoc(doc(db, "notes", id), {
    content,
    updatedAt: serverTimestamp(),
  });
  return { id, content, updatedAt: new Date().toISOString() };
}

export async function deleteNote(id) {
  await deleteDoc(doc(db, "notes", id));
}
