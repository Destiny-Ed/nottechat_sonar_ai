import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:notte_chat/core/constants.dart';
import 'package:notte_chat/core/utils/analysis_logger.dart';
import 'package:notte_chat/core/utils/pick_pdf.dart';
import 'package:notte_chat/core/utils/sonar_service.dart';
import 'package:notte_chat/features/chat/data/model/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:notte_chat/features/chat/data/repo/db_helper_factory.dart';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart' as ai;

class ChatProvider extends ChangeNotifier {
  List<ChatSession> _sessions = [];
  final _dbHelper = getDBHelper();
  final FlutterTts tts = FlutterTts();

  bool _isThinking = false;
  bool isTTsSpeaking = false;
  bool _isExtracting = false;
  String _selectedPersona = 'Default'; // Custom AI personas
  final Map<String, String> _personas = {
    'Default': 'I’ll answer clearly and concisely.',
    'Professor': 'Allow me to explain in a detailed, academic tone.',
    'Casual': 'Hey, I’ll keep it chill and simple!',
    'Techie': 'Let’s geek out with a technical spin!',
  };

  List<ChatSession> get sessions => _sessions;
  bool get isThinking => _isThinking;
  bool get isExtracting => _isExtracting;
  String get selectedPersona => _selectedPersona;
  Map<String, String> get personas => _personas;

  set isExtracting(bool value){
    _isExtracting = value;
    notifyListeners();
  }

  ChatProvider() {
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    _sessions = await _dbHelper.loadSessions();
    for (var session in _sessions) {
      session.messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    notifyListeners();
  }

  Future<void> createChatFromDocuments(List<PlatformFile> documentFiles) async {
    _isExtracting = true;
    notifyListeners();
    try {
      List<String> pdfTexts = [];
      List<String> pdfPaths = [];
      String title = documentFiles.first.name; // Use file name for title
      for (var file in documentFiles) {
        final getText = await extractText(file);

        if (getText.isNotEmpty) {
          pdfTexts.add(getText);
          pdfPaths.add(kIsWeb ? file.name : file.path ?? file.name); // Use name on web, path on mobile
        }
      }
      if (pdfTexts.isNotEmpty) {
        ChatSession newSession = ChatSession(
          title: documentFiles.length > 1 ? 'Multi-Document Chat: $title' : title,
          createdAt: DateTime.now(),
          pdfTexts: pdfTexts,
          pdfPaths: pdfPaths,
          messages: [ChatMessage(text: 'Document(s) loaded successfully!', isUser: false, createdAt: DateTime.now())],
          shareId: 'share_${DateTime.now().millisecondsSinceEpoch}',
        );

        int sessionId = await _dbHelper.insertSession(newSession);
        newSession = ChatSession(
          id: sessionId,
          title: newSession.title,
          createdAt: newSession.createdAt,
          pdfTexts: newSession.pdfTexts,
          pdfPaths: newSession.pdfPaths,
          messages: newSession.messages,
          shareId: newSession.shareId,
        );
        await _dbHelper.insertMessage(newSession.messages[0], sessionId);

        _sessions.add(newSession);
        notifyListeners();
      } else {
        throw Exception("Error extracting text from document");
      }
    } catch (e) {
      ChatSession errorSession = ChatSession(
        title: documentFiles.first.name,
        createdAt: DateTime.now(),
        pdfTexts: [],
        messages: [
          ChatMessage(
            text: 'Failed to load document. Try a smaller or different file.',
            isUser: false,
            createdAt: DateTime.now(),
          ),
        ],
        shareId: 'share_${DateTime.now().millisecondsSinceEpoch}',
      );
      int sessionId = await _dbHelper.insertSession(errorSession);
      await _dbHelper.insertMessage(errorSession.messages[0], sessionId);
      _sessions.add(
        ChatSession(
          id: sessionId,
          title: errorSession.title,
          createdAt: errorSession.createdAt,
          pdfTexts: errorSession.pdfTexts,
          messages: errorSession.messages,
          shareId: errorSession.shareId,
        ),
      );
      notifyListeners();
      AnalysisLogger.logEvent("document_error", EventDataModel(value: e.toString()));
    } finally {
      _isExtracting = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String message, int sessionIndex, {bool isAudio = false}) async {
    final session = _sessions[sessionIndex];
    ChatMessage userMsg = ChatMessage(text: message, isUser: true, isAudio: isAudio, createdAt: DateTime.now());
    int msgId = await _dbHelper.insertMessage(userMsg, session.id!);
    session.messages.add(
      ChatMessage(id: msgId, text: message, isUser: true, isAudio: isAudio, createdAt: userMsg.createdAt),
    );
    notifyListeners();

    _isThinking = true;
    notifyListeners();

    String response = await _getAIResponse(message, session.pdfTexts.join('\n'), persona: _selectedPersona);
    ChatMessage aiMsg = ChatMessage(text: response, isUser: false, createdAt: DateTime.now());
    int aiMsgId = await _dbHelper.insertMessage(aiMsg, session.id!);
    session.messages.add(ChatMessage(id: aiMsgId, text: response, isUser: false, createdAt: aiMsg.createdAt));

    _isThinking = false;
    notifyListeners();

    ///add vibration
    HapticFeedback.heavyImpact();
  }

  Future<String> getSummary(int sessionIndex) async {
    final session = _sessions[sessionIndex];
    return 'Summary: ${session.pdfTexts.join(" ").substring(0, 100)}...'; // Simulated summary
  }

  Future<void> deleteChat(int sessionIndex) async {
    final session = _sessions[sessionIndex];
    await _dbHelper.deleteSession(session.id!);
    _sessions.removeAt(sessionIndex);
    notifyListeners();
  }

  void setPersona(String persona) {
    _selectedPersona = persona;
    notifyListeners();
  }

  Future<String> _getAIResponse(String query, String pdfText, {required String persona}) async {
    final isOffline = 3 < 1;
    if (isOffline) return 'Offline: Basic answer to "$query".'; // Offline mode from ProProvider
    try {
      final prompt =
          'Persona: $persona\nContext: $pdfText\nQuery: $query\nRespond in the style of the specified persona.';
      // final response = await _model.generateContent([ai.Content.text(prompt)]);
      final response = await SonarService().queryDocument(prompt);
      if (response == null) return 'NotteChat returned no text';
      return response;
    } on SocketException catch (_) {
      return 'connection error: please check your network connection';
    } catch (e) {
      return 'AI content generation failed: $e';
    }
  }

  void speak(String text) async {
    HapticFeedback.heavyImpact();

    if (isTTsSpeaking) {
      await tts.stop();
      isTTsSpeaking = false;
    } else {
      isTTsSpeaking = true;
      await tts.speak(text);

      final isSpeaking = await tts.awaitSpeakCompletion(true);
      if (isSpeaking == 1) {
        //speaking stopped
        isTTsSpeaking = false;
      }
    }
  }
}
