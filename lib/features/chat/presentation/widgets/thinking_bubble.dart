import 'package:flutter/material.dart';

import 'package:notte_chat/shared/style/color.dart';
import 'package:notte_chat/features/settings/presentation/provider/settings_provider.dart';
import 'package:provider/provider.dart';

Widget thinkingBubble(ThemeData theme, BuildContext context) {
  final provider = context.read<SettingsProvider>();
  return Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: provider.isDarkMode ? Colors.grey[700] : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor), strokeWidth: 2),
          SizedBox(width: 8),
          Text('Thinking...', style: theme.textTheme.bodyMedium),
        ],
      ),
    ),
  );
}
