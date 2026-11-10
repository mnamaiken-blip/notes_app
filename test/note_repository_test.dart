import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:colornote_clone/data/datasources/local/app_database.dart';
import 'package:colornote_clone/data/repositories/note_repository_impl.dart';
import 'package:colornote_clone/domain/models/note_model.dart';
import 'package:colornote_clone/domain/models/note_type.dart';

void main() {
  late AppDatabase db;
  late NoteRepositoryImpl repository;

  setUp(() {
    // In-memory sqlite instance for rapid isolated testing
    db = AppDatabase(NativeDatabase.memory());
    repository = NoteRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Save and retrieve active notes, verifying pin priority', () async {
    final now = DateTime.now();
    final note1 = Note(
      id: '1',
      title: 'Standard Note',
      content: 'Hello world',
      type: NoteType.text,
      colorValue: 0xFFFFF9C4,
      isPinned: false,
      createdAt: now,
      updatedAt: now,
    );

    final note2 = Note(
      id: '2',
      title: 'Pinned Note',
      content: 'Important info',
      type: NoteType.text,
      colorValue: 0xFFFFCDD2,
      isPinned: true,
      createdAt: now.add(const Duration(seconds: 1)),
      updatedAt: now.add(const Duration(seconds: 1)),
    );

    await repository.saveNote(note1);
    await repository.saveNote(note2);

    final activeNotes = await repository.watchActiveNotes().first;
    expect(activeNotes.length, 2);
    // Pinned note must be first
    expect(activeNotes.first.id, '2');
    expect(activeNotes.first.isPinned, isTrue);
  });
}
