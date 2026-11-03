import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import 'package:pdf_toolkit/utils/file_utils.dart';
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

  Future<void> _handleDownload(BuildContext context) async {
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
                        onPressed: () => FileUtils.openOutputDirectory(
                            settings.saveDirectory),
                        icon: const Icon(Icons.folder_open),
                        label: Text(l10n.openFolder),
                        style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF22D3EE)),
                      ),
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
                  icon: Icon(kIsWeb ? Icons.download : Icons.save),
                  label: Text(kIsWeb ? 'Download' : l10n.save),
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
