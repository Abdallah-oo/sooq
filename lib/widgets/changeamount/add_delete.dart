import 'package:flutter/material.dart';
import 'package:market_salla/models/products_model.dart';
import 'package:market_salla/widgets/changeamount/addandremove_container.dart';

class AddandDelete extends StatelessWidget {
  const AddandDelete({
    super.key,
    required this.product,
    required this.amount,
  
  });
  final int amount;
  final Products product;


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
     
    final width = size.width;
    return Stack(
      children: [
        Container(
          width: width*0.344,
          height: 130,
          decoration: BoxDecoration(
            color: const Color(0xffF6F6F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(product.image, fit: BoxFit.contain),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: Customcontainer(product: product, amount: amount),
        ),
      ],
    );
  }
}
