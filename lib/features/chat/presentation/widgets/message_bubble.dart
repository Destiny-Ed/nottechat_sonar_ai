import 'package:flutter/services.dart';
import 'package:notte_chat/core/extensions/date_extension.dart';
import 'package:notte_chat/core/utils/text_parser.dart';
import 'package:notte_chat/features/chat/data/model/chat_model.dart';
import 'package:notte_chat/features/chat/presentation/provider/chat_provider.dart';
import 'package:flutter/material.dart';

import 'package:notte_chat/shared/style/color.dart';
import 'package:notte_chat/features/settings/presentation/provider/settings_provider.dart';
import 'package:provider/provider.dart';

Widget messageBubble(BuildContext context, ChatMessage msg, ThemeData theme, String searchQuery) {
  final provider = context.read<SettingsProvider>();
  return Align(
    alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(12),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: BoxDecoration(
        color:
            msg.isUser
                ? primaryColor[500]
                : provider.isDarkMode
                ? Colors.grey[700]
                : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: !msg.isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (msg.isAudio)
                Icon(Icons.mic, size: 16, color: msg.isUser ? Colors.white : theme.textTheme.bodyMedium!.color),
              SizedBox(width: msg.isAudio ? 8 : 0),
              Flexible(
                child: buildHighlightedText(
                  msg.text,
                  searchQuery, // User's search query
                  TextStyle(color: msg.isUser ? Colors.white : theme.textTheme.bodyMedium!.color, fontSize: 14),
                  highlightColor: primaryColor,
                ),
              ),
            ],
          ),
          if (!msg.isUser)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    splashColor: primaryColor,
                    child: Icon(
                      Icons.copy,
                      size: 16,
                      color: msg.isUser ? Colors.white : theme.textTheme.bodyMedium!.color,
                    ),
                    onTap: () async {
                      HapticFeedback.heavyImpact();
                      final data = ClipboardData(text: msg.text);

                      await Clipboard.setData(data);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("copied".cap)));
                    },
                  ),
                  InkWell(
                    splashColor: primaryColor,
                    child: Icon(
                      Icons.volume_up,
                      size: 16,
                      color: msg.isUser ? Colors.white : theme.textTheme.bodyMedium!.color,
                    ),

                    onTap: () => context.read<ChatProvider>().speak(msg.text),
                  ),
                ],
              ),
            ),
          if (msg.isUser)
            Text(
              msg.createdAt.formatTime(),
              textAlign: TextAlign.end,
              style: TextStyle(color: msg.isUser ? Colors.white : theme.textTheme.bodyMedium!.color, fontSize: 10),
            ),
        ],
      ),
    ),
  );
}

Widget buildHighlightedText(
  String fullText,
  String query,
  TextStyle baseStyle, {
  Color highlightColor = Colors.yellow,
}) {
  if (query.isEmpty) {
    return FormattedText(text: fullText, baseStyle: baseStyle); // Fallback if no query
  }

  // Case-insensitive search
  final lowerText = fullText.toLowerCase();
  final lowerQuery = query.toLowerCase();
  final List<TextSpan> spans = [];

  int start = 0;
  while (true) {
    final int matchIndex = lowerText.indexOf(lowerQuery, start);
    if (matchIndex == -1) {
      // Add remaining text
      spans.add(TextSpan(text: fullText.substring(start)));
      break;
    }

    // Add text before match
    if (matchIndex > start) {
      spans.add(TextSpan(text: fullText.substring(start, matchIndex)));
    }

    // Add highlighted match
    spans.add(
      TextSpan(
        text: fullText.substring(matchIndex, matchIndex + query.length),
        style: baseStyle.copyWith(backgroundColor: highlightColor, color: Colors.white),
      ),
    );

    start = matchIndex + query.length;
  }

  return RichText(text: TextSpan(style: baseStyle, children: spans));
}

class FormattedText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;

  const FormattedText({required this.text, this.baseStyle, super.key});

  @override
  Widget build(BuildContext context) {
    final segments = TextParser.parse(text);
    return RichText(
      text: TextSpan(
        children:
            segments.map((segment) {
              return TextSpan(
                text: segment.text,
                style:
                    segment.isBold
                        ? (baseStyle ?? const TextStyle()).copyWith(fontWeight: FontWeight.bold, fontSize: 14)
                        : baseStyle,
              );
            }).toList(),
        style: const TextStyle(color: Colors.black, fontSize: 14), // Default style
      ),
    );
  }
}
