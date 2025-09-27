import 'package:flutter/material.dart';
import 'package:market_salla/provider/sallastate.dart';
import 'package:market_salla/widgets/card.dart';
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
        leading: const SizedBox.shrink(),
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(
                Icons.favorite_border_outlined,
                color: Color.fromARGB(255, 32, 32, 32),
              ),

              SizedBox(width: 10),
              Text(
                'favorite products',
                style: TextStyle(
                  color: Color.fromARGB(255, 25, 26, 25),
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

                        return Sahredcard(
                          width: width * 0.25,
                          product: product,
                          fontsize: 13,
                          minfontsize: 9,
                          isFavorite: true,
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'No favorite product added yet..',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(221, 95, 92, 92),
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
