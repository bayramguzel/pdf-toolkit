import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'l10n/app_localizations.dart';
import 'app.dart';
import 'providers/app_state.dart';
import 'providers/settings_provider.dart';
import 'widgets/video_splash_screen.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService().initialize();

  // Set system UI overlay style only on mobile
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        // iOS uses the inverse semantics: dark background => light icons.
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  // Check for incoming intent BEFORE showing splash.
  // If the app was opened by tapping a PDF file, skip splash entirely.
  String? incomingFilePath;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    try {
      final initialMedia =
          await ReceiveSharingIntent.instance.getInitialMedia();
      if (initialMedia.isNotEmpty) {
        incomingFilePath = initialMedia.first.path;
      }
    } catch (_) {
      // If intent check fails, proceed normally
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: SplashWrapper(incomingFilePath: incomingFilePath),
    ),
  );
}

class SplashWrapper extends StatefulWidget {
  /// If non-null, the app was launched by opening a PDF file externally.
  /// Splash will be skipped and this file will be opened directly.
  final String? incomingFilePath;

  const SplashWrapper({super.key, this.incomingFilePath});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showSplash = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkSplash();
  }

  Future<void> _checkSplash() async {
    // Skip splash on web
    if (kIsWeb) {
      setState(() {
        _showSplash = false;
        _initialized = true;
      });
      return;
    }

    // Skip splash when app is opened via an external file intent
    if (widget.incomingFilePath != null) {
      setState(() {
        _showSplash = false;
        _initialized = true;
      });
      return;
    }

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final now = DateTime.now();
    final today = "${now.year}-${now.month}-${now.day}";

    if (settings.lastSplashDate == today) {
      _showSplash = false;
    } else {
      await settings.setLastSplashDate(today);
      _showSplash = true;
    }

    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF111827),
          body: Center(
            child: Image.asset(
              'assets/logo.png',
              width: 120,
              height: 120,
            ),
          ),
        ),
      );
    }

    if (_showSplash) {
      return Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: settings.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: VideoSplashScreen(
              onComplete: () {
                setState(() {
                  _showSplash = false;
                });
              },
            ),
          );
        },
      );
    }

    // Pass the incoming file path to the app so it opens directly in reader
    return PdfToolkitApp(incomingFilePath: widget.incomingFilePath);
  }
}
