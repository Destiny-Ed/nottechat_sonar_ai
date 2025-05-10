import 'dart:async';

import 'package:advanced_in_app_review/advanced_in_app_review.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:notte_chat/features/chat/presentation/views/chat_screen.dart';
import 'package:notte_chat/features/onboarding/presentations/views/onboarding_screen.dart';
import 'package:notte_chat/features/settings/presentation/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    navigate();

    unawaited(AppTrackingTransparency.requestTrackingAuthorization());

    AdvancedInAppReview()
        .setMinDaysBeforeRemind(2)
        .setMinDaysAfterInstall(1)
        .setMinLaunchTimes(2)
        .setMinSecondsBeforeShowDialog(4)
        .monitor();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset("assets/nottechat_logo.png", width: 150)));
  }

  void navigate() {
    Future.delayed(const Duration(seconds: 3), () {
      if (context.read<SettingsProvider>().isFirstTimeUser) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OnboardingScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatListScreen()));
      }
    });
  }
}
