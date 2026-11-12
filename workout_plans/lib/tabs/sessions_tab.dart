import 'package:flutter/material.dart';

import '../models/session.dart';
import '../models/session_category.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_list.dart';

class SessionsTab extends StatefulWidget {
  const SessionsTab({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Session> sessions;
  final ValueChanged<Session> onOpen;
  final ValueChanged<Session> onToggleFavourite;

  @override
  State<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends State<SessionsTab> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  SessionCategory? _category;
  bool _showPast = true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Session> get _visible {
    final query = _query.trim().toLowerCase();
    return widget.sessions.where((s) {
      final inCategory = _category == null || s.category == _category;
      final inTime = _showPast || !s.isPast;
      final inSearch = query.isEmpty || s.title.toLowerCase().contains(query);
      return inCategory && inTime && inSearch;
    }).toList()..sort(_compare);
  }

  static int _compare(Session a, Session b) {
    if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
    return a.isPast
        ? b.scheduledAt.compareTo(a.scheduledAt)
        : a.scheduledAt.compareTo(b.scheduledAt);
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _query = value),
            onTapOutside: (event) =>
                FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              hintText: 'Search sessions',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final category in SessionCategory.values)
                ChoiceChip(
                  label: Text(category.label),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
              FilterChip(
                label: const Text('Past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? _emptyState()
              : SessionList(
                  sessions: visible,
                  onOpen: widget.onOpen,
                  onToggleFavourite: widget.onToggleFavourite,
                ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    if (widget.sessions.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy,
        message: 'No sessions yet. Tap + to add one.',
      );
    }
    return EmptyState(
      icon: Icons.search_off,
      message: 'Nothing matches your search',
      actionLabel: 'Clear search',
      onAction: _clearSearch,
    );
  }
}
