import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _pages.dispose();
    _year.dispose();
    super.dispose();
  }

  String? _validateTitle(String? v) =>
      (v ?? '').trim().length < 2 ? 'At least 2 characters' : null;

  String? _validateAuthor(String? v) =>
      (v ?? '').trim().isEmpty ? 'Author is required' : null;

  String? _validatePages(String? v) {
    final n = int.tryParse(v ?? '');
    if (n == null || n <= 0) return 'A whole number above 0';
    return null;
  }

  String? _validateYear(String? v) {
    if (v == null || v.isEmpty) return null;
    final n = int.tryParse(v);
    final max = DateTime.now().year;
    if (n == null || n < 1450 || n > max) {
      return 'A year between 1450 and $max';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final book = Book(
      title: _title.text.trim(),
      author: _author.text.trim(),
      pages: int.parse(_pages.text),
      year: int.tryParse(_year.text),
    );
    Navigator.of(context).pop(book);
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? type,
    TextInputAction action = TextInputAction.next,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: type,
        textInputAction: action,
        validator: validator,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              _field(
                controller: _title,
                label: 'Title',
                validator: _validateTitle,
              ),
              _field(
                controller: _author,
                label: 'Author',
                validator: _validateAuthor,
              ),
              _field(
                controller: _pages,
                label: 'Pages',
                validator: _validatePages,
                type: TextInputType.number,
              ),
              _field(
                controller: _year,
                label: 'Year (optional)',
                validator: _validateYear,
                type: TextInputType.number,
                action: TextInputAction.done,
              ),
              FilledButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
