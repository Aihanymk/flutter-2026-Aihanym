import 'package:flutter/material.dart';

import '../models/session.dart';
import 'session_card.dart';

class SessionList extends StatelessWidget {
  const SessionList({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Session> sessions;
  final ValueChanged<Session> onOpen;
  final ValueChanged<Session> onToggleFavourite;

  static const double _gridBreakpoint = 600;
  static const double _maxCardWidth = 360;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(16, 8, 16, 88);

  Widget _card(Session session) {
    return SessionCard(
      session: session,
      onTap: () => onOpen(session),
      onToggleFavourite: () => onToggleFavourite(session),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _gridBreakpoint) {
          return GridView.builder(
            padding: _padding,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: _maxCardWidth,
              mainAxisExtent: 132,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: sessions.length,
            itemBuilder: (context, index) => _card(sessions[index]),
          );
        }
        return ListView.separated(
          padding: _padding,
          itemCount: sessions.length,
          itemBuilder: (context, index) => _card(sessions[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        );
      },
    );
  }
}
