import 'dart:developer';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:notte_chat/core/extensions/date_extension.dart';

class AnalysisLogger {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static Future<void> logEvent(String name, EventDataModel parameter) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: name, parameters: parameter.toJson());
    } catch (e) {
      log("Error logging event $e");
    }
  }
}

class EventDataModel {
  String value;

  EventDataModel({required this.value});

  Map<String, Object> toJson() => {
    "value": value,
    "time": DateTime.now().formatDateAndTime(),
    "platform": Platform.operatingSystem,
  };
}
