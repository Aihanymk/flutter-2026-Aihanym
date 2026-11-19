import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'core/api/api_exception.dart';
import 'features/users/user.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';

import 'dart:io';

import 'package:http/io_client.dart';

const _smoke = bool.fromEnvironment('SMOKE');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = UserRepository(
    ApiClient(
      IOClient(HttpClient()..connectionTimeout = const Duration(seconds: 10)),
    ),
  );

  if (_smoke) await _smokeTest(repo);

  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final model = UsersModel(repo);
        unawaited(model.load());
        return model;
      },
      child: const App(),
    ),
  );
}

Future<void> _smokeTest(UserRepository repo) async {
  final all = await repo.getAll();
  debugPrint('getAll: ${all.length} -> ${all.map((u) => u.name).join(', ')}');
  try {
    await repo.getById(999);
  } on NotFoundException {
    debugPrint('not found');
  }
  final created = await repo.create(
    const User.draft(name: 'Test', username: 'test', email: 'test@example.com'),
  );
  debugPrint('created id: ${created.id}');
}
