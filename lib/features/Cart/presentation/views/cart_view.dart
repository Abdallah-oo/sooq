import 'package:flutter/material.dart';
import 'package:sooq/features/Cart/presentation/views/cart_view_body.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: const Scaffold(body: CartViewBody()),
    );
  }
}
