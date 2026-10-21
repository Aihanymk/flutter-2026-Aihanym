import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/session.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.sessions,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Session> sessions;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static final RegExp _groupPattern = RegExp(r'^[A-Za-z]{2,5}-\d{2,4}$');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _groupFocus = FocusNode();
  late final TextEditingController _name = TextEditingController(
    text: widget.profile.name,
  );
  late final TextEditingController _group = TextEditingController(
    text: widget.profile.group,
  );

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.profile, widget.profile)) {
      if (_name.text != widget.profile.name) _name.text = widget.profile.name;
      if (_group.text != widget.profile.group) {
        _group.text = widget.profile.group;
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if ((value ?? '').trim().length > 30) return 'Up to 30 characters';
    return null;
  }

  String? _validateGroup(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    return _groupPattern.hasMatch(text) ? null : 'Use the form IT-2301';
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onProfileChanged(
        widget.profile.copyWith(
          name: _name.text.trim(),
          group: _group.text.trim(),
        ),
      );
    }
  }

  String _modeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lists = widget.sessions
        .where((s) => s.contains(widget.profile.name))
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    spacing: 16,
                    children: [
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Your name',
                          helperText: 'Press the keyboard button to save',
                          prefixIcon: Icon(Icons.person),
                        ),
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: _validateName,
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        onFieldSubmitted: (_) {
                          _save();
                          _groupFocus.requestFocus();
                        },
                      ),
                      TextFormField(
                        controller: _group,
                        focusNode: _groupFocus,
                        decoration: const InputDecoration(
                          labelText: 'Group',
                          helperText: 'For example IT-2301',
                          prefixIcon: Icon(Icons.groups),
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        validator: _validateGroup,
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        onFieldSubmitted: (_) => _save(),
                      ),
                    ],
                  ),
                ),
                Text(
                  'You are on $lists ${lists == 1 ? 'list' : 'lists'}',
                  style: theme.textTheme.titleMedium,
                ),
                const Divider(),
                Text('Theme', style: theme.textTheme.titleMedium),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final mode in ThemeMode.values)
                      ChoiceChip(
                        label: Text(_modeLabel(mode)),
                        selected: widget.themeMode == mode,
                        onSelected: (_) => widget.onThemeModeChanged(mode),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
