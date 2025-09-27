import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:market_salla/models/products_model.dart';
import 'package:market_salla/provider/sallastate.dart';
import 'package:provider/provider.dart';

class Sahredcard extends StatelessWidget {
  const Sahredcard({
    super.key,
    required this.width,
    required this.product,
    required this.fontsize,
    required this.minfontsize,
    this.amount,
    this.isFavorite,
    this.trallingwidget,
  });
  final double width;
  final Products product;
  final double fontsize;
  final double minfontsize;
  final int ?amount;
  final bool? isFavorite;
  final Widget? trallingwidget;

  @override
  Widget build(BuildContext context) {
    final instance = Provider.of<Sallastate>(context);
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      child: Padding(
        padding: const EdgeInsetsGeometry.fromLTRB(10, 5, 10, 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
              height: 90,
              width: width,
              child: Image.asset(product.image, fit: BoxFit.contain),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    product.name,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 31, 30, 30),
                      fontSize: fontsize,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    minFontSize: minfontsize, // أصغر حجم خط يمكن أن يصل إليه
                  ),
                  Text(
                    product.price,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                isFavorite == null
                    ? const SizedBox.shrink()
                    : IconButton(
                        onPressed: () {
                          if (isFavorite!) {
                            instance.unfavorite(product);
                          } else {
                            instance.addfavouite(product);
                          }
                        },
                        icon: isFavorite!
                            ? const Icon(Icons.favorite, color: Colors.green)
                            : const Icon(Icons.favorite_border_outlined),
                      ),
                trallingwidget == null ? const SizedBox.shrink() : trallingwidget!,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
