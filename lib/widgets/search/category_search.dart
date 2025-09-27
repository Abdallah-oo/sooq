import 'package:flutter/material.dart';

class CategorySearch extends StatelessWidget {
  const CategorySearch({
    super.key,
    required this.selectedIndex,
    required this.onCategorySelected,
  });
  final int? selectedIndex;
  final Function(int?, String?) onCategorySelected;

  final List<String> category = const [
    'cheese',
    'shrimp',
    'fish',
    'meat',
    'milk',
    'washing',
  ];
  ontapcategory(int index, String currentCategory) {
    if (selectedIndex == index) {
      onCategorySelected(null, null);
    } else {
      onCategorySelected(index, currentCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(category.length, (index) {
            final currentCategory = category[index];

            return GestureDetector(
              onTap: () {
                ontapcategory(index, currentCategory);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? Colors.green
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentCategory,
                  style: TextStyle(
                    color: selectedIndex == index
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }),

          const SizedBox(width: 10),
          if (selectedIndex != null)
            TextButton(
              onPressed: () {
                onCategorySelected(null, null);
              },
              child: const Text(
                'clear',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
