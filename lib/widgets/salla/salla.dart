import 'package:flutter/material.dart';

class Salla extends StatelessWidget {
  const Salla({super.key, required this.basket});
  final List basket;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return basket.isEmpty
        ? const SizedBox.shrink()
        : Center(
          child: Container(
              height: 70,
              width: width*0.8,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: const Color(0xff0CA201),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      reverse: true,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(basket.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Container(
                              width: 36,
                              height: 36,
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xffffffff),
                              ),
                              child: Image.asset(
                                basket[index].image,
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Container(height: 31, width: 1, color: const Color(0xffffffff)),
                      const SizedBox(width: 3),
                      const Text(
                        'ViewBasket',
                        style: TextStyle(
                          color: Color(0xffffffff),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset(
                            'assets/img/icons/basket.png',
                            color: const Color(0xffffffff),
                            height: 22,
                            width: 22,
                          ),
                          Positioned(
                            top: -10,
                            right: -3,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xffffffff),
                              ),
                              child: Text(
                                '${basket.length}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
        );
  }
}
