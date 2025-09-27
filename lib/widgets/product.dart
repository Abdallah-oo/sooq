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
    final sections = sectionsOfProducts;
    
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
              
              ),
              const SizedBox(height: 7),
              Text(
                product.name,
                style: const TextStyle(
                  color: Color(0xff000000),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Image.asset('assets/img/icons/Vector.png', width: 20),
                  const SizedBox(width: 5),
                  Text(
                    '${product.rate} (${product.votes})',
                    style: const TextStyle(fontSize: 14, color: Color(0xff000000)),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                product.price,
                style: const TextStyle(
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
