import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import '../providers/settings_provider.dart';
import '../widgets/auto_fit_text.dart';
import '../widgets/tool_card.dart';
import '../widgets/levelplay_banner_widget.dart';
import '../utils/platform_helper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    // iOS uses a native-looking, grouped list instead of the gradient
    // banner/card layout. Android and web are unchanged.
    if (PlatformHelper.isIOS) {
      final settings = Provider.of<SettingsProvider>(context);
      return _IosHomeLayout(
        appState: appState,
        l10n: l10n,
        bottomPadding: bottomPadding,
        isGrid: settings.isGridView,
      );
    }

    // Web: compact sizes, mobile: original sizes
    final double titleSize = kIsWeb
        ? (screenWidth * 0.04).clamp(18.0, 28.0)
        : (screenWidth * 0.105).clamp(26.0, 44.0);
    final double subtitleSize = kIsWeb
        ? (screenWidth * 0.02).clamp(11.0, 14.0)
        : (screenWidth * 0.040).clamp(13.0, 17.0);

    // Web: much smaller hero buttons
    final double readerHeight = kIsWeb
        ? (screenWidth * 0.06).clamp(48.0, 64.0)
        : (screenWidth * 0.28).clamp(80.0, 120.0);
    final double folderHeight = kIsWeb
        ? (screenWidth * 0.04).clamp(36.0, 48.0)
        : (screenWidth * 0.17).clamp(54.0, 76.0);

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.fromLTRB(20.0, 20.0, 20.0, bottomPadding + 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated gradient title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF8B5CF6),
                        Color(0xFFEC4899),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      l10n.appTitle,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3B82F6)
                              .withAlpha((0.2 * 255).round()),
                          const Color(0xFF8B5CF6)
                              .withAlpha((0.2 * 255).round()),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF3B82F6)
                            .withAlpha((0.3 * 255).round()),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF22D3EE),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.homeSubtitle,
                          style: TextStyle(
                            fontSize: subtitleSize,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[300]
                                    : Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Wide PDF Reader button
                  InkWell(
                    onTap: () => appState.selectTool(ToolType.reader),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 500),
                      height: readerHeight,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withAlpha((0.35 * 255).round()),
                          width: 1.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6)
                                .withAlpha((0.3 * 255).round()),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.white.withAlpha((0.10 * 255).round()),
                            offset: const Offset(-6, -6),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            bottom: -20,
                            child: Icon(
                              Icons.picture_as_pdf,
                              size: 140,
                              color:
                                  Colors.white.withAlpha((0.1 * 255).round()),
                            ),
                          ),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withAlpha((0.2 * 255).round()),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.menu_book,
                                      size: 32, color: Colors.white),
                                ),
                                const SizedBox(width: 24),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.readPdf,
                                      style: TextStyle(
                                        fontSize: (readerHeight * 0.22)
                                            .clamp(18.0, 28.0),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      l10n.viewSearchAnnotate,
                                      style: TextStyle(
                                        fontSize: (readerHeight * 0.125)
                                            .clamp(11.0, 15.0),
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Wide Open Folder button (mobile) or App links (web)
                  if (!kIsWeb)
                    InkWell(
                      onTap: () => appState.selectTool(ToolType.folderBrowser),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 500),
                        height: folderHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF10B981).withValues(alpha: 0.8),
                              const Color(0xFF059669).withValues(alpha: 0.9)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withAlpha((0.35 * 255).round()),
                            width: 1.6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981)
                                  .withAlpha((0.2 * 255).round()),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color:
                                  Colors.white.withAlpha((0.10 * 255).round()),
                              offset: const Offset(-6, -6),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -10,
                              bottom: -10,
                              child: Icon(
                                Icons.folder_open,
                                size: 90,
                                color:
                                    Colors.white.withAlpha((0.1 * 255).round()),
                              ),
                            ),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withAlpha((0.2 * 255).round()),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.folder,
                                        size: 24, color: Colors.white),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    l10n.openFolder,
                                    style: TextStyle(
                                      fontSize: (folderHeight * 0.27)
                                          .clamp(14.0, 22.0),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Banner Card under Open Folder (Android/web only — the iOS
                  // build has no ads and therefore no banner container).
                  if (!kIsWeb && !PlatformHelper.isIOS) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 500),
                      height: 60,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1)
                                .withAlpha((0.15 * 255).round()),
                            const Color(0xFFA855F7)
                                .withAlpha((0.15 * 255).round()),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF6366F1)
                              .withAlpha((0.3 * 255).round()),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1)
                                .withAlpha((0.15 * 255).round()),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: LevelPlayBannerWidget(height: 50),
                      ),
                    ),
                  ],
                  // Web: Play Store + About links
                  if (kIsWeb) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _WebLinkButton(
                          icon: Icons.android,
                          label: 'Android App',
                          color: const Color(0xFF34D399),
                          onTap: () => launchUrl(Uri.parse(
                              'https://play.google.com/store/apps/details?id=com.software41.pdftoolkit')),
                        ),
                        const SizedBox(width: 10),
                        _WebLinkButton(
                          icon: Icons.info_outline,
                          label: 'About',
                          color: const Color(0xFF818CF8),
                          onTap: () =>
                              launchUrl(Uri.parse('https://41software.com')),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double avail = constraints.maxWidth;
                      // Web: 4 cols on wide, 3 on medium; Mobile: 2-3
                      final int cols = kIsWeb
                          ? (avail > 700
                              ? 5
                              : avail > 480
                                  ? 4
                                  : 3)
                          : (avail > 480 ? 3 : 2);
                      const double spacing = kIsWeb ? 8.0 : 12.0;
                      final double cardWidth =
                          (avail - spacing * (cols - 1)) / cols;
                      // Web: square-ish cards, mobile: taller
                      final double cardHeight = kIsWeb
                          ? cardWidth * 0.9
                          : cardWidth * (160.0 / 150.0);
                      return Wrap(
                        spacing: kIsWeb ? 8 : spacing,
                        runSpacing: kIsWeb ? 8 : spacing,
                        alignment: WrapAlignment.center,
                        children: [
                          ToolCard(
                            icon: Icons.merge,
                            title: l10n.mergePdf,
                            description: l10n.combineFiles,
                            color: const Color(0xFFE0F2FE), // Pastel Blue
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () => appState.selectTool(ToolType.merger),
                          ),
                          ToolCard(
                            icon: Icons.call_split,
                            title: l10n.splitPdf,
                            description: l10n.extractPages,
                            color: const Color(0xFFDCFCE7), // Pastel Green
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () => appState.selectTool(ToolType.splitter),
                          ),
                          ToolCard(
                            icon: Icons.compress,
                            title: l10n.compressPdf,
                            description: l10n.reduceSize,
                            color: const Color(0xFFFEF9C3), // Pastel Yellow
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () =>
                                appState.selectTool(ToolType.compressor),
                          ),
                          ToolCard(
                            icon: Icons.rotate_right,
                            title: l10n.rotatePdf,
                            description: l10n.turnPages,
                            color: const Color(0xFFFFEDD5), // Pastel Orange
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () => appState.selectTool(ToolType.rotate),
                          ),
                          ToolCard(
                            icon: Icons.delete_sweep,
                            title: l10n.removePdf,
                            description: l10n.deletePages,
                            color: const Color(0xFFFEE2E2), // Pastel Red
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () =>
                                appState.selectTool(ToolType.removePages),
                          ),
                          ToolCard(
                            icon: Icons.reorder,
                            title: l10n.reorderPdf,
                            description: l10n.arrangePages,
                            color: const Color(0xFFE0E7FF), // Pastel Indigo
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () => appState.selectTool(ToolType.reorder),
                          ),
                          ToolCard(
                            icon: Icons.water_drop,
                            title: l10n.watermarkPdf,
                            description: l10n.addTextImage,
                            color: const Color(0xFFDBEAFE), // Pastel Light Blue
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () =>
                                appState.selectTool(ToolType.watermark),
                          ),
                          ToolCard(
                            icon: Icons.lock,
                            title: l10n.encryptPdf,
                            description: l10n.addPassword,
                            color: const Color(0xFFFCE7F3), // Pastel Pink
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () =>
                                appState.selectTool(ToolType.encryptor),
                          ),
                          ToolCard(
                            icon: Icons.lock_open,
                            title: l10n.unlock,
                            description: l10n.removePass,
                            color: const Color(0xFFF3E8FF), // Pastel Purple
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () => appState.selectTool(ToolType.unlocker),
                          ),
                          ToolCard(
                            icon: Icons.image,
                            title: l10n.pdfToImage,
                            description: l10n.pngJpeg,
                            color: const Color(0xFFFBCFE8), // Pastel Rose
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () =>
                                appState.selectTool(ToolType.pdfToImage),
                          ),
                          ToolCard(
                            icon: Icons.article,
                            title: l10n.pdfToText,
                            description: l10n.toRtfTxt,
                            color: const Color(0xFFE9D5FF), // Pastel Violet
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () =>
                                appState.selectTool(ToolType.pdfToWord),
                          ),
                          ToolCard(
                            icon: Icons.add_photo_alternate,
                            title: l10n.imageToPdf,
                            description: l10n.convertImages,
                            color: const Color(0xFFDDD6FE), // Pastel Purple
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () =>
                                appState.selectTool(ToolType.imageToPdf),
                          ),
                          ToolCard(
                            icon: Icons.text_snippet,
                            title: l10n.textToPdf,
                            description: l10n.convertTxt,
                            color: const Color(0xFFCCFBF1), // Pastel Teal
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () =>
                                appState.selectTool(ToolType.wordToPdf),
                          ),
                          ToolCard(
                            icon: Icons.note_alt,
                            title: l10n.notepad,
                            description: l10n.notepadDescription,
                            color: const Color(0xFFFDE68A), // Pastel Amber
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () => appState.selectTool(ToolType.notepad),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!kIsWeb && !PlatformHelper.isIOS)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: LevelPlayBannerWidget(height: 50),
          ),
      ],
    );
  }
}

