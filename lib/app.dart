import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'providers/app_state.dart';
import 'providers/settings_provider.dart';
import 'services/ad_service.dart';
import 'utils/platform_helper.dart';
import 'widgets/settings_drawer.dart';
import 'screens/home_screen.dart';
import 'screens/pdf_reader_screen.dart';
import 'screens/pdf_merge_screen.dart';
import 'screens/pdf_split_screen.dart';
import 'screens/pdf_compress_screen.dart';
import 'screens/pdf_to_image_screen.dart';
import 'screens/pdf_encrypt_screen.dart';
import 'screens/pdf_unlock_screen.dart';
import 'screens/pdf_to_word_screen.dart';
import 'screens/pdf_rotate_screen.dart';
import 'screens/pdf_watermark_screen.dart';
import 'screens/pdf_remove_pages_screen.dart';
import 'screens/pdf_reorder_screen.dart';
import 'screens/image_to_pdf_screen.dart';
import 'screens/word_to_pdf_screen.dart';
import 'screens/notepad_screen.dart';
import 'screens/pdf_toolkit_folder_screen.dart';
import 'widgets/levelplay_banner_widget.dart';
import 'widgets/vip_reward_dialog.dart';

class PdfToolkitApp extends StatefulWidget {
  /// If non-null, the app was launched by opening a PDF file externally.
  /// The reader will open this file immediately, skipping the home screen.
  final String? incomingFilePath;

  const PdfToolkitApp({super.key, this.incomingFilePath});

  @override
  State<PdfToolkitApp> createState() => _PdfToolkitAppState();
}

class _PdfToolkitAppState extends State<PdfToolkitApp> {
  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();

