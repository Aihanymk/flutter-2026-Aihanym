import 'package:flutter/material.dart';

import 'features/users/users_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Users API',
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    home: const UsersScreen(),
  );
}
