import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class AdService {
  static final AdService instance = AdService._internal();
  factory AdService() => instance;
  AdService._internal();

  bool _initialized = false;
  final ValueNotifier<bool> isInitializedNotifier = ValueNotifier<bool>(false);

  // Unity Ads Configuration for PDF Tools: Merge, Split, Edit
  static const String androidGameId = '800274669';
  static const String iosGameId = '800274669';
  static const String organizationCoreId = '9072401080631';

  static const String bannerPlacementId = 'Banner_Android';
  static const String interstitialPlacementId = 'Interstitial_Android';
  static const String rewardedPlacementId = 'Rewarded_Android';

  static const String _vipExpiryKey = 'vip_expires_at_ms';

  bool get isInitialized => _initialized;

  Future<void> initialize() => init();

  Future<void> init() async {
    if (kIsWeb || _initialized) return;

    try {
      final gameId = defaultTargetPlatform == TargetPlatform.iOS
          ? iosGameId
          : androidGameId;

      await UnityAds.init(
        gameId: gameId,
        testMode: kDebugMode,
        onComplete: () {
          _initialized = true;
          isInitializedNotifier.value = true;
          debugPrint('Unity Ads initialized successfully for PDF Toolkit.');
          _loadAds();
        },
        onFailed: (error, message) {
          debugPrint('Unity Ads initialization failed: $error - $message');
        },
      );
    } catch (e) {
      debugPrint('AdService init error: $e');
    }
  }

  void _loadAds() {
    if (kIsWeb) return;
    try {
      UnityAds.load(
        placementId: interstitialPlacementId,
        onComplete: (placementId) => debugPrint('Loaded interstitial: $placementId'),
        onFailed: (placementId, error, message) =>
            debugPrint('Failed to load interstitial $placementId: $error - $message'),
      );

      UnityAds.load(
        placementId: rewardedPlacementId,
        onComplete: (placementId) => debugPrint('Loaded rewarded: $placementId'),
        onFailed: (placementId, error, message) =>
            debugPrint('Failed to load rewarded $placementId: $error - $message'),
      );
    } catch (e) {
      debugPrint('AdService load error: $e');
    }
  }

  /// Shows rewarded video ad. Upon completion, grants 24h VIP and calls onReward.
  Future<void> showRewardedAd({
    required VoidCallback onReward,
    VoidCallback? onAdNotReady,
  }) async {
    if (kIsWeb) {
      await addVip24Hours();
      onReward();
      return;
    }

    if (!_initialized) {
      // If offline/uninitialized fallback gracefully
      await addVip24Hours();
      onReward();
      return;
    }

    UnityAds.showVideoAd(
      placementId: rewardedPlacementId,
      onComplete: (placementId) async {
        debugPrint('Rewarded ad completed: $placementId');
        await addVip24Hours();
        onReward();
        _loadAds();
      },
      onFailed: (placementId, error, message) {
        debugPrint('Rewarded ad failed: $error - $message');
        onAdNotReady?.call();
        _loadAds();
      },
      onSkipped: (placementId) {
        debugPrint('Rewarded ad skipped: $placementId');
        onAdNotReady?.call();
        _loadAds();
      },
    );
  }

  /// Shows interstitial ad if ready.
  void showInterstitialAd({VoidCallback? onAdClosed}) {
    if (kIsWeb || !_initialized) {
      onAdClosed?.call();
      return;
    }

    UnityAds.showVideoAd(
      placementId: interstitialPlacementId,
      onComplete: (placementId) {
        debugPrint('Interstitial completed: $placementId');
        _loadAds();
        onAdClosed?.call();
      },
      onFailed: (placementId, error, message) {
        debugPrint('Interstitial failed: $error - $message');
        onAdClosed?.call();
      },
      onStart: (placementId) => debugPrint('Interstitial start: $placementId'),
      onClick: (placementId) => debugPrint('Interstitial click: $placementId'),
      onSkipped: (placementId) {
        debugPrint('Interstitial skipped: $placementId');
        _loadAds();
        onAdClosed?.call();
      },
    );
  }

  // --- 24-Hour VIP Timer Management ---
  Future<bool> isVipActive() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryMs = prefs.getInt(_vipExpiryKey) ?? 0;
    return DateTime.now().millisecondsSinceEpoch < expiryMs;
  }

  Future<Duration> getVipRemainingDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryMs = prefs.getInt(_vipExpiryKey) ?? 0;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (expiryMs <= nowMs) return Duration.zero;
    return Duration(milliseconds: expiryMs - nowMs);
  }

  Future<void> addVip24Hours() async {
    final prefs = await SharedPreferences.getInstance();
    final currentExpiryMs = prefs.getInt(_vipExpiryKey) ?? 0;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    int newExpiryMs;
    if (currentExpiryMs > nowMs) {
      newExpiryMs = currentExpiryMs + (24 * 60 * 60 * 1000);
    } else {
      newExpiryMs = nowMs + (24 * 60 * 60 * 1000);
    }

    // Maximum cap of 48 hours to ensure users can check in every 1-2 days
    final maxExpiryMs = nowMs + (48 * 60 * 60 * 1000);
    if (newExpiryMs > maxExpiryMs) {
      newExpiryMs = maxExpiryMs;
    }

    await prefs.setInt(_vipExpiryKey, newExpiryMs);
    debugPrint("VIP status updated until: ${DateTime.fromMillisecondsSinceEpoch(newExpiryMs)}");
  }
}
