import 'package:notte_chat/features/chat/presentation/provider/chat_provider.dart';
import 'package:flutter/material.dart';

Widget presetButton(String label, String question, ChatProvider provider, int sessionIndex) {
  return Expanded(
    child: ElevatedButton(
      onPressed: () => provider.sendMessage(question, sessionIndex),
      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
      child: Text(label, style: TextStyle(fontSize: 12)),
    ),
  );
}
