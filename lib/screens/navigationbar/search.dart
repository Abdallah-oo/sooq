import 'package:flutter/material.dart';
import 'package:market_salla/provider/sallastate.dart';
import 'package:market_salla/shared/products.dart';
import 'package:market_salla/models/products_model.dart';
import 'package:market_salla/widgets/changeamount/addandremove_container.dart';
import 'package:provider/provider.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _searchController = TextEditingController();
  List<Products> filtersearch = [];
  final List<Products> allProducts = sectionsOfProducts
      .expand((section) => section)
      .toList();

  resultOfSearch(String input) {
    filtersearch.clear();

    //with expand method تحويل كل الأقسام إلى قائمة واحدة مسطحة من المنتجات

    String value = input.toLowerCase();

    if (value.isEmpty) {
      setState(() {});
    } else {
      filtersearch = allProducts.where((item) {
        final name = item.name.toLowerCase();
        return name.contains(value);
      }).toList();

      setState(() {});
    }
  }

  resultOfCategory(String input) {
    filtersearch.clear();
    filtersearch = allProducts.where((item) {
      final name = item.name.toLowerCase();
      return name.contains(input);
    }).toList();
    setState(() {});
  }

  ontapCategory(int index, String currentCategory) {
    if (selectedIndex == index) {
      setState(() {
        selectedIndex = null;
        filtersearch.clear();
      });
    } else {
      setState(() {
        selectedIndex = index;
      });
      resultOfCategory(currentCategory);
    }
  }

  List<String> category = [
    "cheese",
    "shrimp",
    "fish",
    "meat",
    "milk",
    "washing",
  ];
  int? selectedIndex;
  // bool isSelected = false;

  @override
  void initState() {
    _searchController.addListener(() {
      resultOfSearch(_searchController.text);
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instance = Provider.of<Sallastate>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (v) {
                    resultOfSearch(v);
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter Product Name',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 20,
                              color: Color.fromARGB(255, 180, 14, 14),
                            ),
                            onPressed: () => _searchController.clear(),
                          )
                        : SizedBox.shrink(),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 245, 244, 244),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 192, 191, 191),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...List.generate(category.length, (index) {
                        final currentCategory = category[index];

                        return GestureDetector(
                          onTap: () {
                            ontapCategory(index, currentCategory);
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

                      SizedBox(width: 10),
                      if(selectedIndex != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            filtersearch.clear();
                            selectedIndex = null;
                          });
                        },
                        child: Text(
                          "clear",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child:
                      filtersearch.isEmpty && _searchController.text.isNotEmpty
                      ? const Center(child: Text("No products found."))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: filtersearch.length,
                            itemBuilder: (context, index) {
                              final product = filtersearch[index];
                              final amount = instance.salla.where((item) {
                                return item == product;
                              }).length;

                              return Card(
                                color: Colors.white,
                                margin: const EdgeInsets.fromLTRB(
                                  10,
                                  10,
                                  10,
                                  0,
                                ),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        height: 90,
                                        width: 90,
                                        child: Image.asset(
                                          product.image,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              product.price,
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      Customcontainer(
                                        product: product,
                                        amount: amount,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
