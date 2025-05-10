class TokenHelper {
  // Approximate: 1 word = 1.33 tokens
  static int _estimateTokenCount(String text) {
    if (text.isEmpty) return 0;
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return (words * 1.33).ceil();
  }

  // Truncate text to fit within max tokens
  static String truncateText(String text, int maxTokens) {
    if (_estimateTokenCount(text) <= maxTokens) return text;

    final words = text.split(RegExp(r'\s+'));
    final truncatedWords = <String>[];
    int currentTokens = 0;

    for (var word in words) {
      final wordTokens = _estimateTokenCount(word);
      if (currentTokens + wordTokens > maxTokens) break;
      truncatedWords.add(word);
      currentTokens += wordTokens;
    }

    return truncatedWords.join(' ');
  }
}
