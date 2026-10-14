import 'package:flutter/material.dart';

import 'detail_screen.dart';
import 'edit_screen.dart';
import 'routes.dart';
import 'students.dart';
import 'students_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    ),
    initialRoute: Routes.students,
    routes: {Routes.students: (_) => const StudentsScreen()},
    onGenerateRoute: (settings) {
      switch (settings.name) {
        case Routes.student:
          final s = settings.arguments as Student;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => DetailScreen(student: s),
          );
        case Routes.edit:
          final s = settings.arguments as Student;
          return MaterialPageRoute<String>(
            settings: settings,
            builder: (_) => EditScreen(student: s),
          );
      }
      return null;
    },
  );
}
