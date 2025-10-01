import 'package:flutter/material.dart';
import 'package:market_salla/provider/sallastate.dart';
import 'package:market_salla/shared/products.dart';
import 'package:market_salla/models/products_model.dart';
import 'package:market_salla/widgets/card.dart';
import 'package:market_salla/widgets/changeamount/addandremove_container.dart';
import 'package:market_salla/widgets/search/category_search.dart';
import 'package:market_salla/widgets/search/searchbar.dart';
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

  ontapcategory(int? index, String? category) {
    setState(() {
      selectedIndex = index;
    });
    if (category != null) {
      resultOfCategory(category);
    } else {
      setState(() {
        filtersearch.clear();
      });
    }
  }

  int? selectedIndex;
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: Column(
              children: [
                Searchbar(
                  searchController: _searchController,
                  onChanged: (value) => resultOfSearch(value),
                ),
                const SizedBox(height: 10),
                CategorySearch(
                  selectedIndex: selectedIndex,
                  onCategorySelected: (index, category) {
                    ontapcategory(index, category);
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child:
                      filtersearch.isEmpty && _searchController.text.isNotEmpty
                      ? const Center(child: Text('No products found.'))
                      : ListView.builder(
                          itemCount: filtersearch.length,
                          itemBuilder: (context, index) {
                            final product = filtersearch[index];
                            final amount = instance.salla.where((item) {
                              return item == product;
                            }).length;

                            return Sahredcard(
                              width: width * 0.18888888,
                              product: product,
                              fontsize: 11,
                              minfontsize: 7,
                              amount: amount,
                              trallingwidget: Customcontainer(
                                product: product,
                                amount: amount,
                              ),
                            );
                          },
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
