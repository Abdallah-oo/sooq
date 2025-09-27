import 'package:flutter/material.dart';
import 'package:market_salla/models/products_model.dart';
import 'package:market_salla/provider/sallastate.dart';
import 'package:market_salla/widgets/card.dart';
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Sahredcard(
      width: width * 0.25,
      product: widget.product,
      fontsize: 13,
      minfontsize: 9,
      amount: widget.amount,
      isFavorite: isFavorite,
      trallingwidget:customtrailing(),
    );
  }

  Widget customtrailing() {
    final instance = Provider.of<Sallastate>(context);
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color.fromARGB(255, 245, 244, 244),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              instance.removeindex(widget.product);
            },
            child: widget.amount > 1
                ? const Icon(Icons.remove)
                : const Icon(Icons.delete_outline_rounded),
          ),
          const SizedBox(width: 3),
          Text(widget.amount.toString()),
          const SizedBox(width: 3),
          GestureDetector(
            onTap: () {
              instance.addtolist(widget.product);
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
