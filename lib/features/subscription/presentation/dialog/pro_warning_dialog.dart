// lib/utils.dart
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:notte_chat/shared/style/color.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:notte_chat/core/constants.dart';
import 'package:notte_chat/core/enums/enum.dart';
import 'package:notte_chat/core/utils/analysis_logger.dart';
import 'package:notte_chat/features/subscription/presentation/provider/subscription_provider.dart';
import 'package:notte_chat/features/subscription/presentation/views/paywall_screen.dart';
import 'package:provider/provider.dart';

void showProUpgradeDialog(BuildContext context, String feature, ProFeaturesEnums unlockFeature) => showDialog(
  context: context,
  builder: (context) => ProUpgradeDialog(feature: feature, unlockFeature: unlockFeature),
);

class ProUpgradeDialog extends StatefulWidget {
  final String feature;
  final ProFeaturesEnums unlockFeature;

  const ProUpgradeDialog({super.key, required this.feature, required this.unlockFeature});

  @override
  _ProUpgradeDialogState createState() => _ProUpgradeDialogState();
}

class _ProUpgradeDialogState extends State<ProUpgradeDialog> {
  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    setState(() => _isAdLoading = true);
    RewardedAd.load(
      adUnitId: Platform.isIOS ? rewardedIOSID : rewardedAndroidId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded:
            (ad) => setState(() {
              _rewardedAd = ad;
              _isAdLoading = false;
            }),
        onAdFailedToLoad: (error) {
          setState(() => _isAdLoading = false);
          log('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  void _showRewardedAd() {
    final proProvider = Provider.of<ProProvider>(context, listen: false);
    if (!proProvider.canWatchAd) return; // Shouldn’t happen due to button disable, but safety check
    if (_rewardedAd == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ad not ready yet. Try again.')));
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => ad.dispose(),
      onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
    );
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        proProvider.unlockFeature(widget.unlockFeature);

        AnalysisLogger.logEvent("ads reward", EventDataModel(value: "Pro Dialog"));

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Feature unlocked for one-time use!')));
      },
    );
  }

  @override
  void dispose() => {_rewardedAd?.dispose(), super.dispose()};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      content: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor[900]!, primaryColor[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(20),
        child: Consumer<ProProvider>(
          builder: (context, proProvider, _) {
            final canWatchAd = proProvider.canWatchAd;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 50, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Upgrade to Pro',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 12),
                Text(
                  'Unlock "${widget.feature}" and more with NotteChat Pro!',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed:
                      () =>
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PaywallScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('Upgrade Now', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: canWatchAd && !_isAdLoading ? _showRewardedAd : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    _isAdLoading
                        ? 'Loading Ad...'
                        : canWatchAd
                        ? 'Watch Ad'
                        : 'Ad Limit Reached (${proProvider.dailyAdCount}/${proProvider.maxAdsPerDay})',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                if (!canWatchAd)
                  Text('Limit resets at midnight.', style: TextStyle(fontSize: 12, color: Colors.white70)),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Later', style: TextStyle(fontSize: 14, color: Colors.white70)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
