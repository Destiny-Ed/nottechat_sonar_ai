import 'package:notte_chat/features/chat/data/model/chat_model.dart';

abstract class DBHelperInterface {
  Future<void> init();
  Future<List<ChatSession>> loadSessions();
  Future<int> insertSession(ChatSession session);
  Future<int> insertMessage(ChatMessage message, int sessionId);
  Future<void> deleteSession(int sessionId);
}
