import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:notte_chat/core/enums/enum.dart';
import 'package:notte_chat/core/utils/analysis_logger.dart';
import 'package:notte_chat/features/chat/presentation/provider/chat_provider.dart';
import 'package:flutter/material.dart';

import 'package:notte_chat/shared/style/color.dart';
import 'package:notte_chat/features/settings/presentation/provider/settings_provider.dart';
import 'package:notte_chat/features/subscription/presentation/dialog/pro_warning_dialog.dart';
import 'package:notte_chat/features/subscription/presentation/provider/subscription_provider.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatInput extends StatefulWidget {
  final int sessionIndex;
  final bool isPDF;

  const ChatInput({super.key, required this.sessionIndex, required this.isPDF});

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();

  late stt.SpeechToText _speech; // Speech-to-text instance
  bool _isListening = false; // Recording state
  String _voiceText = ''; // Text from voice input

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // Initialize speech recognition
  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => log('Speech status: $status'),
      onError: (error) => log('Speech error: $error'),
    );
    if (!available && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Speech recognition not available')));
    }
  }

  // Start/stop recording
  void _toggleRecording() async {
    HapticFeedback.heavyImpact();

    if (!_isListening) {
      await _initSpeech();
      if (_speech.isAvailable) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() => _voiceText = result.recognizedWords);
            _controller.text = _voiceText; // Update text field with voice input
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_voiceText.isNotEmpty) {
        await context.read<ChatProvider>().sendMessage(_voiceText, widget.sessionIndex, isAudio: true);
        _controller.clear(); // Clear after sending
        _voiceText = ''; // Reset voice text
        setState(() {});

        if (mounted) {
          final proProvider = context.read<ProProvider>();
          if (proProvider.unlockedFeature == ProFeaturesEnums.audioChat) proProvider.clearUnlockedFeature();
        }
      }
    }

    AnalysisLogger.logEvent("voice chat", EventDataModel(value: "Chat Input"));

    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<SettingsProvider>().isDarkMode;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(8),
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        child: Row(
          spacing: 8,
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color, fontSize: 14),
                minLines: 1,
                maxLines: 2,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Ask about the ${widget.isPDF ? "PDF" : "Word Document"}...',
                  hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color, fontSize: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  filled: true,
                  isDense: true,
                  fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: primaryColor,
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () {
                  final proProvider = context.read<ProProvider>();
                  final chatProvider = context.read<ChatProvider>();

                  if (_controller.text.isNotEmpty) {
                    ///Check if user conversations count is == 10 and not subscribed
                    if ((!proProvider.isProSubscribed &&
                            chatProvider.sessions[widget.sessionIndex].messages.length >= 10) &&
                        proProvider.unlockedFeature != ProFeaturesEnums.conversationSession) {
                      ///show dialog and then show paywall
                      showProUpgradeDialog(context, "unlimited conversation", ProFeaturesEnums.conversationSession);
                    } else {
                      chatProvider.sendMessage(_controller.text, widget.sessionIndex);
                      _controller.clear();

                      if (mounted) {
                        if (proProvider.unlockedFeature == ProFeaturesEnums.conversationSession)
                          proProvider.clearUnlockedFeature();
                      }

                      AnalysisLogger.logEvent("send chat", EventDataModel(value: "Chat Input"));
                    }
                  }
                },
              ),
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: _isListening ? Colors.red : Colors.green,
              child: IconButton(
                icon: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white),
                onPressed: () {
                  final proProvider = context.read<ProProvider>();
                  if (proProvider.isProSubscribed || proProvider.unlockedFeature == ProFeaturesEnums.audioChat) {
                    _toggleRecording();
                  } else {
                    ///show dialog and then show paywall
                    showProUpgradeDialog(context, "audio chat", ProFeaturesEnums.audioChat);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
