# Unity LevelPlay Reklam Entegrasyonu ve 24 Saatlik Ücretsiz Kullanım Mimarisi Rehberi

Bu doküman, Flutter uygulamalarınızda Unity LevelPlay (IronSource) SDK'sı kullanarak ödüllü reklam (Rewarded), geçiş reklamı (Interstitial) ve banner reklamı (Banner) mimarisinin nasıl kurulacağını ve yönetileceğini adım adım açıklamaktadır.

---

## 1. Paket Gereksinimleri (`pubspec.yaml`)

Projenize aşağıdaki paketleri ekleyin:

```yaml
dependencies:
  flutter:
    sdk: flutter
  unity_levelplay_mediation: ^9.2.0  # Unity LevelPlay SDK
  shared_preferences: ^2.3.3          # 24 saatlik VIP süresini yerel hafızada tutmak için
```

---

## 2. Unity LevelPlay Servisi (`lib/services/ad_service.dart`)

Reklamların başlatılması, yüklenmesi ve 24 saatlik VIP/Ücretsiz erişim süresinin SharedPreferences ile kontrol edilmesini sağlayan singleton servis yapısı:

```dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';

class AdService with LevelPlayInitListener {
  // Unity Dashboard -> App Key ve Placement ID'leriniz
  static const String appKey = '800274669';
  static const String rewardedPlacementId = 'Rewarded_Android';
  static const String interstitialPlacementId = 'Interstitial_Android';
  static const String bannerPlacementId = 'Banner_Android';

  static const String _vipExpiryKey = 'vip_expires_at_ms';

  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  bool _isRewardedReady = false;
  bool _isInterstitialReady = false;

  LevelPlayRewardedAd? _rewardedAd;
  LevelPlayInterstitialAd? _interstitialAd;

  Future<void> initialize() async {
    if (kIsWeb || _isInitialized) return;
    try {
      final initRequest = LevelPlayInitRequest.builder(appKey).build();
      await LevelPlay.init(initRequest: initRequest, initListener: this);
    } catch (e) {
      debugPrint("Unity LevelPlay init error: $e");
    }
  }

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {
    _isInitialized = true;
    _initRewardedAd();
    _initInterstitialAd();
  }

  @override
  void onInitFailed(LevelPlayInitError error) {}

  void _initRewardedAd() {
    if (kIsWeb) return;
    try {
      final listener = _RewardedAdListener(
        onLoaded: () => _isRewardedReady = true,
        onFailed: () => _isRewardedReady = false,
        onClosed: () {
          _isRewardedReady = false;
          _rewardedAd?.loadAd();
        },
        onRewarded: () {
          addVip24Hours();
        },
      );

      _rewardedAd = LevelPlayRewardedAd(adUnitId: rewardedPlacementId);
      _rewardedAd?.setListener(listener);
      _rewardedAd?.loadAd();
    } catch (e) {
      debugPrint("Rewarded Ad Init error: $e");
    }
  }

  void _initInterstitialAd() {
    if (kIsWeb) return;
    try {
      final listener = _InterstitialAdListener(
        onLoaded: () => _isInterstitialReady = true,
        onFailed: () => _isInterstitialReady = false,
        onClosed: () {
          _isInterstitialReady = false;
          _interstitialAd?.loadAd();
        },
      );

      _interstitialAd = LevelPlayInterstitialAd(adUnitId: interstitialPlacementId);
      _interstitialAd?.setListener(listener);
      _interstitialAd?.loadAd();
    } catch (e) {
      debugPrint("Interstitial Ad Init error: $e");
    }
  }

  Future<void> showRewardedAd({required Function() onReward}) async {
    if (kIsWeb) {
      await addVip24Hours();
      onReward();
      return;
    }

    if (_rewardedAd != null && await _rewardedAd!.isAdReady()) {
      _rewardedAd!.showAd();
      onReward();
    } else {
      _rewardedAd?.loadAd();
      await addVip24Hours();
      onReward();
    }
  }

  Future<void> showInterstitialAd() async {
    if (kIsWeb) return;
    if (_interstitialAd != null && await _interstitialAd!.isAdReady()) {
      _interstitialAd!.showAd();
    } else {
      _interstitialAd?.loadAd();
    }
  }

  // --- 24 Saatlik VIP Kontrolü ---
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

    await prefs.setInt(_vipExpiryKey, newExpiryMs);
  }
}

class _RewardedAdListener with LevelPlayRewardedAdListener {
  final VoidCallback onLoaded;
  final VoidCallback onFailed;
  final VoidCallback onClosed;
  final VoidCallback onRewarded;

  _RewardedAdListener({
    required this.onLoaded,
    required this.onFailed,
    required this.onClosed,
    required this.onRewarded,
  });

  @override
  void onAdAdRewarded(LevelPlayReward reward, LevelPlayAdInfo adInfo) => onRewarded();
  @override
  void onAdClosed(LevelPlayAdInfo adInfo) => onClosed();
  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) => onLoaded();
  @override
  void onAdLoadFailed(LevelPlayAdError error) => onFailed();
  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {}
  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {}
  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) {}
  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {}
}

class _InterstitialAdListener with LevelPlayInterstitialAdListener {
  final VoidCallback onLoaded;
  final VoidCallback onFailed;
  final VoidCallback onClosed;

  _InterstitialAdListener({
    required this.onLoaded,
    required this.onFailed,
    required this.onClosed,
  });

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) => onClosed();
  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) => onLoaded();
  @override
  void onAdLoadFailed(LevelPlayAdError error) => onFailed();
  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {}
  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {}
  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) {}
  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {}
}
```

