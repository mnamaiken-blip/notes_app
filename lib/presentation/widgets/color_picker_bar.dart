import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ColorPickerBar extends StatelessWidget {
  final int selectedColorValue;
  final ValueChanged<int> onColorSelected;

  const ColorPickerBar({
    super.key,
    required this.selectedColorValue,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: NoteColors.palette.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final color = NoteColors.palette[index];
          final isSelected = color.value == selectedColorValue;

          return GestureDetector(
            onTap: () => onColorSelected(color.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black87 : Colors.black12,
                  width: isSelected ? 2.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 20, color: Colors.black87)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
