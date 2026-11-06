import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import 'package:pdf_toolkit/utils/file_utils.dart';
import 'package:pdf_toolkit/utils/platform_helper.dart';

class ImageGallerySuccessScreen extends StatelessWidget {
  /// Mobile: provide [imageFiles]. Web: provide [imageBytes] + [imageNames].
  final List<File>? imageFiles;
  final List<Uint8List>? imageBytes;
  final List<String>? imageNames;
  final VoidCallback onGoHome;
  final String successMessage;

  const ImageGallerySuccessScreen({
    super.key,
    this.imageFiles,
    this.imageBytes,
    this.imageNames,
    required this.onGoHome,
    this.successMessage = 'Images saved successfully!',
  });

  int get _count =>
      kIsWeb ? (imageBytes?.length ?? 0) : (imageFiles?.length ?? 0);

  Future<void> _handleShareAll(BuildContext context) async {
    if (kIsWeb) return; // no share on web
    try {
      final xFiles = imageFiles!.map((f) => XFile(f.path)).toList();
      await SharePlus.instance.share(
        ShareParams(
          files: xFiles,
          text: 'Converted ${imageFiles!.length} image(s)',
          sharePositionOrigin: FileUtils.shareAnchorRect(context),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error sharing images: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleShareSingle(BuildContext context, File file) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Check out this image',
          sharePositionOrigin: FileUtils.shareAnchorRect(context),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error sharing image: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  /// iOS: keeps a copy of one image through the native "Save to Files" panel.
  Future<void> _saveImageToDevice(BuildContext context, int index) async {
    final l10n = AppLocalizations.of(context)!;
    final file = imageFiles![index];
    String? savedPath;
    bool panelUnavailable = false;
    try {
      savedPath = await FileUtils.saveFileWithPanel(file);
    } catch (e) {
      debugPrint('Save to Files panel failed: $e');
      panelUnavailable = true;
    }
    if (!context.mounted) return;
    if (savedPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${l10n.savedToFiles}\n${FileUtils.baseName(savedPath)}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    if (panelUnavailable) {
      // No panel: the share sheet still offers "Save to Files".
      await _handleShareSingle(context, file);
    }
  }

  /// iOS: save panel for every image, in order. iOS only exports one document
  /// per dialog, so this walks the list one panel at a time.
  Future<void> _saveAllToDevice(BuildContext context) async {
    if (imageFiles == null || imageFiles!.isEmpty) return;
    if (imageFiles!.length == 1) {
      await _saveImageToDevice(context, 0);
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    // Multiple documents: the share sheet can save them all at once.
    await _handleShareAll(context);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.iosSaveImagesHint),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _downloadImage(BuildContext context, int index) async {
    if (!kIsWeb) return;
    final bytes = imageBytes![index];
    final name = imageNames?[index] ?? 'page_${index + 1}.png';
    await FileUtils.downloadBytesWeb(bytes, name);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Downloading: $name'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _downloadAll(BuildContext context) async {
    if (!kIsWeb) return;
    for (int i = 0; i < (imageBytes?.length ?? 0); i++) {
      final name = imageNames?[i] ?? 'page_${i + 1}.png';
      await FileUtils.downloadBytesWeb(imageBytes![i], name);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('All images downloading...'),
            backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _showSavedLocation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (imageFiles == null || imageFiles!.isEmpty) return;
    final fullPath = imageFiles!.first.path;
    final lastSeparator = fullPath.lastIndexOf(Platform.pathSeparator);
    final directory =
        lastSeparator != -1 ? fullPath.substring(0, lastSeparator) : fullPath;

    if (PlatformHelper.isIOS) {
      // Show the Files app where the app's Documents folder is visible.
      final opened = await FileUtils.openDirectoryPath(directory);
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.iosFilesHint)),
        );
      }
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.imagesSaved),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${imageFiles!.length} images have been saved to:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                directory,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    final Widget imageWidget = kIsWeb
        ? Image.memory(imageBytes![index], fit: BoxFit.contain)
        : Image.file(imageFiles![index], fit: BoxFit.contain);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text('Image ${index + 1} of $_count'),
            backgroundColor: Colors.black,
            actions: [
              if (kIsWeb)
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _downloadImage(context, index),
                )
              else ...[
                if (PlatformHelper.isIOS)
                  IconButton(
                    icon: const Icon(Icons.save_alt),
                    tooltip: l10n.saveToFiles,
                    onPressed: () => _saveImageToDevice(context, index),
                  ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () =>
                      _handleShareSingle(context, imageFiles![index]),
                ),
              ],
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: imageWidget,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha((0.2 * 255).round()),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.check_circle, size: 60, color: Colors.green),
            ),
            const SizedBox(height: 16),
            Text(
              successMessage,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$_count image(s) ${kIsWeb ? "ready to download" : "saved"}',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
            if (!kIsWeb && PlatformHelper.isIOS) ...[
              const SizedBox(height: 6),
              Text(
                l10n.iosFilesHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                if (kIsWeb)
                  ElevatedButton.icon(
                    onPressed: () => _downloadAll(context),
                    icon: const Icon(Icons.download),
                    label: const Text('Download All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  )
                else ...[
                  ElevatedButton.icon(
                    onPressed: () => _showSavedLocation(context),
                    icon: Icon(PlatformHelper.isIOS
                        ? Icons.folder_copy_outlined
                        : Icons.info_outline),
                    label: Text(PlatformHelper.isIOS
                        ? l10n.openInFiles
                        : l10n.viewLocation),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _handleShareAll(context),
                    icon: const Icon(Icons.share),
                    label: Text(l10n.shareAll),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                  if (PlatformHelper.isIOS)
                    ElevatedButton.icon(
                      onPressed: () => _saveAllToDevice(context),
                      icon: const Icon(Icons.save_alt),
                      label: Text(l10n.saveToFiles),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                ],
                ElevatedButton.icon(
                  onPressed: onGoHome,
                  icon: const Icon(Icons.home),
                  label: Text(l10n.goHome),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: _count,
                itemBuilder: (context, index) {
                  final Widget thumb = kIsWeb
                      ? Image.memory(imageBytes![index], fit: BoxFit.cover)
                      : Image.file(imageFiles![index], fit: BoxFit.cover);

                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _showImagePreview(context, index),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: thumb),
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.grey[850],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Page ${index + 1}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                if (kIsWeb)
                                  Text(
                                    FileUtils.formatFileSize(
                                        imageBytes![index].length),
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[400]),
                                  )
                                else
                                  FutureBuilder<int>(
                                    future: imageFiles![index].length(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Text(
                                          FileUtils.formatFileSize(
                                              snapshot.data!),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[400]),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility,
                                          size: 20),
                                      onPressed: () =>
                                          _showImagePreview(context, index),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        kIsWeb ? Icons.download : Icons.share,
                                        size: 20,
                                      ),
                                      onPressed: kIsWeb
                                          ? () => _downloadImage(context, index)
                                          : () => _handleShareSingle(
                                              context, imageFiles![index]),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
