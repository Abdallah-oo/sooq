import 'package:flutter/material.dart';
import 'package:market_salla/models/products_model.dart';
import 'package:market_salla/provider/sallastate.dart';
import 'package:provider/provider.dart';

class Customcontainer extends StatefulWidget {
  const Customcontainer({
    super.key,
    required this.product,
    required this.amount,
  });
  final Products product;
  final int amount;

  @override
  State<Customcontainer> createState() => _CustomcontainerState();
}

class _CustomcontainerState extends State<Customcontainer> {
  @override
  Widget build(BuildContext context) {
    final instance = Provider.of<Sallastate>(context);
    return widget.amount > 0
        ? Container(
            padding: EdgeInsets.all(7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Color.fromARGB(255, 231, 230, 230),
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
          )
        : GestureDetector(
            onTap: () {
              instance.addtolist(widget.product);
            },
            child: Container(
              height: 38,
              width: 38,
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 231, 230, 230),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: Color(0xff000000)),
            ),
          );
  }
}