    // If launched via external file intent, open it directly
    if (!kIsWeb && widget.incomingFilePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<AppState>(context, listen: false)
              .handleIncomingFile(widget.incomingFilePath!);
        }
      });
    }

    // Skip mobile-specific features on web
    if (!kIsWeb && PlatformHelper.isAndroid) {
      // For sharing or opening files while the app is in memory
      _intentDataStreamSubscription =
          ReceiveSharingIntent.instance.getMediaStream().listen((value) {
        if (value.isNotEmpty && mounted) {
          final path = value.first.path;
          Provider.of<AppState>(context, listen: false)
              .handleIncomingFile(path);
        }
      }, onError: (err) {
        debugPrint("getIntentDataStream error: $err");
      });

      // For sharing or opening files while the app is closed:
      // Already handled in main.dart via incomingFilePath — reset the intent
      // so it doesn't fire again here.
      if (widget.incomingFilePath != null) {
        ReceiveSharingIntent.instance.reset();
      } else {
        ReceiveSharingIntent.instance.getInitialMedia().then((value) {
          if (value.isNotEmpty && mounted) {
            final path = value.first.path;
            Provider.of<AppState>(context, listen: false)
                .handleIncomingFile(path);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    if (!kIsWeb && PlatformHelper.isAndroid) {
      _intentDataStreamSubscription.cancel();
    }
    super.dispose();
  }

  ThemeData _buildTheme(Color primaryColor, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
      ).copyWith(
        // Better contrast for text colors
        onSurface: isDark ? Colors.white : Colors.black,
        onSurfaceVariant: isDark ? Colors.grey[300] : Colors.grey[900],
      ),
      scaffoldBackgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          color: isDark ? Colors.grey[300] : Colors.black87,
        ),
        bodySmall: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.black54,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1F2937) : primaryColor,
        elevation: 2,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(settings.primaryColor, Brightness.light),
          darkTheme: _buildTheme(settings.primaryColor, Brightness.dark),
          themeMode: settings.themeMode,
          locale: settings.locale,
          localeResolutionCallback: (locale, supportedLocales) {
            // If user manually selected a language, use it
            if (settings.isLocaleManuallySet) {
              return settings.locale;
            }

            // Auto-detect: try to match system locale
            if (locale != null) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
            }

            // Default to English
            return const Locale('en');
          },
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('tr'),
            Locale('de'),
          ],
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isVipActive = false;
  Timer? _vipTimer;
  Offset? _edgeSwipeStart;

  @override
  void initState() {
    super.initState();
    _checkVipStatus();
    _vipTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _checkVipStatus());
  }

  Future<void> _checkVipStatus() async {
    final active = await AdService().isVipActive();
    if (mounted && active != _isVipActive) {
      setState(() {
        _isVipActive = active;
      });
    }
  }

  Future<void> _handleRewardClick() async {
    await VipRewardDialog.show(context);
    if (mounted) {
      _checkVipStatus();
    }
  }

  @override
  void dispose() {
    _vipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              if (appState.activeTool != ToolType.home) {
                appState.goHome();
              } else {
                // Android: back on the home screen leaves the app.
                // iOS has no system back button; do nothing.
                if (PlatformHelper.isAndroid) {
                  SystemNavigator.pop();
                }
              }
            }
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: PlatformHelper.isIOS,
              titleSpacing: appState.activeTool == ToolType.home ? 16 : 0,
              leading: appState.activeTool != ToolType.home
                  ? IconButton(
                      icon: Icon(PlatformHelper.isIOS
                          ? Icons.arrow_back_ios_new
                          : Icons.arrow_back),
                      onPressed: () => appState.goHome(),
                    )
                  : null,
              title: InkWell(
                onTap: () => appState.goHome(),
                child: const Text('PDF Toolkit'),
              ),
              actions: [
                // Gold Star Icon for Rewarded Ad + Red indicator badge when expired
                IconButton(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 28,
                      ),
                      if (!_isVipActive)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context)
                                        .appBarTheme
                                        .backgroundColor ??
                                    Theme.of(context).primaryColor,
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.redAccent,
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  tooltip: '24h Free Usage (Rewarded Ad)',
                  onPressed: _handleRewardClick,
                ),
                // Share App link
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  tooltip: 'Share App',
                  onPressed: () {
                    final l10n = AppLocalizations.of(context)!;
                    const websiteUrl = 'https://41software.com/pdftoolkit';
                    final shareText =
                        '${l10n.appTitle}\n\n${l10n.shareAppMessage}\n$websiteUrl';
                    SharePlus.instance.share(
                      ShareParams(
                        text: shareText,
                      ),
                    );
                  },
                ),
                // Theme Toggle
                IconButton(
                  icon: Icon(
                    settings.themeMode == ThemeMode.dark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                  ),
                  tooltip: settings.themeMode == ThemeMode.dark
                      ? 'Switch to Light Mode'
                      : 'Switch to Dark Mode',
                  onPressed: () {
                    settings.setThemeMode(settings.themeMode == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark);
                  },
                ),
                const SizedBox(width: 4),
              ],
            ),
            drawer: appState.activeTool == ToolType.home
                ? const SettingsDrawer()
                : null,
            body: Listener(
              // iOS-style edge swipe from the left border returns home.
              // A Listener never competes with child gestures, so scrolling
              // and the PDF viewer keep working normally.
              onPointerDown: PlatformHelper.isIOS
                  ? (event) => _edgeSwipeStart = event.position
                  : null,
              onPointerUp: PlatformHelper.isIOS
                  ? (event) {
                      final start = _edgeSwipeStart;
                      _edgeSwipeStart = null;
                      if (start == null ||
                          appState.activeTool == ToolType.home) {
                        return;
                      }
                      final dx = event.position.dx - start.dx;
                      final dy = (event.position.dy - start.dy).abs();
                      if (start.dx <= 40 && dx >= 80 && dy <= dx) {
                        appState.goHome();
                      }
                    }
                  : null,
              child: SafeArea(
                // Reserve space for Android nav bar at the bottom and
                // status bar at the top (AppBar already handles top).
                top: false,
                child: Column(
                  children: [
                    Expanded(child: _buildCurrentScreen(appState)),
                    if (appState.activeTool != ToolType.home) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: LevelPlayBannerWidget(height: 50),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 6.0),
                        child: Center(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: () => appState.goHome(),
                              icon: Icon(
                                Icons.home_rounded,
                                size: 20,
                                color: settings.primaryColor,
                              ),
                              label: Text(
                                AppLocalizations.of(context)!.backToHome,
                                style: TextStyle(
                                  color: settings.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: settings.primaryColor.withAlpha(160),
                                    width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentScreen(AppState appState) {
    switch (appState.activeTool) {
      case ToolType.reader:
        return PdfReaderScreen(initialFile: appState.initialReaderFile);
      case ToolType.merger:
        return const PdfMergeScreen();
      case ToolType.splitter:
        return const PdfSplitScreen();
      case ToolType.compressor:
        return const PdfCompressScreen();
      case ToolType.pdfToImage:
        return const PdfToImageScreen();
      case ToolType.encryptor:
        return const PdfEncryptScreen();
      case ToolType.unlocker:
        return const PdfUnlockScreen();
      case ToolType.pdfToWord:
        return const PdfToWordScreen();
      case ToolType.rotate:
        return const PdfRotateScreen();
      case ToolType.watermark:
        return const PdfWatermarkScreen();
      case ToolType.removePages:
        return const PdfRemovePagesScreen();
      case ToolType.reorder:
        return const PdfReorderScreen();
      case ToolType.imageToPdf:
        return const ImageToPdfScreen();
      case ToolType.wordToPdf:
        return const WordToPdfScreen();
      case ToolType.notepad:
        return const NotepadScreen();
      case ToolType.folderBrowser:
        return const PdfToolkitFolderScreen();
      case ToolType.home:
        return const HomeScreen();
    }
  }
}
