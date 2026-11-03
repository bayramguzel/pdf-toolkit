import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../providers/settings_provider.dart';
import '../widgets/file_dropzone.dart';
import '../widgets/loading_spinner.dart';
import '../widgets/operation_success_screen.dart';
import '../utils/file_utils.dart';

class PdfCompressScreen extends StatefulWidget {
  const PdfCompressScreen({super.key});

  @override
  State<PdfCompressScreen> createState() => _PdfCompressScreenState();
}

class _PdfCompressScreenState extends State<PdfCompressScreen> {
  File? _pdfFile;
  PickedFile? _pickedFile;
  PdfDocument? _pdfDocument;
  bool _isProcessing = false;
  String _statusText = '';
  String? _error;
  String _compressionLevel = 'best';
  File? _compressedFile;
  Uint8List? _compressedBytes;
  String? _compressedFileName;

  Future<void> _handleFileSelect(List<PickedFile> files) async {
    if (files.isEmpty) return;
    final pf = files.first;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isProcessing = true;
      _statusText = l10n.loadingPdf;
      _error = null;
      _pickedFile = pf;
      _pdfFile = pf.isWeb ? null : pf.ioFile;
    });

    try {
      final bytes = await pf.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);

      setState(() {
        _pdfDocument = document;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _error = l10n.errorLoadingPdf(e.toString());
        _isProcessing = false;
        _pickedFile = null;
        _pdfFile = null;
      });
    }
  }

  Future<void> _compressPdf() async {
    final l10n = AppLocalizations.of(context)!;
    if (_pdfDocument == null || _pickedFile == null) {
      setState(() {
        _error = l10n.pleaseSelectValidPdfFirst;
      });
      return;
    }

    final customDirectory =
        Provider.of<SettingsProvider>(context, listen: false).saveDirectory;

    setState(() {
      _isProcessing = true;
      _statusText = l10n.compressingPdf;
      _error = null;
    });

    PdfDocument? document;
    try {
      // Read the original PDF
      final bytes = await _pickedFile!.readAsBytes();
      final originalSize = bytes.length;
      document = PdfDocument(inputBytes: bytes);

      // Set compression level based on user selection
      document.compressionLevel = _compressionLevel == 'best'
          ? PdfCompressionLevel.best
          : (_compressionLevel == 'normal'
              ? PdfCompressionLevel.normal
              : PdfCompressionLevel.none);

      setState(() {
        _statusText = l10n.applyingCompression;
      });

      document.fileStructure.incrementalUpdate = false;

      if (_compressionLevel != 'none') {
        document.fileStructure.crossReferenceType =
            PdfCrossReferenceType.crossReferenceStream;
      }

      setState(() {
        _statusText = l10n.savingCompressedPdf;
      });

      final List<int> compressedBytes = await document.save();
      document.dispose();
      document = null;

      final compressedSize = compressedBytes.length;

      if (_compressionLevel != 'none' && compressedSize >= originalSize) {
        if (!mounted) return;
        setState(() {
          _error = l10n.unableToCompressFurther(
            FileUtils.formatFileSize(originalSize),
            FileUtils.formatFileSize(compressedSize),
          );
          _isProcessing = false;
        });
        return;
      }

      final outputName = 'compressed_${_pickedFile!.name}';

      if (kIsWeb) {
        if (!mounted) return;
        setState(() {
          _compressedBytes = Uint8List.fromList(compressedBytes);
          _compressedFileName = outputName;
          _isProcessing = false;
          _statusText = l10n.reducedFromTo(
            FileUtils.formatFileSize(originalSize),
            FileUtils.formatFileSize(compressedSize),
          );
        });
      } else {
        final directory = await FileUtils.getOutputDirectory(customDirectory);
        final outputFile = File('${directory.path}/$outputName');
        await FileUtils.writeAndScan(outputFile, compressedBytes);
        if (!mounted) return;

        setState(() {
          _compressedFile = outputFile;
          _isProcessing = false;
          _statusText = l10n.reducedFromTo(
            FileUtils.formatFileSize(originalSize),
            FileUtils.formatFileSize(compressedSize),
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = l10n.failedToCompressPdf(e.toString());
        _isProcessing = false;
      });
    } finally {
      document?.dispose();
    }
  }

  void _reset() {
    _pdfDocument?.dispose();
    setState(() {
      _pdfFile = null;
      _pickedFile = null;
      _pdfDocument = null;
      _compressedFile = null;
      _compressedBytes = null;
      _compressedFileName = null;
      _error = null;
    });
  }

  @override
  void dispose() {
    _pdfDocument?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (_isProcessing) {
      return Column(
        children: [
          Expanded(child: LoadingSpinner(text: _statusText)),
        ],
      );
    }

    if (_compressedFile != null || _compressedBytes != null) {
      return Column(
        children: [
          Expanded(
            child: OperationSuccessScreen(
              file: _compressedFile,
              bytes: _compressedBytes,
              fileName: _compressedFileName,
              onGoHome: () {
                _reset();
                appState.goHome();
              },
              successMessage: l10n.pdfCompressedSuccessfully,
              isPdf: true,
            ),
          ),
        ],
      );
    }

    if (_pickedFile == null) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.compress,
                        size: 64, color: Color(0xFFFACC15)), // Yellow
                    const SizedBox(height: 16),
                    Text(
                      l10n.compressPdf,
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.reduceSize,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FileDropzone(onFileSelect: _handleFileSelect),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                const Text(
                  'Compress PDF',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Adjust the compression level, then click Compress.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha((0.2 * 255).round()),
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          _pickedFile!.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_pdfDocument?.pages.count ?? 0} pages',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.tune, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              l10n.compressionSettings,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _compressionLevel,
                          decoration: InputDecoration(
                            labelText: l10n.compressionLevel,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          itemHeight: 60,
                          items: [
                            DropdownMenuItem(
                              value: 'best',
                              child: SizedBox(
                                height: 60,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(l10n.maximumCompression,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(l10n.bestFileSizeReduction,
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'normal',
                              child: SizedBox(
                                height: 60,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(l10n.balanced,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(l10n.goodCompressionWithQuality,
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'none',
                              child: SizedBox(
                                height: 60,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(l10n.noCompressionTitle,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(l10n.preserveOriginalQuality,
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _compressionLevel = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withAlpha((0.1 * 255).round()),
                            border: Border.all(
                                color:
                                    Colors.blue.withAlpha((0.3 * 255).round())),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.lightbulb_outline,
                                      size: 16, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(l10n.optimizationTips,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('â€¢ ${l10n.tip1}',
                                  style: const TextStyle(fontSize: 12)),
                              Text('â€¢ ${l10n.tip2}',
                                  style: const TextStyle(fontSize: 12)),
                              Text('â€¢ ${l10n.tip3}',
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _compressPdf,
                    icon: const Icon(Icons.compress),
                    label: Text(l10n.compressPdf),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    ]);
  }
}
