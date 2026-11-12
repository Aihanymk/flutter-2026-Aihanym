import 'package:flutter/material.dart';

import 'countdown_screen.dart';
import 'students_future_screen.dart';
import 'students_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Students async', home: StudentsHome());
  }
}

class StudentsHome extends StatelessWidget {
  const StudentsHome({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Data Arrives Later')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _open(context, const StudentsScreen()),
              child: const Text('By hand'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _open(context, const StudentsFutureScreen()),
              child: const Text('FutureBuilder'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _open(context, const CountdownScreen()),
              child: const Text('Countdown'),
            ),
          ],
        ),
      ),
    );
  }
}
