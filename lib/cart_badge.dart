import 'package:flutter/material.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key, required this.count, required this.total});

  final int count;
  final int total;

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Badge(
      label: Text('$count · $total ₸'),
      child: const Icon(Icons.shopping_cart),
    ),
    onPressed: () => Navigator.of(context).pushNamed('/cart'),
  );
}