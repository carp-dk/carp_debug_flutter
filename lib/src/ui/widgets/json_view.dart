import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A read-only, monospaced viewer for an arbitrary value.
///
/// Maps and lists are pretty-printed as indented JSON; scalars are shown as-is.
/// The content can be copied to the clipboard via the copy button.
class JsonView extends StatelessWidget {
  /// Creates a viewer for [value].
  const JsonView({super.key, required this.value});

  /// The value to render (any JSON-like structure or scalar).
  final Object? value;

  /// Formats [value] as pretty JSON when possible, falling back to
  /// `toString()` for values that are not JSON-encodable.
  static String format(Object? value) {
    if (value == null) return 'null';
    if (value is String) return value;
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = format(value);
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: SelectableText(
            text,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            tooltip: 'Copy',
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
