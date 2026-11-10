import 'package:drift/drift.dart';
import '../../domain/models/note_model.dart';
import '../../domain/models/note_type.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/local/app_database.dart';

class NoteRepositoryImpl implements NoteRepository {
  final AppDatabase db;

  NoteRepositoryImpl(this.db);

  Note _toDomain(NotesTableData row) {
    return Note(
      id: row.id,
      title: row.title,
      content: row.content,
      type: NoteType.values[row.type],
      colorValue: row.colorValue,
      isPinned: row.isPinned,
      isArchived: row.isArchived,
      isLocked: row.isLocked,
      isDeleted: row.isDeleted,
      reminderTime: row.reminderTime,
      repeatRule: row.repeatRule,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  NotesTableCompanion _toCompanion(Note note) {
    return NotesTableCompanion(
      id: Value(note.id),
      title: Value(note.title),
      content: Value(note.content),
      type: Value(note.type.index),
      colorValue: Value(note.colorValue),
      isPinned: Value(note.isPinned),
      isArchived: Value(note.isArchived),
      isLocked: Value(note.isLocked),
      isDeleted: Value(note.isDeleted),
      reminderTime: Value(note.reminderTime),
      repeatRule: Value(note.repeatRule),
      createdAt: Value(note.createdAt),
      updatedAt: Value(note.updatedAt),
    );
  }

  @override
  Stream<List<Note>> watchActiveNotes() {
    final query = db.select(db.notesTable)
      ..where((tbl) => tbl.isDeleted.equals(false) & tbl.isArchived.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.isPinned, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<Note>> watchArchivedNotes() {
    final query = db.select(db.notesTable)
      ..where((tbl) => tbl.isArchived.equals(true) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<Note>> watchTrashNotes() {
    final query = db.select(db.notesTable)
      ..where((tbl) => tbl.isDeleted.equals(true))
      ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final query = db.select(db.notesTable)..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<void> saveNote(Note note) async {
    await db.into(db.notesTable).insertOnConflictUpdate(_toCompanion(note));
  }

  @override
  Future<void> deleteNotePermanently(String id) async {
    await (db.delete(db.notesTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<void> cleanOldTrash(Duration threshold) async {
    final cutoff = DateTime.now().subtract(threshold);
    await (db.delete(db.notesTable)
          ..where((tbl) => tbl.isDeleted.equals(true) & tbl.updatedAt.isSmallerThanValue(cutoff)))
        .go();
  }
}
