import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/session.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Session _item = widget.args.item;
  DateTime _now = DateTime.now();
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _apply(Session updated) {
    setState(() => _item = updated);
    widget.args.onChanged(updated);
  }

  Future<void> _join() async {
    final name = widget.args.profileName.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Set your name in the profile first'),
          action: SnackBarAction(label: 'Profile', onPressed: _openProfile),
        ),
      );
      return;
    }
    final confirmed = await showConfirmDialog(
      context,
      title: 'Join this session?',
      message: 'You will be added to "${_item.title}".',
      confirmLabel: 'Join',
    );
    if (confirmed != true || !mounted) return;
    _apply(_item.copyWith(names: [..._item.names, name]));
  }

  void _leave() {
    final name = widget.args.profileName.trim().toLowerCase();
    _apply(
      _item.copyWith(
        names: _item.names.where((n) => n.toLowerCase() != name).toList(),
      ),
    );
  }

  void _openProfile() {
    widget.args.onOpenProfile();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _edit() async {
    final edited = await Navigator.pushNamed<Session>(
      context,
      Routes.form,
      arguments: FormArgs(item: _item),
    );
    if (edited == null || !mounted) return;
    _apply(edited);
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete session?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (confirmed != true || !mounted) return;
    widget.args.onDelete(_item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.args.profileName;
    final joined = _item.contains(name);
    final VoidCallback? action = joined
        ? _leave
        : (_item.isFull || _item.isPast ? null : _join);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Session'),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: (selected) {
                switch (selected) {
                  case _MenuAction.edit:
                    _edit();
                  case _MenuAction.delete:
                    _delete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(item: _item, countdown: _item.countdownAt(_now)),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Participants (${_item.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(item: _item),
                  _NamesTab(names: _item.names, you: name),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: action,
              child: Text(joined ? 'Leave' : 'Join'),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.item, required this.countdown});

  final Session item;
  final Countdown countdown;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final countdownText = switch (countdown) {
      Upcoming(:final remaining) => 'Starts in ${formatDuration(remaining)}',
      Started(:final elapsed) => 'Started ${formatDuration(elapsed)} ago',
      Ended() => 'Ended',
    };

    return SizedBox(
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/workout.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.scrim.withValues(alpha: 0.35),
            ),
          ),
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: scheme.surface,
              child: Icon(
                item.category.icon,
                size: 36,
                color: item.category.colorOf(scheme),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Chip(label: Text(item.category.label)),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Chip(
              avatar: const Icon(Icons.timer_outlined),
              label: Text(countdownText),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.item});

  final Session item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (:taken, :free) = item.places;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(item.title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.event),
          title: Text(formatDate(item.scheduledAt)),
        ),
        ListTile(
          leading: Icon(item.online ? Icons.link : Icons.place),
          title: Text(item.venue),
          subtitle: Text(item.online ? 'Online - link' : 'Place'),
        ),
        ListTile(
          leading: const Icon(Icons.groups),
          title: Text('$taken of ${item.limit} places taken'),
          subtitle: Text('$free free'),
        ),
        if (item.description case final text?)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(text, style: theme.textTheme.bodyLarge),
          ),
      ],
    );
  }
}

class _NamesTab extends StatelessWidget {
  const _NamesTab({required this.names, required this.you});

  final List<String> names;
  final String you;

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) {
      return const EmptyState(
        icon: Icons.group_off,
        message: 'Nobody has joined yet',
      );
    }
    final scheme = Theme.of(context).colorScheme;
    final me = you.trim().toLowerCase();

    return ListView.builder(
      itemCount: names.length,
      itemBuilder: (context, index) {
        final name = names[index];
        final isYou = me.isNotEmpty && name.toLowerCase() == me;
        return ListTile(
          leading: CircleAvatar(child: Text(name.substring(0, 1))),
          title: Text(isYou ? '$name (You)' : name),
          selected: isYou,
          selectedTileColor: scheme.primaryContainer,
        );
      },
    );
  }
}
