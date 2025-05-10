// lib/helpers/dbHelper_web.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notte_chat/features/chat/data/model/chat_model.dart';
import 'package:notte_chat/features/chat/data/repo/db_helper_interface.dart';

class DBHelperWeb implements DBHelperInterface {
  static const String _sessionsBox = 'sessions';
  static const String _messagesBox = 'messages';

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_sessionsBox)) {
      await Hive.openBox(_sessionsBox);
    }
    if (!Hive.isBoxOpen(_messagesBox)) {
      await Hive.openBox(_messagesBox);
    }
  }

  @override
  Future<List<ChatSession>> loadSessions() async {
    final sessionsBox = Hive.box(_sessionsBox);
    final messagesBox = Hive.box(_messagesBox);
    List<ChatSession> sessions = [];
    for (var key in sessionsBox.keys) {
      final sessionMap = sessionsBox.get(key) as Map<dynamic, dynamic>;
      final sessionId = sessionMap['id'] as int;
      final messageKeys = messagesBox.keys.where((k) => messagesBox.get(k)['sessionId'] == sessionId);
      final messages = messageKeys.map((k) => ChatMessage.fromMap(messagesBox.get(k))).toList();
      sessions.add(ChatSession.fromMap(sessionMap.cast<String, dynamic>(), messages));
    }
    return sessions;
  }

  @override
  Future<int> insertSession(ChatSession session) async {
    final sessionsBox = Hive.box(_sessionsBox);
    final id = sessionsBox.length + 1; // Simple ID generation
    final sessionMap = session.toMap()..['id'] = id;
    await sessionsBox.put(id, sessionMap);
    return id;
  }

  @override
  Future<int> insertMessage(ChatMessage message, int sessionId) async {
    final messagesBox = Hive.box(_messagesBox);
    final id = messagesBox.length + 1; // Simple ID generation
    final messageMap = message.toMap(sessionId)..['id'] = id;
    await messagesBox.put(id, messageMap);
    return id;
  }

  @override
  Future<void> deleteSession(int sessionId) async {
    final sessionsBox = Hive.box(_sessionsBox);
    final messagesBox = Hive.box(_messagesBox);
    // Delete messages for this session
    final messageKeys = messagesBox.keys.where((k) => messagesBox.get(k)['sessionId'] == sessionId);
    for (var key in messageKeys) {
      await messagesBox.delete(key);
    }
    // Delete session
    await sessionsBox.delete(sessionId);
  }
}
