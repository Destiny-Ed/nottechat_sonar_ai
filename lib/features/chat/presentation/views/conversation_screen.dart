import 'package:notte_chat/core/extensions/date_extension.dart';
import 'package:notte_chat/core/utils/analysis_logger.dart';
import 'package:notte_chat/features/chat/presentation/provider/chat_provider.dart';
import 'package:notte_chat/features/chat/presentation/widgets/chat_input.dart';
import 'package:notte_chat/features/chat/presentation/widgets/message_bubble.dart';
import 'package:notte_chat/features/chat/presentation/widgets/preset_button.dart';
import 'package:notte_chat/features/chat/presentation/widgets/search_widget.dart';
import 'package:notte_chat/features/chat/presentation/widgets/thinking_bubble.dart';
import 'package:flutter/material.dart';
import 'package:notte_chat/features/settings/presentation/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final int sessionIndex;

  const ChatScreen({super.key, required this.sessionIndex});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // bool _showPdfViewer = false;
  // int _currentPdfPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    AnalysisLogger.logEvent("conversation opened", EventDataModel(value: "Conversation Screen"));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    // WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ChatProvider>().tts.stop());

    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  // void _onHighlightTap(String text) {
  //   setState(() => _highlightedText = text);
  //   Provider.of<ChatProvider>(context, listen: false).sendMessage('Tell me about: "$text"', widget.sessionIndex);
  // }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final session = provider.sessions[widget.sessionIndex];
    final theme = Theme.of(context);

    session.messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        final chatProvider = context.read<ChatProvider>();

        if (chatProvider.isTTsSpeaking) {
          chatProvider.speak("closing");
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.title.cap, style: TextStyle(fontSize: 18, color: theme.textTheme.bodyMedium!.color)),
              Text(
                session.createdAt.formatDateAndTime(),
                style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall!.color),
              ),
            ],
          ),
          elevation: 0,
          actions: [
            // IconButton(
            //   icon: Icon(Icons.summarize),
            //   onPressed: () async => showSummary(context, provider, widget.sessionIndex),
            //   tooltip: 'Summary',
            // ),

            ///TODO : IMPLEMENT VIEW PDF
            // IconButton(
            //   icon: Icon(Icons.description),
            //   onPressed: () {
            //     setState(() => _showPdfViewer = !_showPdfViewer);

            //     AnalysisLogger.logEvent("view PDF", EventDataModel(value: "Conversation Screen"));
            //   },
            //   tooltip: 'View PDF',
            // ),
            // IconButton(
            //   icon: Icon(Icons.share),
            //   onPressed: () => shareSession(context, session.shareId),
            //   tooltip: 'Share Session',
            // ),
            // IconButton(
            //   icon: Icon(Icons.download),
            //   onPressed: () => provider.exportChat(widget.sessionIndex),
            //   tooltip: 'Export Chat',
            // ),
            DropdownButton<String>(
              value: provider.selectedPersona,
              iconEnabledColor: theme.textTheme.bodyMedium!.color,
              dropdownColor: settingsProvider.isDarkMode ? Colors.black : Colors.white,
              style: theme.textTheme.bodyMedium,
              items:
                  provider.personas.keys
                      .map((p) => DropdownMenuItem(value: p, child: Text(p, style: theme.textTheme.bodyMedium)))
                      .toList(),
              onChanged: (value) {
                provider.setPersona(value!);

                AnalysisLogger.logEvent("Change Persona", EventDataModel(value: value));
              },
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              Column(
                children: [
                  // if (_showPdfViewer && session.pdfTexts.isNotEmpty)
                  //   SizedBox(
                  //     height: 250,
                  //     child: Stack(
                  //       children: [
                  //         PDFView(
                  //           filePath: session.pdfTexts.first, // Show first PDF
                  //           onPageChanged: (page, total) => setState(() => _currentPdfPage = page! - 1),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  SearchIcon(onChanged: (value) => setState(() => _searchQuery = value)),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: session.messages.length + (provider.isThinking ? 1 : 0),
                      padding: EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        if (provider.isThinking && index == 0) {
                          return thinkingBubble(theme, context);
                        }
                        // Adjust message index
                        final messageIndex = provider.isThinking ? index - 1 : index;
                        final msg = session.messages[messageIndex];
                        if (_searchQuery.isNotEmpty && !msg.text.toLowerCase().contains(_searchQuery.toLowerCase())) {
                          return SizedBox.shrink();
                        }
                        return messageBubble(context, msg, theme, _searchQuery);
                      },
                    ),
                  ),
                  // _presetQuestions(provider),
                  ChatInput(sessionIndex: widget.sessionIndex, isPDF: session.title.toLowerCase().endsWith("pdf")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _presetQuestions(ChatProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        spacing: 10,
        children: [
          presetButton('Main Idea', 'What’s the main idea?', provider, widget.sessionIndex),
          presetButton('Define', 'Define this term', provider, widget.sessionIndex),
          presetButton('Explain', 'Explain this', provider, widget.sessionIndex),
        ],
      ),
    );
  }
}
