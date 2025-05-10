///TEXT parser(make bold) for asterick response from AI
class TextParser {
  static List<TextSegment> parse(String input) {
    final segments = <TextSegment>[];
    final boldPattern = RegExp(r'\*\*?(.*?)\*\*?'); // Matches *text* or **text**
    int lastEnd = 0;

    // Find all matches
    for (final match in boldPattern.allMatches(input)) {
      final start = match.start;
      final end = match.end;
      final text = match.group(1)!; // Text between asterisks

      // Add text before the match (regular)
      if (start > lastEnd) {
        segments.add(TextSegment(text: input.substring(lastEnd, start), isBold: false));
      }

      // Add matched text (bold)
      segments.add(TextSegment(text: text, isBold: true));

      lastEnd = end;
    }

    // Add remaining text (regular)
    if (lastEnd < input.length) {
      segments.add(TextSegment(text: input.substring(lastEnd), isBold: false));
    }

    return segments;
  }
}

class TextSegment {
  final String text;
  final bool isBold;

  TextSegment({required this.text, required this.isBold});
}
