import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

const categoryAvatarPalette = [
  AppColors.accentPrimary,
  AppColors.accentPink,
  AppColors.accentPrimaryLight,
  Color(0xFF4DB6AC),
  Color(0xFFFFB74D),
];

/// Deterministic color for a category id — same id always renders the same
/// color, so a user's categories stay visually consistent without any
/// per-category configuration (categories are free-text, not a fixed set
/// with known brand icons — see design spec's "Category avatar rule").
Color categoryAvatarColor(String categoryId) {
  final hash = categoryId.codeUnits.fold<int>(0, (a, c) => a + c);
  return categoryAvatarPalette[hash % categoryAvatarPalette.length];
}

class CategoryAvatar extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  final double size;
  const CategoryAvatar({super.key, required this.categoryId, required this.categoryName, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final letter = categoryName.isEmpty ? '?' : categoryName[0].toUpperCase();
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: categoryAvatarColor(categoryId),
      child: Text(
        letter,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: size * 0.4),
      ),
    );
  }
}
