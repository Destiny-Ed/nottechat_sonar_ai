// lib/screens/app_analytics_screen.dart
import 'package:flutter/material.dart';

import 'package:notte_chat/shared/style/color.dart';
import 'package:notte_chat/core/utils/analysis_logger.dart';
import 'package:notte_chat/features/analysis/presentation/widgets/chart_widget.dart';
import 'package:notte_chat/features/analysis/presentation/widgets/stats_widget.dart';
import 'package:notte_chat/features/chat/data/model/chat_model.dart';
import 'package:notte_chat/features/chat/presentation/provider/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AppAnalyticsScreen extends StatefulWidget {
  const AppAnalyticsScreen({super.key});

  @override
  State<AppAnalyticsScreen> createState() => _AppAnalyticsScreenState();
}

class _AppAnalyticsScreenState extends State<AppAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    AnalysisLogger.logEvent("view analysis", EventDataModel(value: "Analysis Screen"));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);
    final theme = Theme.of(context);

    // Aggregate app-wide data
    final allMessages = provider.sessions.expand((s) => s.messages).toList();
    final totalMessages = allMessages.length;
    final userMessages = allMessages.where((m) => m.isUser).length;
    final aiMessages = totalMessages - userMessages;
    final audioMessages = allMessages.where((m) => m.isAudio).length;
    final sessionCount = provider.sessions.length;
    final totalChatDuration =
        allMessages.isNotEmpty ? allMessages.last.createdAt.difference(provider.sessions.first.createdAt).inHours : 0;
    final wordFreq = _calculateWordFrequency(allMessages);
    final messagesPerDay = _messagesPerDay(allMessages);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NotteChat Analytics',
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyMedium!.color),
        ),
        elevation: 0,
      ),
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [theme.primaryColor.withOpacity(0.1), Colors.white],
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //   ),
        // ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCard(
                context,
                totalMessages,
                userMessages,
                aiMessages,
                audioMessages,
                sessionCount,
                totalChatDuration,
                theme,
              ),
              _buildChartSection('Messages Over Time', buildLineChart(messagesPerDay, theme), theme),
              _buildChartSection('Top Keywords', buildBarChart(wordFreq, theme), theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    int totalMessages,
    int userMessages,
    int aiMessages,
    int audioMessages,
    int sessionCount,
    int totalChatDuration,
    ThemeData theme,
  ) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          spacing: 20,
          children: [
            Text('Overview', style: theme.textTheme.headlineMedium),
            SizedBox(
              height: 200,
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                children: [
                  buildStatTile(context, 'Total Messages', totalMessages, Icons.message, primaryColor),
                  buildStatTile(context, 'Sessions', sessionCount, Icons.chat, Colors.green),
                  buildStatTile(context, 'You', userMessages, Icons.person, secondaryColor),
                  buildStatTile(context, 'AI', aiMessages, Icons.smart_toy, Colors.purple),
                  buildStatTile(context, 'Audio', audioMessages, Icons.mic, Colors.red),
                  buildStatTile(context, 'Hours', totalChatDuration, Icons.timer, Colors.teal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(String title, Widget chart, ThemeData theme) {
    return Card(
      elevation: 8,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: theme.textTheme.headlineMedium),
            SizedBox(height: 16),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Map<String, int> _messagesPerDay(List<ChatMessage> messages) {
    final dayCounts = <String, int>{};
    for (var msg in messages) {
      final day = DateFormat('MM/dd').format(msg.createdAt); // e.g., "04/09"
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }
    return Map.fromEntries(dayCounts.entries.toList()..sort((a, b) => a.key.compareTo(b.key))); // Sort by date
  }

  Map<String, int> _calculateWordFrequency(List<ChatMessage> messages) {
    final wordMap = <String, int>{};
    final stopWords = {'the', 'a', 'an', 'and', 'or', 'to', 'in', 'is', 'of'};
    for (var msg in messages) {
      final words =
          msg.text.toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty && !stopWords.contains(w)).toList();
      for (var word in words) wordMap[word] = (wordMap[word] ?? 0) + 1;
    }
    return Map.fromEntries(wordMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }
}
