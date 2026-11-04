import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('All books will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<Cart>().clear();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cart'),
      actions: [
        TextButton(
          onPressed: () => _confirmClear(context),
          child: const Text('Clear cart'),
        ),
      ],
    ),
    body: Consumer<Cart>(
      child: const Row(
        children: [Icon(Icons.payments), SizedBox(width: 8), Text('Total:')],
      ),
      builder: (context, cart, child) => Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                for (final b in cart.items)
                  ListTile(
                    title: Text(b.title),
                    subtitle: Text('${b.price} ₸   ×${cart.qtyOf(b)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => cart.increment(b),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => cart.remove(b),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                child!,
                const Spacer(),
                Text(
                  '${cart.total} ₸',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
