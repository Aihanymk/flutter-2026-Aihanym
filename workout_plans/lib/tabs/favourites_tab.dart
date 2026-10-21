import 'package:flutter/material.dart';

import '../models/session.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_list.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onBrowse,
  });

  final List<Session> sessions;
  final ValueChanged<Session> onOpen;
  final ValueChanged<Session> onToggleFavourite;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = [...sessions.where((s) => s.favourite)]
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        actionLabel: 'Browse sessions',
        onAction: onBrowse,
      );
    }
    return SessionList(
      sessions: favourites,
      onOpen: onOpen,
      onToggleFavourite: onToggleFavourite,
    );
  }
}
