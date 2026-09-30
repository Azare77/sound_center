import 'package:material_ui/material_ui.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';

class CategoryBar extends StatefulWidget {
  const CategoryBar({super.key});

  @override
  State<CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<CategoryBar> {
  Category selectedCategory = Category.allSongs;

  final Map<Category, GlobalKey> categoryKeys = {
    for (final category in Category.values) category: GlobalKey(),
  };

  void _selectCategory(Category category) {
    setState(() {
      selectedCategory = category;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = categoryKeys[category]?.currentContext;

      if (context != null) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 5,
          children: Category.values.map((category) {
            final isSelected = selectedCategory == category;

            return TextButton(
              key: categoryKeys[category],
              style: TextButton.styleFrom(
                backgroundColor: isSelected
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _selectCategory(category),
              child: Text(
                category.title(context),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
