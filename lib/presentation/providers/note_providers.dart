import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/app_database.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/models/note_model.dart';
import '../../domain/repositories/note_repository.dart';

// Single database instance
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Repository provider
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return NoteRepositoryImpl(db);
});

// Stream of active notes directly from Drift SQLite
final rawActiveNotesStreamProvider = StreamProvider<List<Note>>((ref) {
  final repository = ref.watch(noteRepositoryProvider);
  return repository.watchActiveNotes();
});

// View mode state: true = Grid, false = List
final isGridViewProvider = StateProvider<bool>((ref) => true);

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filter by color: null means show all colors
final selectedColorFilterProvider = StateProvider<int?>((ref) => null);

// Sorting modes
enum NoteSortOption {
  modifiedDate,
  createdDate,
  title,
  color,
}

final sortOptionProvider = StateProvider<NoteSortOption>((ref) => NoteSortOption.modifiedDate);

// Computed provider combining raw notes + search + filter + sort
final filteredNotesProvider = Provider<List<Note>>((ref) {
  final notesAsync = ref.watch(rawActiveNotesStreamProvider);

  return notesAsync.maybeWhen(
    data: (notes) {
      final query = ref.watch(searchQueryProvider).trim().toLowerCase();
      final colorFilter = ref.watch(selectedColorFilterProvider);
      final sortOption = ref.watch(sortOptionProvider);

      var list = notes;

      // 1. Color filter
      if (colorFilter != null) {
        list = list.where((note) => note.colorValue == colorFilter).toList();
      }

      // 2. Search query filter
      if (query.isNotEmpty) {
        list = list.where((note) {
          final titleMatch = note.title.toLowerCase().contains(query);
          final contentMatch = note.content.toLowerCase().contains(query);
          return titleMatch || contentMatch;
        }).toList();
      }

      // 3. Sort (pinned notes always stay on top)
      list.sort((a, b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }

        switch (sortOption) {
          case NoteSortOption.modifiedDate:
            return b.updatedAt.compareTo(a.updatedAt);
          case NoteSortOption.createdDate:
            return b.createdAt.compareTo(a.createdAt);
          case NoteSortOption.title:
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
          case NoteSortOption.color:
            return a.colorValue.compareTo(b.colorValue);
        }
      });

      return list;
    },
    orElse: () => [],
  );
});