---

## 3. Banner Reklam Bileşeni (`lib/widgets/levelplay_banner_widget.dart`)

Uygulamanızın her sayfasına (bottom navigation yukarısına, sayfa altlarına vb.) rahatsız etmeyecek şekilde eklenebilecek Banner bileşeni:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import '../services/ad_service.dart';

class LevelPlayBannerWidget extends StatefulWidget {
  final LevelPlayAdSize? adSize;
  final double height;

  const LevelPlayBannerWidget({
    super.key,
    this.adSize,
    this.height = 50.0,
  });

  @override
  State<LevelPlayBannerWidget> createState() => _LevelPlayBannerWidgetState();
}

class _LevelPlayBannerWidgetState extends State<LevelPlayBannerWidget>
    with LevelPlayBannerAdViewListener {
  final GlobalKey<LevelPlayBannerAdViewState> _bannerKey = GlobalKey();
  bool _isAdLoaded = false;

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    if (mounted) setState(() => _isAdLoaded = true);
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {}
  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {}
  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {}
  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) {}
  @override
  void onAdCollapsed(LevelPlayAdInfo adInfo) {}
  @override
  void onAdExpanded(LevelPlayAdInfo adInfo) {}
  @override
  void onAdLeftApplication(LevelPlayAdInfo adInfo) {}

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: widget.height,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          LevelPlayBannerAdView(
            key: _bannerKey,
            adUnitId: AdService.bannerPlacementId,
            adSize: widget.adSize ?? LevelPlayAdSize.BANNER,
            listener: this,
            onPlatformViewCreated: () {
              _bannerKey.currentState?.loadAd();
            },
          ),
          if (!_isAdLoaded)
            Container(
              height: widget.height,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.grey[200],
              child: const Center(
                child: Text("ADVERTISEMENT", style: TextStyle(fontSize: 11, color: Colors.grey)),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

## 4. Başlık Çubuğu (AppBar) ve Kırmızı Nokta Mantığı (`lib/app.dart`)

`AppBar` alanında altın sarısı yıldız ikonu yer alır. Süre bittiğinde (VIP pasifleştiğinde) yıldızın sağ üst köşesine kırmızı nokta gösterilir:

```dart
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isVipActive = true;
  Timer? _vipTimer;

  @override
  void initState() {
    super.initState();
    _checkVipStatus();
    // 5 saniyede bir VIP süresini ve durumunu kontrol eder
    _vipTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkVipStatus());
  }

  Future<void> _checkVipStatus() async {
    final active = await AdService().isVipActive();
    if (mounted && active != _isVipActive) {
      setState(() {
        _isVipActive = active;
      });
    }
  }

  @override
  void dispose() {
    _vipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uygulama Başlığı'),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 28,
                ),
                // Süre bittiğinde çıkan Kırmızı İndikatör Nokta
                if (!_isVipActive)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: '24 Saat Ücretsiz Kullanım',
            onPressed: () async {
              await VipRewardDialog.show(context);
              _checkVipStatus();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Expanded(child: Center(child: Text("Sayfa İçeriği"))),
          
          // Her sayfanın en altına eklenen Banner Reklam
          const LevelPlayBannerWidget(height: 50),
        ],
      ),
    );
  }
}
```

---

## 5. Ödüllü Reklam Dialog Penceresi (`lib/widgets/vip_reward_dialog.dart`)

Yıldıza tıklandığında açılan, kalan süreyi canlı gösteren ve istenildiği zaman "Ücretsiz Kullan (+24 Saat)" butonuna basılarak sürenin uzatılmasını sağlayan diyalog:

- **Canlı Geri Sayım**: `_formatDuration` ile `HH:MM:SS` formatında kalan VIP süresi dinamik gösterilir.
- **Süre Ekleme**: Reklam izlendiğinde var olan sürenin üzerine +24 saat eklenir. Süre bitmişse şu andan itibaren 24 saat başlatılır.

---

## Technical Summary / Teknik Kimlikler

- **SDK**: Unity LevelPlay Mediation
- **App Key**: `800274669`
- **Rewarded Placement**: `Rewarded_Android`
- **Interstitial Placement**: `Interstitial_Android`
- **Banner Placement**: `Banner_Android`
