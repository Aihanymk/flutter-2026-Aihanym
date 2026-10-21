import 'package:flutter/material.dart';
import 'summary_card.dart';

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _birthDateController = TextEditingController();

  final _emailFocusNode = FocusNode();

  String? _selectedGroup;
  DateTime? _birthDate;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _emailController,
      _passwordController,
      _confirmController,
      _birthDateController,
    ]) {
      c.dispose();
    }
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _onSignUp() {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created')),
      );
      setState(() {
        _done = true;
      });
    }
  }

  void _startOver() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmController.clear();
    _birthDateController.clear();

    setState(() {
      _selectedGroup = null;
      _birthDate = null;
      _agreed = false;
      _done = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text =
        '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'),
      ),
      body: _done
          ? SingleChildScrollView(
        child: Column(
          children: [
            SummaryCard(
              name: _nameController.text,
              email: _emailController.text,
              group: _selectedGroup ?? '',
              birthDate: _birthDate!,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _startOver,
              child: const Text('Start over'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  _emailFocusNode.requestFocus();
                },
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (v) {
                  final trimmed = (v ?? '').trim();
                  if (trimmed.length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'name@kbtu.kz',
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (v) {
                  final val = v ?? '';
                  if (!val.contains('@') || !val.contains('.')) {
                    return 'Email must contain @ and .';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  helperText: 'At least 8 characters',
                ),
                obscureText: true,
                textInputAction: TextInputAction.next,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (v) {
                  if ((v ?? '').length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _onSignUp(),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (v) {
                  if (v != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedGroup,
                decoration: const InputDecoration(
                  labelText: 'Group',
                ),
                items: groups.map((g) {
                  return DropdownMenuItem(
                    value: g,
                    child: Text(g),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedGroup = val;
                  });
                },
                validator: (g) =>
                g == null ? 'Choose a group' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _pickDate,
                validator: (_) =>
                _birthDate == null ? 'Select birth date' : null,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('I agree to the rules'),
                value: _agreed,
                onChanged: (val) {
                  setState(() {
                    _agreed = val ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _agreed ? _onSignUp : null,
                child: const Text('Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}