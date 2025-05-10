import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:notte_chat/core/enums/enum.dart';
import 'package:notte_chat/features/chat/data/model/chat_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ProProvider extends ChangeNotifier {
  bool _isProSubscribed = false;
  final InAppPurchase _iap = InAppPurchase.instance;
  static const String _proSubscriptionId = 'nottechat_pro_monthly';
  bool _isOffline = false;
  ProFeaturesEnums? _unlockedFeature;
  int _dailyAdCount = 0; // Tracks ads watched today
  DateTime? _lastAdDate; // Date of last ad watch
  final int maxAdsPerDay = 5; // Daily limit
  List<ProductDetails> availableProducts = [];
  List<ProductDetails> freeAvailableProducts = [];

  bool get isProSubscribed => _isProSubscribed;
  bool get isOffline => _isOffline;
  ProFeaturesEnums? get unlockedFeature => _unlockedFeature;
  int get dailyAdCount => _dailyAdCount;
  bool get canWatchAd => _dailyAdCount < maxAdsPerDay || (!_isSameDay(_lastAdDate!, DateTime.now()));

  ProProvider() {
    _initSubscription();
    // _loadOfflineMode();
    _loadAdCount(); // Load ad tracking
  }

  Future<void> _initSubscription() async {
    log("initializing subscription");
    final bool isAvailable = await _iap.isAvailable();
    if (!isAvailable) return;
    final ProductDetailsResponse response = await _iap.queryProductDetails({_proSubscriptionId});
    for (var i in response.productDetails) {
      if (i.price.toLowerCase() == "free") {
        if (!freeAvailableProducts.any((item) => item.id == i.id)) {
          freeAvailableProducts.add(i);
        }
      } else {
        if (!availableProducts.any((item) => item.id == i.id)) {
          availableProducts.add(i);
        }
      }
      log("products details :::: ${i.title} : ${i.id} ::: ${i.price}");
    }
    if (availableProducts.isNotEmpty) {
      _iap.purchaseStream.listen((purchases) => _handlePurchases(purchases));
      _checkSubscriptionStatus();

      notifyListeners();

      unawaited(restorePurchases());
    }
  }

  ProductDetails _getFreeProductDetails() {
    late ProductDetails productDetails;

    final selectedProductDetails = availableProducts.first;

    if (freeAvailableProducts.isEmpty) return selectedProductDetails;

    for (var i in freeAvailableProducts) {
      if (selectedProductDetails.id == i.id) {
        productDetails = i;
      } else {
        productDetails = selectedProductDetails;
      }
    }
    return productDetails;
  }

  Future<void> _checkSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isProSubscribed = prefs.getBool('isProSubscribed') ?? false;
    notifyListeners();
  }

  Future<void> purchaseProSubscription() async {
    if (kIsWeb) {
      await _handleWebPurchase();
    } else {
      //mobile
      final ProductDetailsResponse response = await _iap.queryProductDetails({_proSubscriptionId});
      if (response.productDetails.isNotEmpty) {
        final purchaseParam = PurchaseParam(productDetails: _getFreeProductDetails());
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }
    }
  }

  Future<void> _handleWebPurchase() async {
    //TODO: IMPLEMENT WEB CHECKOUT SUPPORT with Stripe or Another
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('isProSubscribed', true);
    _isProSubscribed = true;
    notifyListeners();
  }

  Future<void> restorePurchases() async => await _iap.restorePurchases();

  void _handlePurchases(List<PurchaseDetails> purchases) async {
    final prefs = await SharedPreferences.getInstance();

    for (var purchase in purchases) {
      log(purchase.status.toString());
      if (purchase.productID == _proSubscriptionId &&
          (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored)) {
        await prefs.setBool('isProSubscribed', true);
        _isProSubscribed = true;
        if (purchase.pendingCompletePurchase) await _iap.completePurchase(purchase);
        notifyListeners();
      }

      if (purchase.status == PurchaseStatus.canceled) {
        await prefs.setBool('isProSubscribed', false);
        _isProSubscribed = false;
        notifyListeners();
      }
    }
  }

  Future<void> exportChat(List<ChatMessage> messages, int sessionId) async {
    if (!_isProSubscribed && _unlockedFeature != ProFeaturesEnums.exportChat) {
      throw Exception('Upgrade to Pro to export chats!');
    }

    final dir = await getExternalStorageDirectory();
    final file = File('`({dir!.path}/nottechat_)`sessionId.txt');
    String content = messages
        .map((m) => '`({m.isUser ? "You" : "AI"} ()`{DateFormat("h:mm a").format(m.createdAt)}): ${m.text}')
        .join('\n');
    await file.writeAsString(content);
    clearUnlockedFeature();
  }

  // Future<void> toggleOfflineMode() async {
  //   if (!_isProSubscribed && _unlockedFeature != ProFeaturesEnums.offline) {
  //     throw Exception('Upgrade to Pro for offline mode!');
  //   }
  //   _isOffline = !_isOffline;
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('isOffline', _isOffline);
  //   if (_unlockedFeature == ProFeaturesEnums.offline) clearUnlockedFeature();
  //   notifyListeners();
  // }

  // Future<void> _loadOfflineMode() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   _isOffline = prefs.getBool('isOffline') ?? false;
  //   notifyListeners();
  // }

  void unlockFeature(ProFeaturesEnums feature) {
    _unlockedFeature = feature;
    _incrementAdCount(); // Increment after ad watch
    notifyListeners();
  }

  void clearUnlockedFeature() {
    _unlockedFeature = null;
    notifyListeners();
  }

  Future<void> _loadAdCount() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAdDateStr = prefs.getString('lastAdDate');
    _dailyAdCount = prefs.getInt('dailyAdCount') ?? 0;
    _lastAdDate = lastAdDateStr != null ? DateTime.parse(lastAdDateStr) : null;
    if (!_isSameDay(_lastAdDate, DateTime.now())) _resetAdCount(); // Reset if new day
    notifyListeners();
  }

  Future<void> _incrementAdCount() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    if (!_isSameDay(_lastAdDate!, now)) _resetAdCount(); // Reset if new day
    _dailyAdCount = _dailyAdCount + 1;
    _lastAdDate = now;
    await prefs.setInt('dailyAdCount', _dailyAdCount);
    await prefs.setString('lastAdDate', now.toIso8601String());
    notifyListeners();
  }

  Future<void> _resetAdCount() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyAdCount = 0;
    await prefs.setInt('dailyAdCount', 0);
    notifyListeners();
  }

  bool _isSameDay(DateTime? date1, DateTime date2) {
    if (date1 == null) return false;
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}
