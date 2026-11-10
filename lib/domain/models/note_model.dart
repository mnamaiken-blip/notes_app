import 'checklist_item.dart';
import 'note_type.dart';

class Note {
  final String id;
  final String title;
  final String content; // Raw text or JSON encoded checklist
  final NoteType type;
  final int colorValue; // Hex ARGB integer
  final bool isPinned;
  final bool isArchived;
  final bool isLocked;
  final bool isDeleted;
  final DateTime? reminderTime;
  final String? repeatRule; // e.g., 'daily', 'weekly', null
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.colorValue,
    this.isPinned = false,
    this.isArchived = false,
    this.isLocked = false,
    this.isDeleted = false,
    this.reminderTime,
    this.repeatRule,
    required this.createdAt,
    required this.updatedAt,
  });

  List<ChecklistItem> get checklistItems {
    if (type != NoteType.checklist) return [];
    return ChecklistItem.decodeList(content);
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    NoteType? type,
    int? colorValue,
    bool? isPinned,
    bool? isArchived,
    bool? isLocked,
    bool? isDeleted,
    DateTime? reminderTime,
    String? repeatRule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isLocked: isLocked ?? this.isLocked,
      isDeleted: isDeleted ?? this.isDeleted,
      reminderTime: reminderTime ?? this.reminderTime,
      repeatRule: repeatRule ?? this.repeatRule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