class _IosToolEntry {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color accent;
  final Color pastel;
  final ToolType tool;

  const _IosToolEntry({
    required this.icon,
    required this.title,
    required this.tool,
    required this.accent,
    required this.pastel,
    this.subtitle,
  });
}

/// Native-looking home layout used on iOS. Each tool gets its own pastel
/// accent: pastel fills in light mode and black cards with a pastel border in
/// dark mode. Icons are Cupertino (SF-Symbol-like) so the screen feels native.
class _IosHomeLayout extends StatelessWidget {
  final AppState appState;
  final AppLocalizations l10n;
  final double bottomPadding;
  final bool isGrid;

  const _IosHomeLayout({
    required this.appState,
    required this.l10n,
    required this.bottomPadding,
    required this.isGrid,
  });

  @override
  Widget build(BuildContext context) {
    final tools = <_IosToolEntry>[
      _IosToolEntry(
        icon: CupertinoIcons.square_on_square,
        title: l10n.mergePdf,
        subtitle: l10n.combineFiles,
        accent: const Color(0xFF0284C7),
        pastel: const Color(0xFFE0F2FE),
        tool: ToolType.merger,
      ),
      _IosToolEntry(
        icon: CupertinoIcons.scissors,
        title: l10n.splitPdf,
        subtitle: l10n.extractPages,
        accent: const Color(0xFF16A34A),
        pastel: const Color(0xFFDCFCE7),
        tool: ToolType.splitter,
      ),
      _IosToolEntry(
        icon: CupertinoIcons.archivebox,
        title: l10n.compressPdf,
        subtitle: l10n.reduceSize,
        accent: const Color(0xFFCA8A04),
        pastel: const Color(0xFFFEF9C3),
        tool: ToolType.compressor,
      ),
      _IosToolEntry(
        icon: CupertinoIcons.rotate_right,
        title: l10n.rotatePdf,
        subtitle: l10n.turnPages,
        accent: const Color(0xFFEA580C),
        pastel: const Color(0xFFFFEDD5),
        tool: ToolType.rotate,
      ),
      _IosToolEntry(
        icon: CupertinoIcons.delete,
        title: l10n.removePdf,
        subtitle: l10n.deletePages,
        accent: const Color(0xFFDC2626),
        pastel: const Color(0xFFFEE2E2),
        tool: ToolType.removePages,
      ),
      _IosToolEntry(
        icon: CupertinoIcons.square_grid_2x2,
        title: l10n.reorderPdf,
        subtitle: l10n.arrangePages,
        accent: const Color(0xFF4F46E5),
        pastel: const Color(0xFFE0E7FF),
        tool: ToolType.reorder,
      ),
      _IosToolEntry(
        icon: CupertinoIcons.drop,
        title: l10n.watermarkPdf,
        subtitle: l10n.addTextImage,
        accent: const Color(0xFF0891B2),
        pastel: const Color(0xFFCFFAFE),
        tool: ToolType.watermark,
      ),
      _IosToolEntry(
        icon: CupertinoIcons.lock,
        title: l10n.encryptPdf,
        subtitle: l10n.addPassword,
        accent: const Color(0xFFDB2777),
        pastel: const Color(0xFFFCE7F3),
        tool: ToolType.encryptor,
      ),
      _IosToolEntry(
        icon: CupertinoIcons.lock_open,
        title: l10n.unlock,
        subtitle: l10n.removePass,
        accent: const Color(0xFF9333EA),
        pastel: const Color(0xFFF3E8FF),
        tool: ToolType.unlocker,
      ),
      _IosToolEntry(
        icon: CupertinoIcons.photo,
        title: l10n.pdfToImage,
        subtitle: l10n.pngJpeg,
        accent: const Color(0xFFC026D3),
        pastel: const Color(0xFFFAE8FF),
        tool: ToolType.pdfToImage,
      ),
      _IosToolEntry(
        icon: CupertinoIcons.doc_text,
        title: l10n.pdfToText,
        subtitle: l10n.toRtfTxt,
        accent: const Color(0xFF7C3AED),
        pastel: const Color(0xFFEDE9FE),
        tool: ToolType.pdfToWord,
      ),
      _IosToolEntry(
        icon: CupertinoIcons.photo_on_rectangle,
        title: l10n.imageToPdf,
        subtitle: l10n.convertImages,
        accent: const Color(0xFF0D9488),
        pastel: const Color(0xFFCCFBF1),
        tool: ToolType.imageToPdf,
      ),
      _IosToolEntry(
        icon: CupertinoIcons.doc_plaintext,
        title: l10n.textToPdf,
        subtitle: l10n.convertTxt,
        accent: const Color(0xFFE11D48),
        pastel: const Color(0xFFFFE4E6),
        tool: ToolType.wordToPdf,
      ),
      _IosToolEntry(
        icon: CupertinoIcons.pencil,
        title: l10n.notepad,
        subtitle: l10n.notepadDescription,
        accent: const Color(0xFFD97706),
        pastel: const Color(0xFFFEF3C7),
        tool: ToolType.notepad,
      ),
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding + 24),
      children: [
        // Primary actions as full-width cards: My Files first, then Read PDF
        // (kept on a single line because it is the most used action).
        _IosFeatureCard(
          icon: CupertinoIcons.folder_fill,
          title: l10n.myFiles,
          subtitle: l10n.openFolder,
          accent: const Color(0xFF059669),
          pastel: const Color(0xFFDCFCE7),
          onTap: () => appState.selectTool(ToolType.folderBrowser),
        ),
        const SizedBox(height: 12),
        _IosFeatureCard(
          icon: CupertinoIcons.book_fill,
          title: l10n.readPdf,
          accent: const Color(0xFF2563EB),
          pastel: const Color(0xFFE0F2FE),
          onTap: () => appState.selectTool(ToolType.reader),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.pdfTools,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
        ),
        if (isGrid)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemCount: tools.length,
            itemBuilder: (context, index) {
              final entry = tools[index];
              return _IosToolTile(
                icon: entry.icon,
                title: entry.title,
                subtitle: entry.subtitle,
                accent: entry.accent,
                pastel: entry.pastel,
                onTap: () => appState.selectTool(entry.tool),
              );
            },
          )
        else
          _IosGroup(
            children: [
              for (final entry in tools)
                _IosRow(
                  icon: entry.icon,
                  title: entry.title,
                  subtitle: entry.subtitle,
                  accent: entry.accent,
                  pastel: entry.pastel,
                  onTap: () => appState.selectTool(entry.tool),
                ),
            ],
          ),
      ],
    );
  }
}

