import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import '../services/ad_service.dart';

class LevelPlayBannerWidget extends StatelessWidget {
  final BannerSize size;
  final double height;

  const LevelPlayBannerWidget({
    super.key,
    this.size = BannerSize.standard,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: height,
      child: UnityBannerAd(
        placementId: AdService.bannerPlacementId,
        size: size,
        onLoad: (placementId) => debugPrint('Unity Banner loaded: $placementId'),
        onClick: (placementId) => debugPrint('Unity Banner clicked: $placementId'),
        onFailed: (placementId, error, message) =>
            debugPrint('Unity Banner failed: $placementId $error $message'),
      ),
    );
  }
}
