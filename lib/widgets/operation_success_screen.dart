import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import 'package:pdf_toolkit/utils/file_utils.dart';
import 'package:pdf_toolkit/utils/platform_helper.dart';
import 'package:pdf_toolkit/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class OperationSuccessScreen extends StatelessWidget {
  /// Mobile: provide [file]. Web: provide [bytes] + [fileName].
  final File? file;
  final Uint8List? bytes;
  final String? fileName;
  final VoidCallback onGoHome;
  final String successMessage;
  final bool isPdf;

  const OperationSuccessScreen({
    super.key,
    this.file,
    this.bytes,
    this.fileName,
    required this.onGoHome,
    this.successMessage = 'Operation completed successfully!',
    this.isPdf = true,
  }) : assert(
          (file != null) || (bytes != null && fileName != null),
          'Provide file on mobile or bytes+fileName on web',
        );

  String get _displayName =>
      fileName ?? file?.path.split('/').last ?? 'output.pdf';

  Future<void> _handleShare(BuildContext context) async {
    try {
      if (kIsWeb) {
        // Web: trigger browser download
        await FileUtils.downloadBytesWeb(bytes!, _displayName);
      } else {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file!.path)],
            text: 'Check out this file: $_displayName',
            sharePositionOrigin: FileUtils.shareAnchorRect(context),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// iOS: native "Save to Files" panel. Falls back to the share sheet when the
  /// panel cannot be presented. Returns true when the save panel did the work.
  Future<bool> _handleSaveToFiles(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    Uint8List? data = bytes;
    if (data == null && file != null) {
      try {
        data = await file!.readAsBytes();
      } catch (_) {
        data = null;
      }
    }

    String? savedPath;
    var panelUnavailable = data == null;
    if (data != null) {
      try {
        savedPath = await FileUtils.saveWithSavePanel(
            bytes: data, fileName: _displayName);
      } catch (e) {
        debugPrint('Save to Files panel failed: $e');
        panelUnavailable = true;
      }
    }

    if (!context.mounted) return !panelUnavailable;
    if (savedPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${l10n.savedToFiles}\n${FileUtils.baseName(savedPath)}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
      return true;
    }
    if (panelUnavailable) {
      // No panel: the share sheet still offers "Save to Files".
      await _handleShare(context);
      return false;
    }
    // The user dismissed the panel — nothing to do.
    return true;
  }

  Future<void> _handleDownload(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (kIsWeb) {
      await FileUtils.downloadBytesWeb(bytes!, _displayName);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloading: $_displayName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (PlatformHelper.isIOS) {
      final saved = await _handleSaveToFiles(context);
      if (!saved && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.chooseSaveLocationHint),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File saved: $_displayName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Share',
            onPressed: () => _handleShare(context),
          ),
        ),
      );
    }
  }

  void _showPreview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(_displayName),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _handleShare(context),
              ),
            ],
          ),
          body: kIsWeb ? SfPdfViewer.memory(bytes!) : SfPdfViewer.file(file!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final fileSize =
        kIsWeb ? FileUtils.formatFileSize(bytes?.length ?? 0) : null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha((0.2 * 255).round()),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.check_circle, size: 80, color: Colors.green),
            ),
            const SizedBox(height: 32),
            Text(
              successMessage,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.picture_as_pdf,
                        size: 48, color: Color(0xFF22D3EE)),
                    const SizedBox(height: 16),
                    Text(
                      _displayName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (kIsWeb && fileSize != null)
                      Text(fileSize,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[400]))
                    else if (!kIsWeb && file != null)
                      FutureBuilder<int>(
                        future: file!.length(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              FileUtils.formatFileSize(snapshot.data!),
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[400]),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    const SizedBox(height: 16),
                    if (!kIsWeb)
                      TextButton.icon(
                        onPressed: () async {
                          final opened = await FileUtils.openOutputDirectory(
                              settings.saveDirectory);
                          if (!opened && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.iosFilesHint)),
                            );
                          }
                        },
                        icon: Icon(PlatformHelper.isIOS
                            ? Icons.folder_copy_outlined
                            : Icons.folder_open),
                        label: Text(PlatformHelper.isIOS
                            ? l10n.openInFiles
                            : l10n.openFolder),
                        style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF22D3EE)),
                      ),
                    if (!kIsWeb && PlatformHelper.isIOS) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.iosFilesHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                if (isPdf)
                  ElevatedButton.icon(
                    onPressed: () => _showPreview(context),
                    icon: const Icon(Icons.visibility),
                    label: Text(l10n.preview),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: () => _handleDownload(context),
                  icon: Icon(kIsWeb
                      ? Icons.download
                      : PlatformHelper.isIOS
                          ? Icons.save_alt
                          : Icons.save),
                  label: Text(kIsWeb
                      ? 'Download'
                      : PlatformHelper.isIOS
                          ? l10n.saveToFiles
                          : l10n.save),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                if (!kIsWeb)
                  ElevatedButton.icon(
                    onPressed: () => _handleShare(context),
                    icon: const Icon(Icons.share),
                    label: Text(l10n.share),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
