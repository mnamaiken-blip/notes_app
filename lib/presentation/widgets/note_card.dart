import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/note_model.dart';
import '../../domain/models/note_type.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final noteColor = Color(note.colorValue);
    final formattedDate = DateFormat('MMM d, h:mm a').format(note.updatedAt);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: noteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Title & Pin/Lock Badges
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title.trim().isNotEmpty ? note.title : 'Untitled',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: note.title.trim().isNotEmpty
                            ? Colors.black87
                            : Colors.black38,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isLocked)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.lock, size: 16, color: Colors.black54),
                    ),
                  if (note.isPinned)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.push_pin, size: 16, color: Colors.black54),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Content Body
              if (note.isLocked)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, size: 14, color: Colors.black38),
                      SizedBox(width: 4),
                      Text(
                        'Locked Note',
                        style: TextStyle(fontSize: 13, color: Colors.black45),
                      ),
                    ],
                  ),
                )
              else if (note.type == NoteType.text)
                Text(
                  note.content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                )
              else
                _buildChecklistPreview(note),

              const SizedBox(height: 10),

              // Footer: Date & Reminder Icon (if set)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                  if (note.reminderTime != null)
                    const Icon(
                      Icons.alarm,
                      size: 13,
                      color: Colors.black54,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistPreview(Note note) {
    final items = note.checklistItems;
    final previewItems = items.take(4).toList();

    if (items.isEmpty) {
      return const Text(
        'Empty checklist',
        style: TextStyle(
          fontSize: 13,
          color: Colors.black38,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...previewItems.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.5),
            child: Row(
              children: [
                Icon(
                  item.isDone
                      ? Icons.check_box_outlined
                      : Icons.check_box_outline_blank,
                  size: 14,
                  color: item.isDone ? Colors.black38 : Colors.black54,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.text,
                    style: TextStyle(
                      fontSize: 12,
                      color: item.isDone ? Colors.black38 : Colors.black87,
                      decoration: item.isDone ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (items.length > 4)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+${items.length - 4} more items',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black45,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
