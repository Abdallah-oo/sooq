import 'package:flutter/material.dart';
import 'package:market_salla/provider/sallastate.dart';
import 'package:market_salla/shared/products.dart';
import 'package:market_salla/widgets/changeamount/addandremove_container.dart';
import 'package:provider/provider.dart';

class Seeall extends StatelessWidget {
  const Seeall({super.key, required this.reseveindex});

  final int reseveindex;

  @override
  Widget build(BuildContext context) {
    final instance = Provider.of<Sallastate>(context);
    return Dialog(
      shadowColor: Colors.green,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      child: FractionallySizedBox(
        heightFactor: 0.8,
        child: ListView.builder(
          itemCount: sectionsOfProducts[reseveindex].length,
          itemBuilder: (context, index) {
            final product = sectionsOfProducts[reseveindex][index];
            final amount = instance.salla
                .where((item) => item == product)
                .length;
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 90,
                      width: 90,
                      child: Image.asset(product.image, fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                    Customcontainer(product: product, amount: amount),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
