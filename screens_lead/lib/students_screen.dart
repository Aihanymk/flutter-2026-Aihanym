import 'package:flutter/material.dart';

import 'routes.dart';
import 'students.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Students')),
    body: ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, i) {
        final s = students[i];
        return ListTile(
          leading: CircleAvatar(child: Text(s.name[0])),
          title: Text(s.name),
          subtitle: Text(s.group),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              Navigator.of(context).pushNamed(Routes.student, arguments: s),
        );
      },
    ),
  );
}
