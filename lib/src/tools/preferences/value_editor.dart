import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Result of editing/creating a preference: the resolved [key] and typed
/// [value].
class PrefEntryResult {
  /// Creates a preference edit result.
  const PrefEntryResult(this.key, this.value);

  /// The (possibly newly entered) preference key.
  final String key;

  /// The typed value to write (`String`, `bool`, `int`, `double` or
  /// `List<String>`).
  final Object value;
}

/// Shows a modal editor for a preference value and returns the new entry, or
/// `null` if cancelled.
///
/// When [initialValue] is `null` the editor is in "add" mode and lets the user
/// choose both the key and the value type; otherwise the type is inferred from
/// the existing value and the key is read-only.
Future<PrefEntryResult?> showPrefEditor(
  BuildContext context, {
  String? initialKey,
  Object? initialValue,
}) {
  return showDialog<PrefEntryResult>(
    context: context,
    builder: (context) =>
        _PrefEditorDialog(initialKey: initialKey, initialValue: initialValue),
  );
}

const _types = ['String', 'bool', 'int', 'double', 'List<String>'];

String _typeOf(Object value) => switch (value) {
  bool() => 'bool',
  int() => 'int',
  double() => 'double',
  List() => 'List<String>',
  _ => 'String',
};

class _PrefEditorDialog extends StatefulWidget {
  const _PrefEditorDialog({this.initialKey, this.initialValue});
  final String? initialKey;
  final Object? initialValue;

  @override
  State<_PrefEditorDialog> createState() => _PrefEditorDialogState();
}

class _PrefEditorDialogState extends State<_PrefEditorDialog> {
  late final TextEditingController _keyCtrl = TextEditingController(
    text: widget.initialKey ?? '',
  );
  late final TextEditingController _valueCtrl = TextEditingController(
    text: widget.initialValue is List
        ? (widget.initialValue! as List).join('\n')
        : widget.initialValue?.toString() ?? '',
  );
  late String _type = widget.initialValue != null
      ? _typeOf(widget.initialValue!)
      : 'String';
  late bool _boolValue = widget.initialValue is bool
      ? widget.initialValue! as bool
      : false;
  String? _error;

  bool get _isAdding => widget.initialValue == null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isAdding ? 'Add preference' : 'Edit "${widget.initialKey}"'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isAdding)
              TextField(
                controller: _keyCtrl,
                decoration: const InputDecoration(labelText: 'Key'),
              ),
            if (_isAdding)
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  for (final t in _types)
                    DropdownMenuItem(value: t, child: Text(t)),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'String'),
              ),
            const SizedBox(height: 8),
            _valueField(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  Widget _valueField() {
    if (_type == 'bool') {
      return SwitchListTile(
        title: const Text('Value'),
        value: _boolValue,
        onChanged: (v) => setState(() => _boolValue = v),
      );
    }
    final isNumber = _type == 'int' || _type == 'double';
    return TextField(
      controller: _valueCtrl,
      maxLines: _type == 'List<String>' ? 6 : 1,
      keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
      inputFormatters: _type == 'int'
          ? [FilteringTextInputFormatter.allow(RegExp(r'[\d-]'))]
          : null,
      decoration: InputDecoration(
        labelText: 'Value',
        helperText: _type == 'List<String>' ? 'One item per line' : null,
      ),
    );
  }

  void _save() {
    final key = _isAdding ? _keyCtrl.text.trim() : widget.initialKey!;
    if (key.isEmpty) {
      setState(() => _error = 'Key cannot be empty');
      return;
    }
    final Object? value = switch (_type) {
      'bool' => _boolValue,
      'int' => int.tryParse(_valueCtrl.text.trim()),
      'double' => double.tryParse(_valueCtrl.text.trim()),
      'List<String>' =>
        _valueCtrl.text
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      _ => _valueCtrl.text,
    };
    if (value == null) {
      setState(() => _error = 'Invalid $_type value');
      return;
    }
    Navigator.of(context).pop(PrefEntryResult(key, value));
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }
}
