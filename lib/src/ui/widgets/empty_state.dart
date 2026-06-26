import 'package:flutter/material.dart';

/// A centered placeholder shown when a list/store/database is empty.
class EmptyState extends StatelessWidget {
  /// Creates an empty-state placeholder.
  const EmptyState({super.key, required this.icon, required this.message});

  /// Illustrative icon.
  final IconData icon;

  /// Explanation of why nothing is shown.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.white30),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
