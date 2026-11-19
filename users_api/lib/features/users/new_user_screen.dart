import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_model.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final model = context.read<UsersModel>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);

    final error = await model.create(
      User.draft(
        name: _name.text.trim(),
        username: _username.text.trim(),
        email: _email.text.trim(),
      ),
    );

    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(_message(error))));
    }
  }

  String _message(ApiException e) => switch (e) {
    NoConnectionException() => 'No connection. Try again.',
    NotFoundException() => 'The server could not find that resource.',
    UnauthorizedException() => 'You are not authorised to do this.',
    ServerException(:final status) => 'Server error ($status). Try later.',
    BadResponseException() => 'The server answered with unreadable data.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New user')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'At least 2 characters'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username'),
              textInputAction: TextInputAction.next,
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.length < 3) return 'At least 3 characters';
                if (s.contains(' ')) return 'No spaces';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(v?.trim() ?? '')
                  ? null
                  : 'Enter a valid email',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
