import 'package:flutter/material.dart';

/// Shows a modal confirmation dialog and resolves to `true` only if the user
/// taps the confirm action.
///
/// Used to guard destructive operations (deleting a record, clearing a store,
/// wiping preferences) so they are never one tap away.
Future<bool> showDebugConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  bool destructive = true,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: destructive ? Colors.redAccent : null,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
