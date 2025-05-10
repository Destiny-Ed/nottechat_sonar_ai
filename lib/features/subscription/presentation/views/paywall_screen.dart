// lib/screens/paywall_screen.dart
import 'package:flutter/material.dart';

import 'package:notte_chat/shared/style/color.dart';
import 'package:notte_chat/core/constants.dart';
import 'package:notte_chat/core/extensions/date_extension.dart';
import 'package:notte_chat/core/utils/analysis_logger.dart';
import 'package:notte_chat/features/subscription/presentation/provider/subscription_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proProvider = Provider.of<ProProvider>(context);
    // final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor[900]!, primaryColor[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder:
                      (context, child) => Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Text(
                          'Unlock NotteChat Pro',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
                          ),
                        ),
                      ),
                ),
                SizedBox(height: 20),
                _buildFeatureTile(
                  'App-Wide Analytics',
                  'See your usage with stunning charts.',
                  Icons.analytics,
                  Colors.white,
                ),
                _buildFeatureTile(
                  'Unlimited PDFs and Word Docx',
                  'Chat across Multiple documents.',
                  Icons.picture_as_pdf,
                  Colors.white,
                ),
                _buildFeatureTile(
                  'Unlimited Conversation',
                  'Chat with Any Document, Instantly',
                  Icons.chat,
                  Colors.white,
                ),
                _buildFeatureTile('Offline Mode', 'Use NotteChat anywhere.', Icons.cloud_off, Colors.white),
                _buildFeatureTile('Voice Chat', 'Speak to your documents.', Icons.voice_chat, Colors.white),
                _buildFeatureTile('No Ads', 'Enjoy Ads Free Experience.', Icons.ads_click, Colors.white),
                SizedBox(height: 30),
                if (proProvider.availableProducts.isNotEmpty)
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder:
                        (context, child) => Transform.scale(
                          scale: _scaleAnimation.value,
                          child: ElevatedButton(
                            onPressed: () async {
                              await proProvider.purchaseProSubscription();
                              if (proProvider.isProSubscribed) {
                                AnalysisLogger.logEvent("Pro subscription", EventDataModel(value: "Paywall Screen"));
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 5,
                              shadowColor: Colors.black45,
                            ),
                            child: Text(
                              'Get Pro - ${proProvider.availableProducts.first.price}/Month'.cap,
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                  ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final url = Uri.parse(privacyPolicy);
                        if (await canLaunchUrl(url)) {
                          launchUrl(url);
                        }

                        AnalysisLogger.logEvent("launched privacy url", EventDataModel(value: "Paywall screen"));
                      },
                      child: Text('End User Policy', style: TextStyle(fontSize: 14, color: Colors.white70)),
                    ),
                    SizedBox(width: 20), //gemini-2.0-flash-exp-image-generation
                    TextButton(
                      onPressed: () async {
                        await proProvider.restorePurchases();

                        if (proProvider.isProSubscribed) {
                          AnalysisLogger.logEvent("restore purchases", EventDataModel(value: "Paywall Screen"));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Purchases restored!')));
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Restore Purchases', style: TextStyle(fontSize: 14, color: Colors.white70)),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Maybe Later', style: TextStyle(fontSize: 14, color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile(String title, String subtitle, IconData icon, Color color) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: color, size: 28),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text(subtitle, style: TextStyle(fontSize: 14, color: color.withOpacity(0.8))),
            ],
          ),
        ),
      ],
    ),
  );

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Terms of Use', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Text(
                'By subscribing to NotteChat Pro, you agree to the following terms:\n\n1. Subscription is auto-renewable at \$2.99/month.\n2. You may cancel anytime via your app store account.\n3. No refunds for partial billing periods.\n4. Use of this app is subject to our Privacy Policy.\n\n[Replace this with your actual terms and link to full policy.]',
                style: TextStyle(fontSize: 14),
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))],
          ),
    );
  }
}
