import 'package:flutter/material.dart';

import 'package:market_salla/provider/sallastate.dart';
import 'package:market_salla/shared/products.dart';
import 'package:market_salla/widgets/changeamount/add_delete.dart';
import 'package:provider/provider.dart';

class Customproduct extends StatefulWidget {
  const Customproduct({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  State<Customproduct> createState() => _CustomproductState();
}

class _CustomproductState extends State<Customproduct> {
  @override
  Widget build(BuildContext context) {
    final instance = Provider.of<Sallastate>(context);
    final sections = sectionsOfProducts; // Access the static list
    return Row( // Access the static list
      children: List.generate(sections[widget.selectedIndex].length, (index) {
        final product = sections[widget.selectedIndex][index];
        final amount = instance.salla.where((p) => p == product).length;

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddandDelete(
                product: product,
                amount: amount,
                onAdd: () {
                  instance.addtolist(product);
                },
                onRemove: () {
                  instance.removeindex(product);
                },
              ),
              SizedBox(height: 7),
              Text(
                product.name,
                style: TextStyle(
                  color: Color(0xff000000),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Image.asset("assets/img/icons/Vector.png", width: 20),
                  SizedBox(width: 5),
                  Text(
                    "${product.rate} (${product.votes})",
                    style: TextStyle(fontSize: 14, color: Color(0xff000000)),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                product.price,
                style: TextStyle(
                  color: Color(0xff000000),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
