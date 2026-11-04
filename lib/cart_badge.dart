import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('badge build');
    final n = context.select<Cart, int>((c) => c.count);
    return IconButton(
      icon: Badge(label: Text('$n'), child: const Icon(Icons.shopping_cart)),
      onPressed: () => Navigator.of(context).pushNamed('/cart'),
    );
  }
}
