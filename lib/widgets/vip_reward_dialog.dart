import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import '../services/ad_service.dart';

class VipRewardDialog extends StatefulWidget {
  const VipRewardDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const VipRewardDialog(),
    );
  }

  @override
  State<VipRewardDialog> createState() => _VipRewardDialogState();
}

class _VipRewardDialogState extends State<VipRewardDialog> {
  Duration _remaining = Duration.zero;
  Timer? _timer;
  bool _isLoadingAd = false;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingTime();
    });
  }

  Future<void> _updateRemainingTime() async {
    final remaining = await AdService().getVipRemainingDuration();
    if (mounted) {
      setState(() {
        _remaining = remaining;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d <= Duration.zero) return "00:00:00";
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  Future<void> _watchAd() async {
    setState(() {
      _isLoadingAd = true;
    });

    final isTr = AppLocalizations.of(context)?.localeName == 'tr';
    final isDe = AppLocalizations.of(context)?.localeName == 'de';

    await AdService().showRewardedAd(
      onReward: () async {
        await _updateRemainingTime();
        if (mounted) {
          final thankYouMsg = isTr
              ? 'Teşekkürler! 24 saatlik tam ve ücretsiz kullanım süreniz tanımlandı.'
              : (isDe
                  ? 'Vielen Dank! 24 Stunden volle und kostenlose Nutzung wurden freigeschaltet.'
                  : 'Thank you! 24 hours of full and free access has been granted.');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      thankYouMsg,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF4F46E5),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      onAdNotReady: () {
        if (mounted) {
          final errorMsg = isTr
              ? 'Reklam şu anda yüklenemedi. Lütfen internet bağlantınızı kontrol edip birkaç saniye sonra tekrar deneyin.'
              : (isDe
                  ? 'Die Werbung konnte nicht geladen werden. Bitte versuchen Sie es in wenigen Sekunden erneut.'
                  : 'Ad is currently unavailable. Please check your internet connection and try again in a few seconds.');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(errorMsg)),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
    );

    if (mounted) {
      setState(() {
        _isLoadingAd = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTr = AppLocalizations.of(context)?.localeName == 'tr';
    final isDe = AppLocalizations.of(context)?.localeName == 'de';

    final title = isTr
        ? 'İzle & Kullan (24 Saat Ücretsiz)'
        : (isDe ? 'Ansehen & Nutzen (24 Std Gratis)' : 'Watch & Use (24h Free Access)');

    final description = isTr
        ? 'Aşağıdaki butona tıklayarak kısa bir ödüllü reklam izleyin ve 24 saat boyunca tüm PDF araçlarını tam ve sınırsız ücretsiz kullanın! Süre bitse dahi istediğiniz zaman tekrar izleyip sürenizi uzatabilir ve bize destek olabilirsiniz.'
        : (isDe
            ? 'Klicken Sie auf die Schaltfläche unten, um ein kurzes Belohnungsvideo anzusehen und 24 Stunden lang alle PDF-Werkzeuge uneingeschränkt kostenlos zu nutzen! Sie können jederzeit erneut ansehen, um zu verlängern und uns zu unterstützen.'
            : 'Watch a short rewarded ad to unlock 24 hours of full, unlimited and free access to all PDF tools! You can watch again anytime to extend your time or support us.');

    final watchBtnText = isTr
        ? 'İzle & Kullan (+24 Saat Ücretsiz)'
        : (isDe ? 'Ansehen & Nutzen (+24 Std Gratis)' : 'Watch & Use (+24 Hours Free)');

    final remainingLabel = isTr
        ? 'Kalan Ücretsiz Kullanım Süresi:'
        : (isDe ? 'Verbleibende kostenlose Nutzungszeit:' : 'Remaining Free Usage Time:');

    final isVipActive = _remaining > Duration.zero;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gold Star Header Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withAlpha(100),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),

            // Live Countdown Timer Box (visible when active or inactive)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: isVipActive
                    ? const Color(0xFF10B981).withAlpha(30)
                    : Colors.amber.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isVipActive
                      ? const Color(0xFF10B981).withAlpha(120)
                      : Colors.amber.withAlpha(120),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isVipActive ? Icons.timer : Icons.hourglass_empty_rounded,
                        size: 20,
                        color: isVipActive ? const Color(0xFF10B981) : Colors.amber[800],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        remainingLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isVipActive ? const Color(0xFF10B981) : Colors.amber[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDuration(_remaining),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: isVipActive
                          ? const Color(0xFF10B981)
                          : (Theme.of(context).brightness == Brightness.dark
                              ? Colors.amber[300]
                              : Colors.amber[900]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ALWAYS Clickable Rewarded Ad Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoadingAd ? null : _watchAd,
                icon: _isLoadingAd
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_circle_fill_rounded, size: 24),
                label: Text(
                  watchBtnText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF8B5CF6).withAlpha(120),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isTr ? 'Kapat' : (isDe ? 'Schließen' : 'Close'),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
