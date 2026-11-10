import '../models/note_model.dart';

abstract class NoteRepository {
  Stream<List<Note>> watchActiveNotes();
  Stream<List<Note>> watchArchivedNotes();
  Stream<List<Note>> watchTrashNotes();
  Future<Note?> getNoteById(String id);
  Future<void> saveNote(Note note);
  Future<void> deleteNotePermanently(String id);
  Future<void> cleanOldTrash(Duration threshold);
}
