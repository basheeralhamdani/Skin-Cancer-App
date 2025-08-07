import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUserMessage;
  final String? link;
  final VoidCallback? onLinkTap;

  const ChatBubble({
    super.key,
    required this.message,
    this.isUserMessage = false,
    this.link,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alignment =
        isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color =
        isUserMessage ? theme.colorScheme.primary : theme.colorScheme.surface;
    final textColor =
        isUserMessage ? Colors.white : theme.textTheme.bodyLarge?.color;
    final borderRadius = isUserMessage
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Material(
              borderRadius: borderRadius,
              color: color,
              elevation: 1,
              shadowColor: Colors.black.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 16.0),
                child: link != null
                    ? InkWell(
                        onTap: onLinkTap,
                        child: Text(
                          message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Text(message,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: textColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