/// Full-width card for the two primary home actions.
class _IosFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color accent;
  final Color pastel;
  final VoidCallback onTap;

  const _IosFeatureCard({
    required this.icon,
    required this.title,
    required this.accent,
    required this.pastel,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? const Color(0xFF111318) : pastel;
    final border = isDark
        ? accent.withValues(alpha: 0.85)
        : Color.alphaBlend(Colors.black.withValues(alpha: 0.16), pastel);
    final iconColor = isDark
        ? accent
        : Color.alphaBlend(Colors.black.withValues(alpha: 0.3), accent);

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: isDark ? 1.4 : 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark
                      ? accent.withValues(alpha: 0.16)
                      : Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 23, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoFitText(
                      title,
                      maxLines: 1,
                      minFontSize: 13,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: AutoFitText(
                          subtitle!,
                          maxLines: 1,
                          minFontSize: 10,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white70
                                : Colors.black.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_forward,
                size: 18,
                color: isDark
                    ? Colors.white38
                    : Colors.black.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card used in the iOS grid layout.
class _IosToolTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color accent;
  final Color pastel;
  final VoidCallback onTap;

  const _IosToolTile({
    required this.icon,
    required this.title,
    required this.accent,
    required this.pastel,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? const Color(0xFF111318) : pastel;
    final border = isDark
        ? accent.withValues(alpha: 0.85)
        : Color.alphaBlend(Colors.black.withValues(alpha: 0.14), pastel);
    final iconColor = isDark
        ? accent
        : Color.alphaBlend(Colors.black.withValues(alpha: 0.32), accent);
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor =
        isDark ? Colors.white70 : Colors.black.withValues(alpha: 0.55);

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: isDark ? 1.4 : 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? accent.withValues(alpha: 0.16)
                      : Colors.white.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const Spacer(),
              AutoFitText(
                title,
                maxLines: 2,
                minFontSize: 10,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.18,
                  color: titleColor,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: AutoFitText(
                    subtitle!,
                    maxLines: 2,
                    minFontSize: 9,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.15,
                      color: subtitleColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IosGroup extends StatelessWidget {
  final List<Widget> children;

  const _IosGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111318) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2D34) : const Color(0xFFE5E7EB),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 62,
                color:
                    isDark ? const Color(0xFF2A2D34) : const Color(0xFFF3F4F6),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _IosRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color accent;
  final Color pastel;
  final VoidCallback onTap;

  const _IosRow({
    required this.icon,
    required this.title,
    required this.accent,
    required this.pastel,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark
        ? accent
        : Color.alphaBlend(Colors.black.withValues(alpha: 0.3), accent);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? accent.withValues(alpha: 0.16) : pastel,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
      trailing: Icon(
        CupertinoIcons.chevron_forward,
        size: 16,
        color: isDark ? Colors.white30 : Colors.black26,
      ),
    );
  }
}

class _WebLinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _WebLinkButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          border: Border.all(color: color.withAlpha(100)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
