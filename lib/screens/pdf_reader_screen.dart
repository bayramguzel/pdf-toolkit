import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/file_dropzone.dart';
import '../widgets/loading_spinner.dart';
import '../utils/file_utils.dart';
import '../utils/platform_helper.dart';
import '../utils/web_download_stub.dart'
    if (dart.library.js_interop) '../utils/web_download.dart' as web_dl;

class PdfReaderScreen extends StatefulWidget {
  final File? initialFile;

  const PdfReaderScreen({super.key, this.initialFile});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  File? _pdfFile;
  Uint8List? _pdfBytes; // for web
  String? _pdfFileName;
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isLoading = false;
  bool _documentLoaded = false;
  String? _error;
  double _zoomLevel = 1.0;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && widget.initialFile != null) {
      _loadPdf(widget.initialFile!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _loadPdf(File file) {
    setState(() {
      _isLoading = true;
      _documentLoaded = false;
      _error = null;
      _pdfFile = file;
      _pdfFileName = file.path.split(RegExp(r'[\\/]')).last;
    });
  }

  void _loadPdfBytes(Uint8List bytes, String name) {
    setState(() {
      _isLoading = true;
      _documentLoaded = false;
      _error = null;
      _pdfBytes = bytes;
      _pdfFileName = name;
    });
  }

  Future<void> _downloadPdf() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_hasFile) return;

    try {
      if (kIsWeb) {
        if (_pdfBytes != null) {
          web_dl.downloadFileWeb(_pdfBytes!, _pdfFileName ?? 'document.pdf');
        }
      } else {
        final bytes = await _pdfFile!.readAsBytes();

        if (Platform.isAndroid) {
          // Uses MediaStore on Android 10+ and a direct write + scan on older
          // versions, so no storage permission is required.
          final savedPath = await FileUtils.saveToDownloads(
              bytes, _pdfFileName ?? 'document.pdf');
          if (savedPath == null) {
            throw Exception('Could not save to Downloads');
          }
        } else if (Platform.isIOS) {
          // iOS has no public Downloads folder. Use the system "Save to Files"
          // panel so the user picks the destination; fall back to the share
          // sheet when the panel cannot be presented.
          String? savedPath;
          bool panelUnavailable = false;
          try {
            savedPath = await FileUtils.saveWithSavePanel(
                bytes: bytes, fileName: _pdfFileName ?? 'document.pdf');
          } catch (e) {
            debugPrint('Save to Files panel failed: $e');
            panelUnavailable = true;
          }
          if (!mounted) return;
          if (savedPath != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${l10n.savedToFiles}\n${FileUtils.baseName(savedPath)}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
            return;
          }
          if (panelUnavailable) {
            await _sharePdf();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.chooseSaveLocationHint),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
          return;
        } else {
          Directory? downloadsDir;
          try {
            downloadsDir = await getDownloadsDirectory();
          } catch (_) {
            downloadsDir = null;
          }
          downloadsDir ??= await getApplicationDocumentsDirectory();
          final filePath =
              '${downloadsDir.path}/${_pdfFileName ?? 'document.pdf'}';
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          await FileUtils.scanFileForMediaStore(filePath);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.fileDownloaded),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Download error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _sharePdf() async {
    if (!_hasFile) return;

    try {
      final l10n = AppLocalizations.of(context)!;
      const webUrl = 'https://41software.com/pdftoolkit';
      final shareMsg = '${l10n.shareAppMessage}\n$webUrl';

      if (kIsWeb) {
        await SharePlus.instance.share(
          ShareParams(text: shareMsg),
        );
      } else {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(_pdfFile!.path)],
            text: shareMsg,
            subject: l10n.shareFile,
            sharePositionOrigin: FileUtils.shareAnchorRect(context),
          ),
        );
      }
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  void _handleFileSelected(List<PickedFile> files) {
    if (files.isEmpty) return;
    final f = files.first;
    if (!(f.path ?? f.name).toLowerCase().endsWith('.pdf')) {
      return;
    }
    if (f.isWeb) {
      f.readAsBytes().then((bytes) {
        if (mounted) _loadPdfBytes(bytes, f.name);
      });
    } else {
      _loadPdf(f.ioFile);
    }
  }

  bool get _hasFile => kIsWeb ? _pdfBytes != null : _pdfFile != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(50),
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        ),
      );
    }

    if (!_hasFile) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.readPdf,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                kIsWeb
                    ? 'Click below to select a PDF file from your device'
                    : l10n.clickToSelectFile('PDF', ''),
                style: TextStyle(fontSize: 15, color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FileDropzone(onFileSelect: _handleFileSelected),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: Colors.grey[900],
          child: IconTheme(
            data: const IconThemeData(color: Colors.white),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _pdfFileName ?? 'PDF',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.zoom_out, size: 20, color: Colors.white),
                  onPressed: _documentLoaded
                      ? () {
                          setState(() {
                            _zoomLevel = (_zoomLevel - 0.25).clamp(0.5, 5.0);
                            _pdfViewerController.zoomLevel = _zoomLevel;
                          });
                        }
                      : null,
                  tooltip: 'Zoom Out',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                Text('${(_zoomLevel * 100).round()}%',
                    style: const TextStyle(fontSize: 12, color: Colors.white)),
                IconButton(
                  icon:
                      const Icon(Icons.zoom_in, size: 20, color: Colors.white),
                  onPressed: _documentLoaded
                      ? () {
                          setState(() {
                            _zoomLevel = (_zoomLevel + 0.25).clamp(0.5, 5.0);
                            _pdfViewerController.zoomLevel = _zoomLevel;
                          });
                        }
                      : null,
                  tooltip: 'Zoom In',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                IconButton(
                  icon: Icon(_isSearchVisible ? Icons.search_off : Icons.search,
                      size: 20, color: Colors.white),
                  onPressed: _documentLoaded
                      ? () =>
                          setState(() => _isSearchVisible = !_isSearchVisible)
                      : null,
                  tooltip: 'Search',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                IconButton(
                  icon: Icon(
                      PlatformHelper.isIOS ? Icons.save_alt : Icons.download,
                      size: 20,
                      color: Colors.white),
                  onPressed: _downloadPdf,
                  tooltip: PlatformHelper.isIOS ? l10n.saveToFiles : 'Download',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                IconButton(
                  icon: const Icon(Icons.share, size: 20, color: Colors.white),
                  onPressed: _sharePdf,
                  tooltip: 'Share',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                IconButton(
                  icon: const Icon(Icons.folder_open,
                      size: 20, color: Colors.white),
                  onPressed: () => setState(() {
                    _pdfFile = null;
                    _pdfBytes = null;
                    _pdfFileName = null;
                    _documentLoaded = false;
                    _isLoading = false;
                  }),
                  tooltip: 'Open another file',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),
        ),
        if (_isSearchVisible)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[800],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search in PDF...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    onSubmitted: (v) => _pdfViewerController.searchText(v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _pdfViewerController.clearSelection();
                    _searchController.clear();
                  },
                ),
              ],
            ),
          ),
        Expanded(
          child: Stack(
            children: [
              if (kIsWeb)
                SfPdfViewer.memory(
                  _pdfBytes!,
                  controller: _pdfViewerController,
                  initialZoomLevel: _zoomLevel,
                  pageLayoutMode: PdfPageLayoutMode.single,
                  scrollDirection: PdfScrollDirection.vertical,
                  enableDoubleTapZooming: true,
                  interactionMode: PdfInteractionMode.pan,
                  onDocumentLoaded: (details) {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                        _documentLoaded = true;
                      });
                    }
                  },
                  onDocumentLoadFailed: (details) {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                        _error = l10n.errorLoadingPdf(details.error);
                      });
                    }
                  },
                )
              else
                SfPdfViewer.file(
                  _pdfFile!,
                  controller: _pdfViewerController,
                  initialZoomLevel: _zoomLevel,
                  pageLayoutMode: PdfPageLayoutMode.single,
                  scrollDirection: PdfScrollDirection.vertical,
                  enableDoubleTapZooming: true,
                  interactionMode: PdfInteractionMode.pan,
                  onDocumentLoaded: (details) {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                        _documentLoaded = true;
                      });
                    }
                  },
                  onDocumentLoadFailed: (details) {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                        _error = l10n.errorLoadingPdf(details.error);
                      });
                    }
                  },
                ),
              if (_isLoading)
                Positioned.fill(
                  child: LoadingSpinner(text: l10n.loadingPdf),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
