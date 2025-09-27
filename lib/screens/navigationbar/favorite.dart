import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:market_salla/provider/sallastate.dart';
import 'package:provider/provider.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  @override
  Widget build(BuildContext context) {
    final instance = Provider.of<Sallastate>(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0.0,
        leadingWidth: 0,
        leading: SizedBox.shrink(),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(
                Icons.favorite_border_outlined,
                color: const Color.fromARGB(255, 32, 32, 32),
              ),

              SizedBox(width: 10),
              Text(
                "favorite products",
                style: TextStyle(
                  color: const Color.fromARGB(255, 25, 26, 25),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: instance.favorite.isNotEmpty
                  ? ListView.builder(
                      itemCount: instance.favorite.length,
                      itemBuilder: (context, index) {
                        final product = instance.favorite[index];
                        final unfavorite = instance.favorite.contains(product);

                        return Card(
                          color: Colors.white,
                          margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Padding(
                            padding: EdgeInsetsGeometry.fromLTRB(10, 5, 10, 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  height: 90,
                                  width: width * 0.25,
                                  child: Image.asset(
                                    product.image,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AutoSizeText(
                                        product.name,
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                            255,
                                            31,
                                            30,
                                            30,
                                          ),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        minFontSize: 9,
                                      ),
                                      Text(
                                        product.price,
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
                                  onPressed: () {
                                    unfavorite
                                        ? instance.unfavorite(product)
                                        : instance.addfavouite(product);
                                  },
                                  icon: unfavorite
                                      ? Icon(
                                          Icons.favorite,
                                          color: Colors.green,
                                        )
                                      : Icon(
                                          Icons.favorite_border_outlined,
                                          color: const Color.fromARGB(
                                            255,
                                            35,
                                            36,
                                            35,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No favorite product added yet..",
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color.fromARGB(221, 95, 92, 92),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
