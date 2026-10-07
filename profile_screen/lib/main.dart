import 'package:flutter/material.dart';

import 'data.dart';
import 'info_row.dart';
import 'profile_header.dart';

void main() => runApp(const ProfileApp());

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('My profile')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const ProfileHeader(name: myName, university: myUniversity),
              for (final fact in facts)
                InfoRow(label: fact.label, value: fact.value),
            ],
          ),
        ),
      ),
    );
  }
}
