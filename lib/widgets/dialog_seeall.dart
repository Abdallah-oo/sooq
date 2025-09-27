import 'package:flutter/material.dart';
import 'package:market_salla/provider/sallastate.dart';
import 'package:market_salla/shared/products.dart';
import 'package:market_salla/widgets/card.dart';
import 'package:market_salla/widgets/changeamount/addandremove_container.dart';
import 'package:provider/provider.dart';

class Seeall extends StatelessWidget {
  const Seeall({super.key, required this.reseveindex});

  final int reseveindex;

  @override
  Widget build(BuildContext context) {
    final instance = Provider.of<Sallastate>(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;
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
            return Sahredcard(
              width: width * 0.18888888,
              product: product,
              fontsize: 11,
              minfontsize: 7,
              amount: amount,
              trallingwidget: Customcontainer(product: product, amount: amount),
            );
          },
        ),
      ),
    );
  }
}
