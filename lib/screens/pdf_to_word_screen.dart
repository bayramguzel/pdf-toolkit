import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf_pdf;
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/settings_provider.dart';
import '../utils/file_utils.dart';
import '../widgets/file_dropzone.dart';
import '../widgets/loading_spinner.dart';
import '../widgets/operation_success_screen.dart';

class PdfToWordScreen extends StatefulWidget {
  const PdfToWordScreen({super.key});

  @override
  State<PdfToWordScreen> createState() => _PdfToWordScreenState();
}

class _PdfToWordScreenState extends State<PdfToWordScreen> {
  PickedFile? _pickedFile;
  bool _isProcessing = false;
  String _statusText = '';
  String? _error;
  File? _exportedFile;
  Uint8List? _outputBytes;
  String? _outputFileName;
  String _outputFormat = 'rtf'; // Default to RTF for Word compatibility

  Future<void> _handleFileSelect(List<PickedFile> files) async {
    if (files.isEmpty) return;
    setState(() {
      _pickedFile = files.first;
      _error = null;
    });
  }

  Future<void> _convertPdf() async {
    if (_pickedFile == null) {
      setState(() {
        _error = AppLocalizations.of(context)!.pleaseSelectValidPdfFirst;
      });
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isProcessing = true;
      _statusText = l10n.extractingText;
      _error = null;
    });

    final customDirectory =
        Provider.of<SettingsProvider>(context, listen: false).saveDirectory;

    try {
      final bytes = await _pickedFile!.readAsBytes();
      final document = sf_pdf.PdfDocument(inputBytes: bytes);

      final StringBuffer fullText = StringBuffer();
      final totalPages = document.pages.count;
      final textExtractor = sf_pdf.PdfTextExtractor(document);

      for (int i = 0; i < totalPages; i++) {
        setState(() {
          _statusText = l10n.processingPage(i + 1, totalPages);
        });

        try {
          final text =
              textExtractor.extractText(startPageIndex: i, endPageIndex: i);
          if (text.trim().isNotEmpty) {
            fullText.writeln(text);
            fullText.writeln();
          }
        } catch (e) {
          fullText.writeln('[Text extraction failed for page ${i + 1}]');
          fullText.writeln();
        }
      }

      document.dispose();

      final extractedText = fullText.toString().trim();
      if (extractedText.isEmpty ||
          extractedText
              .replaceAll(RegExp(r'\[Text extraction failed.*\]'), '')
              .trim()
              .isEmpty) {
        setState(() {
          _error = l10n.noTextExtractedError;
          _isProcessing = false;
        });
        return;
      }

      final originalName = _pickedFile!.name.replaceAll('.pdf', '');
      final ext = _outputFormat == 'txt' ? 'txt' : 'rtf';
      final outFileName = '$originalName.$ext';

      if (kIsWeb) {
        final content = _outputFormat == 'txt'
            ? extractedText
            : _generateRtfContent(extractedText);
        final outBytes = Uint8List.fromList(content.codeUnits);
        setState(() {
          _outputBytes = outBytes;
          _outputFileName = outFileName;
          _isProcessing = false;
        });
      } else {
        final directory = await FileUtils.getOutputDirectory(customDirectory);
        File outputFile;
        if (_outputFormat == 'txt') {
          outputFile = File('${directory.path}/$outFileName');
          await FileUtils.writeStringAndScan(outputFile, extractedText);
        } else {
          outputFile = File('${directory.path}/$outFileName');
          await FileUtils.writeStringAndScan(
              outputFile, _generateRtfContent(extractedText));
        }
        setState(() {
          _exportedFile = outputFile;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = l10n.failedToExtractText(e.toString());
        _isProcessing = false;
      });
    }
  }

  String _generateRtfContent(String text) {
    final escapedText = text
        .replaceAll('\\', '\\\\')
        .replaceAll('{', '\\{')
        .replaceAll('}', '\\}')
        .replaceAll('\n', '\\par\n');

    final rtfHeader = r'{\rtf1\ansi\ansicpg1252\deff0\nouicompat'
        r'{\fonttbl{\f0\fnil\fcharset0 Calibri;}}'
        r'{\colortbl ;\red0\green0\blue0;}'
        r'\viewkind4\uc1'
        r'\pard\sa200\sl276\slmult1\f0\fs22\lang9 ';

    const rtfFooter = '}';

    return '$rtfHeader$escapedText$rtfFooter';
  }

  void _reset() {
    setState(() {
      _pickedFile = null;
      _exportedFile = null;
      _outputBytes = null;
      _outputFileName = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Column(
      children: [
        Expanded(
          child: _buildContent(appState),
        ),
      ],
    );
  }

  Widget _buildContent(AppState appState) {
    final l10n = AppLocalizations.of(context)!;

    if (_isProcessing) {
      return LoadingSpinner(text: _statusText);
    }

    if (_exportedFile != null || _outputBytes != null) {
      final message = _outputFormat == 'rtf'
          ? l10n.rtfExportSuccess
          : l10n.textExtractSuccess;
      return OperationSuccessScreen(
        file: kIsWeb ? null : _exportedFile,
        bytes: kIsWeb ? _outputBytes : null,
        fileName: kIsWeb ? _outputFileName : null,
        onGoHome: () {
          _reset();
          appState.goHome();
        },
        successMessage: message,
        isPdf: false,
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header Section (Standardized)
              const Icon(Icons.article,
                  size: 64, color: Color(0xFFD946EF)), // Fuchsia
              const SizedBox(height: 16),
              Text(
                l10n.pdfToText,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.toRtfTxt,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              if (_pickedFile == null) ...[
                // Format Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.chooseOutputFormat,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildFormatOption(
                              'rtf',
                              l10n.wordRtf,
                              l10n.bestForEditing,
                              const Color(0xFF8B5CF6),
                            ),
                            const SizedBox(width: 12),
                            _buildFormatOption(
                              'txt',
                              l10n.textTxt,
                              l10n.plainTextOnly,
                              const Color(0xFF3B82F6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FileDropzone(
                  onFileSelect: _handleFileSelect,
                  fileTypeLabel: 'PDF',
                ),
              ] else ...[
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha((0.1 * 255).round()),
                      border: Border.all(
                          color: Colors.red.withAlpha((0.5 * 255).round())),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Selected File View
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.picture_as_pdf,
                                color: Colors.red, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _pickedFile!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    l10n.outputFormatLabel(
                                        _outputFormat.toUpperCase()),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  setState(() => _pickedFile = null),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _convertPdf,
                            icon: const Icon(Icons.transform),
                            label: Text(l10n.convertNow),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatOption(
      String format, String title, String subtitle, Color color) {
    final isSelected = _outputFormat == format;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _outputFormat = format),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withAlpha((0.1 * 255).round())
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? color
                  : Colors.grey.withAlpha((0.3 * 255).round()),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
