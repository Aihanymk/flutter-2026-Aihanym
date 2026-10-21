import 'package:flutter/material.dart';

import '../models/session.dart';
import '../utils/format.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final Session session;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final when = session.isPast
        ? '${formatDate(session.scheduledAt)} - past'
        : formatDate(session.scheduledAt);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(session: session),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      session.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      when,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      session.online ? 'Online session' : session.venue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: session.favourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: onToggleFavourite,
                icon: Icon(
                  session.favourite ? Icons.favorite : Icons.favorite_border,
                  color: session.favourite ? scheme.error : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final String? badge = session.isFull
        ? 'FULL'
        : (session.free <= 5 ? '${session.free} left' : null);

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CircleAvatar(
              backgroundColor: scheme.surfaceContainerHighest,
              child: Icon(
                session.category.icon,
                color: session.category.colorOf(scheme),
              ),
            ),
          ),
          if (badge case final text?)
            Positioned(
              right: -8,
              bottom: -6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: session.isFull
                      ? scheme.errorContainer
                      : scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Text(
                    text,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: session.isFull
                          ? scheme.onErrorContainer
                          : scheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
