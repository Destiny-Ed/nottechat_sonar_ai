import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:notte_chat/core/constants.dart';
import 'package:notte_chat/features/subscription/presentation/provider/subscription_provider.dart';
import 'package:notte_chat/features/subscription/presentation/views/paywall_screen.dart';
import 'package:provider/provider.dart';

class AdsWidget extends StatefulWidget {
  const AdsWidget({super.key});

  @override
  _AdsWidgetState createState() => _AdsWidgetState();
}

class _AdsWidgetState extends State<AdsWidget> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    loadAd();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_bannerAd == null) return SizedBox();
    if (_bannerAd != null && context.watch<ProProvider>().isProSubscribed) return SizedBox();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.textTheme.bodyMedium!.color!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          // spacing: 5,
          children: [
            Expanded(
              child: SizedBox(width: MediaQuery.of(context).size.width, height: 50, child: AdWidget(ad: _bannerAd!)),
            ),

            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PaywallScreen()));
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(Icons.cancel, color: theme.textTheme.bodySmall!.color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BannerAd? _bannerAd;

  /// Loads a banner ad.
  void loadAd() async {
    _bannerAd = BannerAd(
      adUnitId: Platform.isIOS ? bannerIOSID : bannerAndroidId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(),
    )..load();
  }
}
