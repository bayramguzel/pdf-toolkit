import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf_pdf;
import '../providers/app_state.dart';
import '../providers/settings_provider.dart';
import '../widgets/file_dropzone.dart';
import '../utils/tool_meta.dart';
import '../widgets/loading_spinner.dart';
import '../widgets/operation_success_screen.dart';
import '../utils/file_utils.dart';

class WordToPdfScreen extends StatefulWidget {
  const WordToPdfScreen({super.key});

  @override
  State<WordToPdfScreen> createState() => _WordToPdfScreenState();
}

class _WordToPdfScreenState extends State<WordToPdfScreen> {
  File? _textFile;
  PickedFile? _pickedFile;
  bool _isConverting = false;
  String? _error;
  File? _pdfFile;
  Uint8List? _pdfBytes;
  String? _pdfFileName;

  Future<void> _handleFileSelect(List<PickedFile> files) async {
    if (files.isEmpty) return;

    final file = files.first;
    final ext = (file.path ?? file.name).toLowerCase();

    if (!ext.endsWith('.txt') && !ext.endsWith('.rtf')) {
      setState(() {
        _error = 'Please select a .txt or .rtf file';
      });
      return;
    }

    setState(() {
      _pickedFile = file;
      _textFile = file.isWeb ? null : file.ioFile;
      _error = null;
    });
  }

  String _stripRtf(String rtf) {
    if (!rtf.startsWith('{\\rtf')) return rtf;
    String text = rtf;
    text = text.replaceAll(RegExp(r'\{\\fonttbl[\s\S]*?\}'), '');
    text = text.replaceAll(RegExp(r'\{\\colortbl[\s\S]*?\}'), '');
    text = text.replaceAll(RegExp(r'\{\\stylesheet[\s\S]*?\}'), '');
    text = text.replaceAll(RegExp(r'\{\\info[\s\S]*?\}'), '');
    // Decode \uN? Unicode escapes (N is a signed 16-bit value)
    text = text.replaceAllMapped(RegExp(r'\\u(-?\d+)\??'),
        (m) => String.fromCharCode(int.parse(m.group(1)!) & 0xFFFF));
    // Decode \'hh hex escapes (Windows-1252 / Latin-1 compatible range)
    text = text.replaceAllMapped(RegExp(r"\\'([0-9a-fA-F]{2})"),
        (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)));
    text = text.replaceAll(RegExp(r'\\par|\\line'), '\n');
    text = text.replaceAll(RegExp(r'\\tab'), '\t');
    text = text.replaceAll(RegExp(r'\\(\w+)(\s|(?=\\)|(?=\}))'), '');
    text = text.replaceAll(RegExp(r'[\{\}]'), '');
    return text.trim();
  }

  Future<void> _convertToPdf() async {
    if (_pickedFile == null) return;

    setState(() {
      _isConverting = true;
      _error = null;
    });

    final customDirectory =
        Provider.of<SettingsProvider>(context, listen: false).saveDirectory;

    sf_pdf.PdfDocument? document;
    try {
      final bytes = await _pickedFile!.readAsBytes();
      String text = utf8.decode(bytes, allowMalformed: true);

      if (_pickedFile!.name.toLowerCase().endsWith('.rtf')) {
        text = _stripRtf(text);
      }

      if (text.trim().isEmpty) {
        throw Exception('File is empty or could not be parsed');
      }

      document = sf_pdf.PdfDocument();

      final sf_pdf.PdfTextElement textElement = sf_pdf.PdfTextElement(
        text: text,
        font: sf_pdf.PdfStandardFont(sf_pdf.PdfFontFamily.helvetica, 12),
      );

      final sf_pdf.PdfLayoutFormat layoutFormat = sf_pdf.PdfLayoutFormat(
        layoutType: sf_pdf.PdfLayoutType.paginate,
        breakType: sf_pdf.PdfLayoutBreakType.fitPage,
      );

      textElement.draw(
        page: document.pages.add(),
        bounds: Rect.fromLTWH(
            40,
            40,
            document.pages[0].getClientSize().width - 80,
            document.pages[0].getClientSize().height - 80),
        format: layoutFormat,
      );

      final List<int> pdfBytes = await document.save();
      document.dispose();
      document = null;

      final originalName = _pickedFile!.name
          .replaceAll(RegExp(r'\.(txt|rtf)$', caseSensitive: false), '');
      final outputName = '$originalName.pdf';

      if (kIsWeb) {
        if (!mounted) return;
        setState(() {
          _pdfBytes = Uint8List.fromList(pdfBytes);
          _pdfFileName = outputName;
          _isConverting = false;
        });
      } else {
        final directory = await FileUtils.getOutputDirectory(customDirectory);
        final outputFile = File('${directory.path}/$outputName');
        await FileUtils.writeAndScan(outputFile, pdfBytes);
        if (!mounted) return;
        setState(() {
          _pdfFile = outputFile;
          _isConverting = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to convert text to PDF: $e';
        _isConverting = false;
      });
    } finally {
      document?.dispose();
    }
  }

  void _reset() {
    setState(() {
      _textFile = null;
      _pickedFile = null;
      _pdfFile = null;
      _pdfBytes = null;
      _pdfFileName = null;
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

    if (_isConverting) {
      return const LoadingSpinner(text: 'Converting text to PDF...');
    }

    if (_pdfFile != null || _pdfBytes != null) {
      return OperationSuccessScreen(
        file: _pdfFile,
        bytes: _pdfBytes,
        fileName: _pdfFileName,
        onGoHome: () {
          _reset();
          appState.goHome();
        },
        successMessage: 'Text file converted to PDF successfully!',
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
              const Icon(Icons.text_snippet,
                  size: 64, color: Color(0xFF7C3AED)),
              const SizedBox(height: 16),
              Text(
                l10n.textToPdf,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.convertTxt,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
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
              if (_pickedFile == null) ...[
                FileDropzone(
                  icon: ToolMeta.of(ToolType.wordToPdf).icon,
                  accent: ToolMeta.of(ToolType.wordToPdf).color,
                  onFileSelect: _handleFileSelect,
                  fileTypeLabel: 'Text/RTF',
                  allowedExtensions: const ['txt', 'rtf'],
                ),
              ] else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.text_snippet,
                                color: Color(0xFF8B5CF6), size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _pickedFile!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() {
                                _pickedFile = null;
                                _textFile = null;
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _convertToPdf,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: Text(l10n.convertToPdf),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
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
