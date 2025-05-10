import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:notte_chat/features/chat/data/repo/db_helper_factory.dart';
import 'package:notte_chat/features/chat/presentation/provider/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:notte_chat/features/settings/presentation/provider/settings_provider.dart';
import 'package:notte_chat/features/onboarding/presentations/views/splash_screen.dart';
import 'package:notte_chat/features/subscription/presentation/provider/subscription_provider.dart';
import 'package:notte_chat/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  if (kIsWeb) {
    _initApp();
  } else {
    runZonedGuarded<Future<void>>(() async {
      _initApp();
    }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
  }
}

_initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final dbHelper = getDBHelper();
  await dbHelper.init();
  // The following lines are the same as previously explained in "Handling uncaught errors"
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NotteChat',
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            scaffoldBackgroundColor: Colors.grey[100],
            cardColor: Colors.white,
            appBarTheme: AppBarTheme(backgroundColor: Colors.white, iconTheme: IconThemeData(color: Colors.black)),
            textTheme: TextTheme(
              bodyMedium: TextStyle(color: Colors.black87),
              headlineMedium: TextStyle(color: Colors.black87),
              bodySmall: TextStyle(color: Colors.grey[600]),
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.indigo,
            scaffoldBackgroundColor: Colors.grey[900],
            cardColor: Colors.grey[800],
            appBarTheme: AppBarTheme(backgroundColor: Colors.grey[800], iconTheme: IconThemeData(color: Colors.white)),
            textTheme: TextTheme(
              bodyMedium: TextStyle(color: Colors.white),
              headlineMedium: TextStyle(color: Colors.white),
              bodySmall: TextStyle(color: Colors.grey[400]),
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: SplashScreen(),
        );
      },
    );
  }
}
