import 'package:flutter/material.dart';

import 'cart_badge.dart';
import 'main.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({
    super.key,
    required this.cart,
    required this.onAdd,
    required this.total,
  });

  final List<Book> cart;
  final void Function(Book) onAdd;
  final int total;

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: [CartBadge(count: cart.length, total: total)],
      ),
      body: ListView(
        children: [
          for (final b in books)
            Builder(builder: (_) {
              debugPrint('row ${b.title}');
              return ListTile(
                title: Text(b.title),
                subtitle: Text(b.author),
                trailing: cart.contains(b)
                    ? const Text('Added',
                    style: TextStyle(fontWeight: FontWeight.bold))
                    : OutlinedButton(
                  onPressed: () => onAdd(b),
                  child: const Text('Add'),
                ),
              );
            }),
        ],
      ),
    );
  }
}