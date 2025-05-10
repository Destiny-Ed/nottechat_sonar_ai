import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:notte_chat/core/constants.dart';
import 'dart:convert';
import 'package:notte_chat/core/utils/analysis_logger.dart';
import 'package:notte_chat/features/chat/data/model/sonar_response_model.dart';

class SonarService {
  Future<String?> queryDocument(
    String userQuery
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.perplexity.ai/chat/completions'),
        headers: {
          'Authorization': 'Bearer $sonarApiKey',
          'content-type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode({
          "model": "sonar-pro",
          "messages": [
            {"role": "system", "content": "Be precise and concise."},
            {
              "role": "user",
              "content": userQuery,
            },
          ],
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Sonar API error: ${response.statusCode}');
      }

      final data = SonarResponse.fromJson(jsonDecode(response.body));
      log("sonar response :: ${data.toJson()}");
      final answer = data.choices.first.message.content;

      AnalysisLogger.logEvent(
        'sonar_query',
        EventDataModel(value: answer.toString()),
      );
      return answer.isEmpty ? "No response found" : answer;
    } catch (e) {
      AnalysisLogger.logEvent(
        'sonar_error',
        EventDataModel(value: e.toString()),
      );
      throw Exception('Error querying Sonar API: $e');
    }
  }
}
