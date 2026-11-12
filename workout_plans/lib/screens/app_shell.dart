import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/profile.dart';
import '../models/session.dart';
import '../routes.dart';
import '../tabs/favourites_tab.dart';
import '../tabs/profile_tab.dart';
import '../tabs/sessions_tab.dart';
import '../widgets/confirm_dialog.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const List<String> _titles = ['Sessions', 'Favourites', 'Profile'];

  int _index = 0;
  List<Session> _sessions = seedSessions();
  Profile _profile = const Profile.empty();

  void _select(int index) => setState(() => _index = index);

  void _updateProfile(Profile profile) => setState(() => _profile = profile);

  void _replace(Session updated) {
    setState(() {
      _sessions = [
        for (final s in _sessions)
          if (s.id == updated.id) updated else s,
      ];
    });
  }

  void _remove(Session removed) {
    setState(() {
      _sessions = _sessions.where((s) => s.id != removed.id).toList();
    });
  }

  void _toggleFavourite(Session session) {
    _replace(session.copyWith(favourite: !session.favourite));
  }

  Future<void> _addSession() async {
    final created = await Navigator.pushNamed<Session>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (created == null || !mounted) return;
    setState(() => _sessions = [..._sessions, created]);
  }

  void _openDetail(Session session) {
    Navigator.pushNamed(
      context,
      Routes.detail,
      arguments: DetailArgs(
        item: session,
        profileName: _profile.name,
        onChanged: _replace,
        onDelete: _remove,
        onOpenProfile: () => _select(2),
      ),
    );
  }

  void _showAbout() {
    Navigator.pop(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Workout Plans - Lab 1 of Mobile Development.\n'
          'Browse sessions, join them and keep favourites. '
          'All data lives in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    Navigator.pop(context);
    final confirmed = await showConfirmDialog(
      context,
      title: 'Reset data?',
      message: 'The sample sessions come back and your profile is cleared.',
      confirmLabel: 'Reset',
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _sessions = seedSessions();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Workout Plans',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: _showAbout,
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Reset data'),
                onTap: _resetData,
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: [
          SessionsTab(
            sessions: _sessions,
            onOpen: _openDetail,
            onToggleFavourite: _toggleFavourite,
          ),
          FavouritesTab(
            sessions: _sessions,
            onOpen: _openDetail,
            onToggleFavourite: _toggleFavourite,
            onBrowse: () => _select(0),
          ),
          ProfileTab(
            profile: _profile,
            sessions: _sessions,
            themeMode: widget.themeMode,
            onProfileChanged: _updateProfile,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              tooltip: 'New session',
              onPressed: _addSession,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
