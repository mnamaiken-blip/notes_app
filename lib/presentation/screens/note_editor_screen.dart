import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/note_model.dart';
import '../../../domain/models/note_type.dart';
import '../../providers/note_providers.dart';
import '../../widgets/color_picker_bar.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note;
  final NoteType initialType;

  const NoteEditorScreen({
    super.key,
    this.note,
    this.initialType = NoteType.text,
  });

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late int _selectedColor;
  late bool _isPinned;
  late String _noteId;
  late DateTime _createdAt;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    _noteId = n?.id ?? const Uuid().v4();
    _titleController = TextEditingController(text: n?.title ?? '');
    _contentController = TextEditingController(text: n?.content ?? '');
    _selectedColor = n?.colorValue ?? NoteColors.defaultColor.value;
    _isPinned = n?.isPinned ?? false;
    _createdAt = n?.createdAt ?? DateTime.now();

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _saveNote(); // Flush save on exit
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), _saveNote);
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Avoid saving ghost empty notes
    if (title.isEmpty && content.isEmpty && widget.note == null) {
      return;
    }

    final note = Note(
      id: _noteId,
      title: _titleController.text,
      content: _contentController.text,
      type: widget.note?.type ?? widget.initialType,
      colorValue: _selectedColor,
      isPinned: _isPinned,
      isArchived: widget.note?.isArchived ?? false,
      isLocked: widget.note?.isLocked ?? false,
      isDeleted: widget.note?.isDeleted ?? false,
      reminderTime: widget.note?.reminderTime,
      repeatRule: widget.note?.repeatRule,
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
    );

    await ref.read(noteRepositoryProvider).saveNote(note);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) => _saveNote(),
      child: Scaffold(
        backgroundColor: Color(_selectedColor),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: Colors.black87,
              ),
              onPressed: () {
                setState(() => _isPinned = !_isPinned);
                _saveNote();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black38),
                  border: InputBorder.none,
                ),
              ),
            ),
            const Divider(height: 1, thickness: 0.5, color: Colors.black12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
                  decoration: const InputDecoration(
                    hintText: 'Start typing note...',
                    hintStyle: TextStyle(fontSize: 16, color: Colors.black38),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            ColorPickerBar(
              selectedColorValue: _selectedColor,
              onColorSelected: (val) {
                setState(() => _selectedColor = val);
                _saveNote();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
