import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/env_entry.dart';

/// Shows a modal editor for a `text` / `integer` launch argument and resolves
/// to the new value, or `null` if cancelled.
///
/// The [TextEditingController] is owned by the dialog's [State] and disposed in
/// `dispose()` — i.e. only after the dialog is fully removed from the tree.
/// Disposing it eagerly right after `showDialog` completes (while the dismiss
/// animation is still running) throws "A TextEditingController was used after
/// being disposed", which surfaces as a red error screen.
Future<String?> showEnvTextEditor(
  BuildContext context, {
  required EnvEntry entry,
  required String current,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _EnvTextDialog(entry: entry, current: current),
  );
}

class _EnvTextDialog extends StatefulWidget {
  const _EnvTextDialog({required this.entry, required this.current});

  final EnvEntry entry;
  final String current;

  @override
  State<_EnvTextDialog> createState() => _EnvTextDialogState();
}

class _EnvTextDialogState extends State<_EnvTextDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.current,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInt = widget.entry.type == EnvValueType.integer;
    return AlertDialog(
      title: Text(widget.entry.label),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: isInt ? TextInputType.number : TextInputType.text,
        inputFormatters: isInt
            ? [FilteringTextInputFormatter.allow(RegExp(r'[\d-]'))]
            : null,
        decoration: InputDecoration(
          labelText: widget.entry.key,
          helperText: 'Default: ${widget.entry.fallback}',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
