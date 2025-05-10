// lib/helpers/dbHelper_factory.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:notte_chat/features/chat/data/repo/db_helper.dart';
import 'package:notte_chat/features/chat/data/repo/db_helper_interface.dart';
import 'package:notte_chat/features/chat/data/repo/db_web_helper.dart';

DBHelperInterface getDBHelper() => (kIsWeb) ? DBHelperWeb() : DBHelper();
