import 'package:flutter/material.dart';
import 'package:sound_center/features/local_audio/domain/repositories/audio_repository.dart';
import 'package:sound_center/features/local_audio/presentation/pages/category/category_deatil.dart';
import 'package:sound_center/features/local_audio/presentation/widgets/category/category_template.dart';

class CategoryGridTemplate<T> extends StatefulWidget {
  const CategoryGridTemplate({
    super.key,
    required this.items,
    required this.category,
    required this.icon,
  });

  final List<T> items;
  final Category category;
  final IconData icon;

  @override
  State<CategoryGridTemplate<T>> createState() =>
      _CategoryGridTemplateState<T>();
}

class _CategoryGridTemplateState<T> extends State<CategoryGridTemplate<T>> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 120),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryDetail(
                  title: (item as dynamic).name,
                  category: widget.category,
                ),
              ),
            );
          },
          child: CategoryTemplate(
            key: ValueKey((item as dynamic).name),
            item: item,
            icon: widget.icon,
          ),
        );
      },
    );
  }
}
