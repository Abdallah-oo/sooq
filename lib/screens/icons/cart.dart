import 'package:flutter/material.dart';
import 'package:market_salla/provider/sallastate.dart';
import 'package:market_salla/widgets/salla/sallacard.dart';
import 'package:provider/provider.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    final instance = Provider.of<Sallastate>(context);
    final uniqueSalla = instance.salla.toSet().toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0.0,
        leadingWidth: 0,
        leading: SizedBox.shrink(),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Image.asset(
                "assets/img/icons/basket.png",
                color: const Color.fromARGB(255, 19, 85, 21),

                width: 25,
              ),
              SizedBox(width: 10),
              Text("Cart"),
              Spacer(),
              Text(
                "pay: \$ ${instance.totalpayment()} ",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            instance.salla.isNotEmpty
                ? Column(
                    children: [
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: TextButton(
                            onPressed: () {
                              instance.clearcart();
                            },
                            child: Text(
                              "Clear Cart",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            SizedBox(height: 10),
            Expanded(
              child: uniqueSalla.isNotEmpty
                  ? ListView.builder(
                      itemCount: uniqueSalla.length,
                      itemBuilder: (context, index) {
                        final product = uniqueSalla[index];
                        final amount = instance.salla
                            .where((item) => item == product)
                            .length;
                        return Sallacard(
                          product: product,
                          amount: amount,
                          index: index,
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No Items In Cart Yet..",
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color.fromARGB(221, 95, 92, 92),
                        ),
                      ),
                    ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(5),
              color: const Color.fromARGB(255, 15, 90, 15),
              width: 100,
              child: Center(
                child: Text(
                  "Payment",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 248, 247, 247),
                    fontSize: 20,
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
