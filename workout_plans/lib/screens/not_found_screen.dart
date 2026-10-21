import 'package:flutter/material.dart';

import '../widgets/empty_state.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: EmptyState(
        icon: Icons.explore_off,
        message: 'Not found: ${name ?? 'unknown route'}',
      ),
    );
  }
}
