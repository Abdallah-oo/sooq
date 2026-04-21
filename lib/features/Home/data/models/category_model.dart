class Category {
  final String image;
  final String name;
  const Category({required this.image, required this.name});

  static const List<Category> itemslist = [
    Category(image: 'assets/img/category/vegetable.png', name: 'vegetable'),

    Category(image: 'assets/img/category/fruits.png', name: 'fruits'),

    Category(image: 'assets/img/category/dairy.png', name: 'dairy'),

    Category(image: 'assets/img/category/protiens.png', name: 'protiens'),

    Category(image: 'assets/img/category/laundry.png', name: 'laundry'),
  ];
}
