import 'package:flutter/material.dart';
import 'package:market_salla/models/products_model.dart';
import 'package:market_salla/provider/sallastate.dart';
import 'package:provider/provider.dart';

class Sallacard extends StatefulWidget {
  const Sallacard({
    super.key,
    required this.product,
    required this.amount,
    required this.index,
  });
  final Products product;
  final int amount;
  final int index;

  @override
  State<Sallacard> createState() => _SallacardState();
}

class _SallacardState extends State<Sallacard> {
  @override
  Widget build(BuildContext context) {
    final instance = Provider.of<Sallastate>(context);
    final isFavorite = instance.favorite.contains(widget.product);

    return Card(
      color: Colors.white,
      margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      child: Padding(
        padding: EdgeInsetsGeometry.fromLTRB(10, 5, 10, 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
              height: 120,
              width: 150,
              child: Image.asset(widget.product.image, fit: BoxFit.contain),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 31, 30, 30),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.product.price,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Spacer(),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    if (isFavorite) {
                      instance.unfavorite(widget.product);
                    } else {
                      instance.addfavouite(widget.product);
                    }
                  },
                  icon: isFavorite
                      ? const Icon(Icons.favorite, color: Colors.green)
                      : const Icon(Icons.favorite_border_outlined),
                ),
                Container(
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: Color.fromARGB(255, 245, 244, 244),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          instance.removeindex(widget.product);
                        },
                        child: widget.amount > 1
                            ? Icon(Icons.remove)
                            : Icon(Icons.delete_outline_rounded),
                      ),
                      SizedBox(width: 3),
                      Text(widget.amount.toString()),
                      SizedBox(width: 3),
                      GestureDetector(
                        onTap: () {
                          instance.addtolist(widget.product);
                        },
                        child: Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
