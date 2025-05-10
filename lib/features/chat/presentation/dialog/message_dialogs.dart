import 'package:notte_chat/features/chat/presentation/provider/chat_provider.dart';
import 'package:flutter/material.dart';

void showSummary(BuildContext context, ChatProvider provider, int sessionIndex) async {
  String summary = await provider.getSummary(sessionIndex);
  if (!context.mounted) return;
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text('Summary'),
          content: Text(summary),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
        ),
  );
}

void shareSession(BuildContext context, String shareId) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text('Share Session'),
          content: Text('Share this ID: $shareId'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
        ),
  );
}
