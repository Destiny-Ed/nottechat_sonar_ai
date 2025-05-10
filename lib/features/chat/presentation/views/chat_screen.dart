import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:notte_chat/core/constants.dart';
import 'package:notte_chat/core/extensions/date_extension.dart';
import 'package:notte_chat/core/utils/analysis_logger.dart';
import 'package:notte_chat/core/utils/pick_pdf.dart';
import 'package:notte_chat/core/utils/url_helper.dart';
import 'package:notte_chat/features/analysis/presentation/views/all_wide_analysis_screen.dart';
import 'package:notte_chat/features/chat/presentation/provider/chat_provider.dart';
import 'package:notte_chat/features/chat/presentation/views/conversation_screen.dart';
import 'package:notte_chat/features/chat/presentation/widgets/theme_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:notte_chat/features/settings/presentation/provider/settings_provider.dart';
import 'package:notte_chat/shared/style/color.dart';
import 'package:notte_chat/shared/widgets/busy_overlay.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatListScreen extends StatefulWidget {
  ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    AnalysisLogger.logEvent(
      "app launched",
      EventDataModel(value: "Chat Screen"),
    );
    context.read<SettingsProvider>().saveFirstTimeUser();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<ChatProvider>(
        builder: (context, provider, child) {
          return BusyOverlay(
            show: provider.isExtracting,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'NotteChat Ai',
                  style: TextStyle(color: theme.textTheme.bodyMedium!.color),
                ),
                elevation: 0,
                actions: [
                  ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      backgroundColor: WidgetStateProperty.all(primaryColor),
                    ),
                    onPressed: () async {
                      final url = Uri.parse(appWebsite);
                      if (await canLaunchUrl(url)) {
                        launchUrl(url);
                      }

                      AnalysisLogger.logEvent(
                        "view about",
                        EventDataModel(value: "Chat Screen"),
                      );
                    },
                    child: Text("About"),
                  ),
                  ThemeToggleButton(),
                  // IconButton(
                  //   icon: Icon(Provider.of<ChatProvider>(context).isOffline ? Icons.cloud_off : Icons.cloud),
                  //   onPressed: () => Provider.of<ChatProvider>(context, listen: false).toggleOfflineMode(),
                  //   tooltip: 'Toggle Offline Mode',
                  // ),
                  IconButton(
                        icon: Icon(Icons.analytics),
                        onPressed: () {
                        
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppAnalyticsScreen(),
                              ),
                            );
                          
                        },
                        tooltip: 'All Chat Analysis',
                      )
                ],
              ),
              body: Builder(
                builder: (context) {
                  if (provider.sessions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.description,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No chats yet. Upload PDFs or Word Docx to start!',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: provider.sessions.length,
                    padding: const EdgeInsets.only(top: 10, bottom: 110),
                    itemBuilder: (context, index) {
                      final session = provider.sessions[index];

                      return Dismissible(
                        key: Key(session.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 16),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          provider.deleteChat(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${session.title} deleted')),
                          );
                        },
                        child: Card(
                          color: theme.cardColor,
                          margin: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: Icon(
                              session.title.toLowerCase().endsWith("pdf")
                                  ? Icons.picture_as_pdf
                                  : Icons.library_books,
                              color: primaryColor,
                            ),
                            title: Text(
                              session.title.cap,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyMedium!.color,
                              ),
                            ),
                            subtitle: Text(
                              session.createdAt.formatDateAndTime(),
                              style: theme.textTheme.bodySmall,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          ChatScreen(sessionIndex: index),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              floatingActionButton: FloatingActionButton.extended(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                onPressed: () {
                  _showUploadDialog();
                },
                tooltip: 'Upload PDFs or Word Docx',
                label: Text("New Chat"),
                icon: Icon(Icons.add),
              ),
            ),
          );
        },
      );
  }

  void _showUploadDialog() {
    final urlController = TextEditingController();
    showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            // title: Align(
            //   alignment: Alignment.center,
            //   child: const Text('Upload Document')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    backgroundColor: WidgetStateProperty.all(secondaryColor),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _uploadLocalFile();
                  },
                  child: const Text('Upload from Device'),
                ),
                const Divider(),
                TextFormField(
                  controller: urlController,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration:   InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Paste PDF, Word, or Google Docs URL',
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                    hintText: 'https://example.com/document.pdf',
             

                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                 style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(Theme.of(context).textTheme.bodyMedium!.color),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  backgroundColor: WidgetStateProperty.all(primaryColor),
                ),
                onPressed: () async {
                  if (urlController.text.isNotEmpty) {
                    Navigator.of(context).pop(true);
                  }
                },
                child: const Text('Fetch URL'),
              ),
            ],
          ),
    ).then((bool? e) async {
      if (e == true) {
        _loadNetworkDocument(urlController.text.trim());
      }
    });
  }

  Future<void> _loadNetworkDocument(String url) async {
      context.read<ChatProvider>().isExtracting = true;

    try {
      log(url.toString());

      final doc = await UrlHelper.fetchDocumentFromUrl(url);
      log(doc.toString());
      if (doc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch document.')),
        );
        return;
      }
      final getFile = File(doc['path']);
      _processDocuments([
        PlatformFile(
          name: getFile.path.split("/").last,
          size: getFile.lengthSync(),
          path: getFile.path,
          bytes: getFile.readAsBytesSync(),
        ),
      ], isUrl: true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      context.read<ChatProvider>().isExtracting = false;
    }
  }

  Future<void> _uploadLocalFile() async {
    final pdfFiles = await pickDocuments();

    _processDocuments(pdfFiles, isUrl: false);
  }

  void _processDocuments(
    List<PlatformFile> pdfFiles, {
    required bool isUrl,
  }) async {

    final isAllDocumentAndPDFs = pdfFiles.any(
      (e) =>
          e.extension!.toLowerCase() == "pdf" ||
          e.extension!.toLowerCase() == "docx" || e.extension!.toLowerCase() == "doc",
    );
    if (!isAllDocumentAndPDFs) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Only PDFs and Word Docx files are supported")),
      );
      return;
    }
   

    if (pdfFiles.isNotEmpty && context.mounted) {
      context.read<ChatProvider>().createChatFromDocuments(pdfFiles) ;
    }

    AnalysisLogger.logEvent(
      "load pdf or docx from ${isUrl ? 'Url' : 'local'}",
      EventDataModel(value: "Chat Screen"),
    );
  }
}
