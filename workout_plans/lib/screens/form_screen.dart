import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/session.dart';
import '../models/session_category.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';

typedef _FormValues = ({
  String title,
  SessionCategory? category,
  bool online,
  String venue,
  DateTime? date,
  TimeOfDay? time,
  String limit,
  String description,
});

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _venue;
  late final TextEditingController _limit;
  late final TextEditingController _description;
  late final TextEditingController _dateText;
  late final TextEditingController _timeText;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _venueFocus = FocusNode();
  final FocusNode _limitFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  SessionCategory? _category;
  bool _online = false;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;

  late final _FormValues _initial;

  bool get _isNew => widget.args.item == null;

  @override
  void initState() {
    super.initState();
    final item = widget.args.item;
    final base = item ?? Session.empty();

    final DateTime? date = item == null
        ? null
        : DateTime(
            item.scheduledAt.year,
            item.scheduledAt.month,
            item.scheduledAt.day,
          );
    final TimeOfDay? time = item == null
        ? null
        : TimeOfDay.fromDateTime(item.scheduledAt);

    _title = TextEditingController(text: base.title);
    _venue = TextEditingController(text: base.venue);
    _limit = TextEditingController(text: base.limit.toString());
    _description = TextEditingController(text: base.description ?? '');
    _dateText = TextEditingController(
      text: date == null ? '' : formatDay(date),
    );
    _timeText = TextEditingController(
      text: time == null ? '' : formatTime(time.hour, time.minute),
    );
    _category = item?.category;
    _online = base.online;
    _date = date;
    _time = time;
    _initial = _current;
  }

  @override
  void dispose() {
    _title.dispose();
    _venue.dispose();
    _limit.dispose();
    _description.dispose();
    _dateText.dispose();
    _timeText.dispose();
    _titleFocus.dispose();
    _venueFocus.dispose();
    _limitFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  _FormValues get _current => (
    title: _title.text,
    category: _category,
    online: _online,
    venue: _venue.text,
    date: _date,
    time: _time,
    limit: _limit.text,
    description: _description.text,
  );

  bool get _dirty => _current != _initial;

  void _rebuild() => setState(() {});

  void _dismissKeyboard(PointerDownEvent event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  String? _validateTitle(String? value) {
    final length = (value ?? '').trim().length;
    if (length < 3 || length > 60) return 'Title must be 3-60 characters';
    return null;
  }

  String? _validateCategory(SessionCategory? value) {
    return value == null ? 'Choose a category' : null;
  }

  String? _validateVenue(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return _online ? 'A link is required' : 'A place is required';
    }
    if (_online && !text.contains('://')) {
      return 'The link must contain ://';
    }
    return null;
  }

  String? _validateLimit(String? value) {
    final limit = int.tryParse((value ?? '').trim());
    if (limit == null || limit < 1 || limit > 500) {
      return 'Enter a whole number from 1 to 500';
    }
    final item = widget.args.item;
    if (item != null && limit < item.count) {
      return 'Already ${item.count} people joined';
    }
    return null;
  }

  String? _validateDate(String? value) {
    final date = _date;
    if (date == null) return 'Pick a date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_isNew && date.isBefore(today)) return 'The date is in the past';
    return null;
  }

  String? _validateTime(String? value) {
    final time = _time;
    if (time == null) return 'Pick a time';
    final date = _date;
    if (_isNew &&
        date != null &&
        _combine(date, time).isBefore(DateTime.now())) {
      return 'Pick a time in the future';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    return (value ?? '').length > 300 ? 'Up to 300 characters' : null;
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = _date ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: initial.isBefore(today) ? initial : today,
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
    _dateText.text = formatDay(picked);
  }

  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked == null || !mounted) return;
    setState(() => _time = picked);
    _timeText.text = formatTime(picked.hour, picked.minute);
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final date = _date;
    final time = _time;
    if (date == null || time == null) {
      setState(() => _saving = false);
      return;
    }

    final base = widget.args.item ?? Session.empty();
    final description = _description.text.trim();
    final result = base.copyWith(
      title: _title.text.trim(),
      category: _category,
      scheduledAt: _combine(date, time),
      venue: _venue.text.trim(),
      limit: int.tryParse(_limit.text.trim()) ?? base.limit,
      online: _online,
      description: description.isEmpty ? null : description,
      clearDescription: description.isEmpty,
    );
    Navigator.pop(context, result);
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop || _saving) return;
    final discard = await showConfirmDialog(
      context,
      title: 'Discard changes?',
      message: 'Your edits will be lost.',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep editing',
    );
    if (discard != true || !mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_dirty && !_saving,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New session' : 'Edit session')),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: _rebuild,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    TextFormField(
                      controller: _title,
                      focusNode: _titleFocus,
                      decoration: const InputDecoration(labelText: 'Title'),
                      maxLength: 60,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      validator: _validateTitle,
                      onTapOutside: _dismissKeyboard,
                      onFieldSubmitted: (_) => _venueFocus.requestFocus(),
                    ),
                    DropdownButtonFormField<SessionCategory>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: [
                        for (final category in SessionCategory.values)
                          DropdownMenuItem(
                            value: category,
                            child: Row(
                              spacing: 12,
                              children: [
                                Icon(
                                  category.icon,
                                  color: category.colorOf(scheme),
                                ),
                                Text(category.label),
                              ],
                            ),
                          ),
                      ],
                      validator: _validateCategory,
                      onChanged: (value) => setState(() => _category = value),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Online session'),
                      subtitle: const Text('The place becomes a link'),
                      value: _online,
                      onChanged: (value) =>
                          setState(() => _online = value ?? false),
                    ),
                    TextFormField(
                      controller: _venue,
                      focusNode: _venueFocus,
                      decoration: InputDecoration(
                        labelText: _online ? 'Meeting link' : 'Place',
                        hintText: _online ? 'https://...' : null,
                        prefixIcon: Icon(_online ? Icons.link : Icons.place),
                      ),
                      keyboardType: _online
                          ? TextInputType.url
                          : TextInputType.streetAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateVenue,
                      onTapOutside: _dismissKeyboard,
                      onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dateText,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            validator: _validateDate,
                            onTap: _pickDate,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _timeText,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Time',
                              suffixIcon: Icon(Icons.schedule),
                            ),
                            validator: _validateTime,
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _limit,
                      focusNode: _limitFocus,
                      decoration: const InputDecoration(
                        labelText: 'Maximum participants',
                        prefixIcon: Icon(Icons.groups),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      validator: _validateLimit,
                      onTapOutside: _dismissKeyboard,
                      onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                    ),
                    TextFormField(
                      controller: _description,
                      focusNode: _descriptionFocus,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      maxLength: 300,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      validator: _validateDescription,
                      onTapOutside: _dismissKeyboard,
                      onFieldSubmitted: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
