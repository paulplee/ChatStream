import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;

  const MessageBubble({
    Key? key,
    required this.text,
    required this.isUserMessage,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment:
            isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isUserMessage
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            child: Text(
              text,
              style: TextStyle(
                color: isUserMessage
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSecondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              DateFormat('HH:mm').format(timestamp),
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
