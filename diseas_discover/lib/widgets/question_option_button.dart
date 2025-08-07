import 'package:flutter/material.dart';

class QuestionOptionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const QuestionOptionButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      onPressed: onPressed,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
      label: Text(text),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    );
  }
}
