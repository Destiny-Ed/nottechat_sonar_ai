class ChatMessage {
  final int? id;
  final String text;
  final bool isUser;
  final bool isAudio;
  final DateTime createdAt;

  ChatMessage({this.id, required this.text, required this.isUser, this.isAudio = false, required this.createdAt});

  Map<String, dynamic> toMap(int sessionId) {
    return {
      'sessionId': sessionId,
      'text': text,
      'isUser': isUser ? 1 : 0,
      'isAudio': isAudio ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      text: map['text'],
      isUser: map['isUser'] == 1,
      isAudio: map['isAudio'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class ChatSession {
  final int? id;
  final String title;
  final DateTime createdAt;
  final List<String> pdfTexts; // Multi-PDF support
  final List<String> pdfPaths; // Multi-PDF support
  final List<ChatMessage> messages;
  final String shareId; // Collaboration ID

  ChatSession({
    this.id,
    required this.title,
    required this.createdAt,
    this.pdfTexts = const [],
    this.pdfPaths = const [],
    this.messages = const [],
    required this.shareId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'pdfTexts': pdfTexts.join(','),
      'pdfPaths': pdfPaths.join(','),
      'shareId': shareId,
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map, List<ChatMessage> messages) {
    return ChatSession(
      id: map['id'],
      title: map['title'],
      createdAt: DateTime.parse(map['createdAt']),
      pdfTexts: (map['pdfTexts'] as String).isEmpty ? [] : (map['pdfTexts'] as String).split(','),
      pdfPaths: (map['pdfPaths'] as String).isEmpty ? [] : (map['pdfPaths'] as String).split(','),
      messages: messages,
      shareId: map['shareId'] ?? 'share_${map['id'] ?? DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
