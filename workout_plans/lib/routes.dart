import 'package:flutter/material.dart';

import 'models/session.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';
import 'screens/not_found_screen.dart';

abstract final class Routes {
  static const String shell = '/';
  static const String detail = '/detail';
  static const String form = '/form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return switch ((settings.name, settings.arguments)) {
      (Routes.detail, final DetailArgs args) => MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => DetailScreen(args: args),
      ),
      (Routes.form, final FormArgs args) => MaterialPageRoute<Session>(
        settings: settings,
        builder: (context) => FormScreen(args: args),
      ),
      _ => null,
    };
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => NotFoundScreen(name: settings.name),
    );
  }
}

class DetailArgs {
  const DetailArgs({
    required this.item,
    required this.profileName,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final Session item;
  final String profileName;
  final ValueChanged<Session> onChanged;
  final ValueChanged<Session> onDelete;
  final VoidCallback onOpenProfile;
}

class FormArgs {
  const FormArgs({this.item});

  final Session? item;
}
