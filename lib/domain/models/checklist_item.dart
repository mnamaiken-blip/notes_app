import 'dart:convert';

class ChecklistItem {
  final String id;
  final String text;
  final bool isDone;

  const ChecklistItem({
    required this.id,
    required this.text,
    this.isDone = false,
  });

  ChecklistItem copyWith({
    String? id,
    String? text,
    bool? isDone,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isDone': isDone,
    };
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] as String,
      text: map['text'] as String,
      isDone: map['isDone'] as bool? ?? false,
    );
  }

  static String encodeList(List<ChecklistItem> items) {
    return jsonEncode(items.map((e) => e.toMap()).toList());
  }

  static List<ChecklistItem> decodeList(String jsonStr) {
    if (jsonStr.trim().isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((e) => ChecklistItem.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
