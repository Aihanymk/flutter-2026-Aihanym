import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String name;
  final String email;
  final String group;
  final DateTime birthDate;

  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birthDate,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${birthDate.day.toString().padLeft(2, '0')}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.year}';

    final tiles = [
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text('Name'),
        subtitle: Text(name),
      ),
      ListTile(
        leading: const Icon(Icons.email),
        title: const Text('Email'),
        subtitle: Text(email),
      ),
      ListTile(
        leading: const Icon(Icons.group),
        title: const Text('Group'),
        subtitle: Text(group),
      ),
      ListTile(
        leading: const Icon(Icons.cake),
        title: const Text('Date of Birth'),
        subtitle: Text(formattedDate),
      ),
    ];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 600) {
              return GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 4,
                children: tiles,
              );
            } else {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: tiles,
              );
            }
          },
        ),
      ),
    );
  }
}