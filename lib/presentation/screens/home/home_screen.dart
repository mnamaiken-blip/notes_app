import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/note_model.dart';
import '../../../domain/models/note_type.dart';
import '../../providers/note_providers.dart';
import '../../widgets/note_card.dart';
import '../note_editor/note_editor_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(filteredNotesProvider);
    final isGrid = ref.watch(isGridViewProvider);
    final selectedColor = ref.watch(selectedColorFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ColorNote', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.view_agenda_outlined : Icons.grid_view),
            onPressed: () => ref.read(isGridViewProvider.notifier).state = !isGrid,
          ),
          PopupMenuButton<NoteSortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (opt) => ref.read(sortOptionProvider.notifier).state = opt,
            itemBuilder: (_) => const [
              PopupMenuItem(value: NoteSortOption.modifiedDate, child: Text('Sort by modified date')),
              PopupMenuItem(value: NoteSortOption.createdDate, child: Text('Sort by created date')),
              PopupMenuItem(value: NoteSortOption.title, child: Text('Sort by title')),
              PopupMenuItem(value: NoteSortOption.color, child: Text('Sort by color')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, size: 20),
                hintText: 'Search notes...',
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Color filter chip strip
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: selectedColor == null,
                  onSelected: (_) => ref.read(selectedColorFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: 8),
                ...NoteColors.palette.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedColorFilterProvider.notifier).state =
                            selectedColor == c.value ? null : c.value;
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == c.value ? Colors.black87 : Colors.black12,
                            width: selectedColor == c.value ? 2.5 : 1,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Notes List or Grid
          Expanded(
            child: notes.isEmpty
                ? const Center(
                    child: Text('No notes found', style: TextStyle(color: Colors.black45)),
                  )
                : isGrid
                    ? _buildGridView(context, notes, ref)
                    : _buildListView(context, notes, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGridView(BuildContext context, List<Note> notes, WidgetRef ref) {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
          ),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context, List<Note> notes, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final note = notes[index];
        return Slidable(
          key: ValueKey(note.id),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => _archiveNote(context, ref, note),
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                icon: Icons.archive,
                label: 'Archive',
              ),
              SlidableAction(
                onPressed: (_) => _deleteNote(context, ref, note),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Trash',
              ),
            ],
          ),
          child: NoteCard(
            note: note,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
            ),
          ),
        );
      },
    );
  }

  void _archiveNote(BuildContext context, WidgetRef ref, Note note) {
    final repo = ref.read(noteRepositoryProvider);
    repo.saveNote(note.copyWith(isArchived: true));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note archived'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => repo.saveNote(note.copyWith(isArchived: false)),
        ),
      ),
    );
  }

  void _deleteNote(BuildContext context, WidgetRef ref, Note note) {
    final repo = ref.read(noteRepositoryProvider);
    repo.saveNote(note.copyWith(isDeleted: true));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Moved to trash'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => repo.saveNote(note.copyWith(isDeleted: false)),
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Text Note'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NoteEditorScreen(initialType: NoteType.text),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.checklist_outlined),
                title: const Text('Checklist Note'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NoteEditorScreen(initialType: NoteType.checklist),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
