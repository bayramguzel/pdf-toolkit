import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf_pdf;
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/settings_provider.dart';
import '../utils/file_utils.dart';
import '../widgets/file_dropzone.dart';
import '../widgets/loading_spinner.dart';
import '../widgets/operation_success_screen.dart';

class PdfToTextScreen extends StatefulWidget {
  const PdfToTextScreen({super.key});

  @override
  State<PdfToTextScreen> createState() => _PdfToTextScreenState();
}

class _PdfToTextScreenState extends State<PdfToTextScreen> {
  PickedFile? _pickedFile;
  bool _isProcessing = false;
  String _statusText = '';
  String? _error;
  File? _exportedFile;
  Uint8List? _outputBytes;
  String? _outputFileName;
  String _outputFormat = 'txt';

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
        _error = 'Please select a PDF file first.';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusText = 'Extracting text...';
      _error = null;
    });

    final customDirectory =
        Provider.of<SettingsProvider>(context, listen: false).saveDirectory;

    sf_pdf.PdfDocument? document;
    try {
      final bytes = await _pickedFile!.readAsBytes();
      document = sf_pdf.PdfDocument(inputBytes: bytes);

      final StringBuffer fullText = StringBuffer();
      final totalPages = document.pages.count;
      final textExtractor = sf_pdf.PdfTextExtractor(document);

      for (int i = 0; i < totalPages; i++) {
        if (!mounted) return;
        setState(() {
          _statusText = 'Processing page ${i + 1} of $totalPages...';
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
      document = null;

      final extractedText = fullText.toString().trim();
      if (extractedText.isEmpty ||
          extractedText
              .replaceAll(RegExp(r'\[Text extraction failed.*\]'), '')
              .trim()
              .isEmpty) {
        if (!mounted) return;
        setState(() {
          _error =
              'No text could be extracted from this PDF. The file may contain only images or have text in a non-standard format.';
          _isProcessing = false;
        });
        return;
      }

      final originalName = _pickedFile!.name
          .replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
      final ext = _outputFormat == 'txt' ? 'txt' : 'rtf';
      final outFileName = '$originalName.$ext';

      if (kIsWeb) {
        final content = _outputFormat == 'txt'
            ? extractedText
            : _generateRtfContent(extractedText);
        if (!mounted) return;
        setState(() {
          _outputBytes = Uint8List.fromList(utf8.encode(content));
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
        if (!mounted) return;
        setState(() {
          _exportedFile = outputFile;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to extract text: $e';
        _isProcessing = false;
      });
    } finally {
      document?.dispose();
    }
  }

  String _generateRtfContent(String text) {
    // Escape special RTF characters
    final escapedText = text
        .replaceAll('\\', '\\\\')
        .replaceAll('{', '\\{')
        .replaceAll('}', '\\}')
        .replaceAll('\n', '\\par\n');

    // Encode non-ASCII characters as \uN? escapes so the RTF stays ASCII-safe
    final StringBuffer buffer = StringBuffer();
    for (final int rune in escapedText.runes) {
      if (rune < 128) {
        buffer.writeCharCode(rune);
      } else {
        buffer.write('\\u${rune & 0xFFFF}?');
      }
    }

    final rtfHeader = r'{\rtf1\ansi\deff0\nouicompat'
        r'{\fonttbl{\f0\fnil\fcharset0 Calibri;}}'
        r'{\colortbl ;\red0\green0\blue0;}'
        r'\viewkind4\uc1'
        r'\pard\sa200\sl276\slmult1\f0\fs22\lang9 ';

    const rtfFooter = '}';

    return '$rtfHeader${buffer.toString()}$rtfFooter';
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

    if (_isProcessing) {
      return Column(
          children: [Expanded(child: LoadingSpinner(text: _statusText))]);
    }

    if (_exportedFile != null || _outputBytes != null) {
      final message = _outputFormat == 'rtf'
          ? 'Document exported successfully as RTF! You can open it with Microsoft Word.'
          : 'Text extracted successfully!';
      return Column(children: [
        Expanded(
            child: OperationSuccessScreen(
          file: kIsWeb ? null : _exportedFile,
          bytes: kIsWeb ? _outputBytes : null,
          fileName: kIsWeb ? _outputFileName : null,
          onGoHome: () {
            _reset();
            appState.goHome();
          },
          successMessage: message,
          isPdf: false,
        ))
      ]);
    }

    if (_pickedFile == null) {
      return Column(children: [
        Expanded(
            child: Center(
                child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Extract to TXT/RTF',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Extract all text from your PDF into TXT or RTF format.',
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
                      const Text(
                        'Output Format',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _outputFormat = 'txt'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _outputFormat == 'txt'
                                      ? const Color(0xFF22D3EE)
                                      : Colors.grey[700],
                                  border: Border.all(
                                    color: _outputFormat == 'txt'
                                        ? const Color(0xFF22D3EE)
                                        : Colors.grey[600]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'TXT',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Plain Text',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _outputFormat = 'rtf'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _outputFormat == 'rtf'
                                      ? const Color(0xFF8B5CF6)
                                      : Colors.grey[700],
                                  border: Border.all(
                                    color: _outputFormat == 'rtf'
                                        ? const Color(0xFF8B5CF6)
                                        : Colors.grey[600]!,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'RTF',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Word Compatible',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Note: Exporting preserves text content but not complex layouts or images.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FileDropzone(onFileSelect: _handleFileSelect),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => appState.goHome(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        )))
      ]);
    }

    return Column(children: [
      Expanded(
          child: Center(
              child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              const Text(
                'Export PDF',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready to export text from your document as a ${_outputFormat.toUpperCase()} file.',
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
                  child: Text(
                    _pickedFile!.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _convertPdf,
                    icon: const Icon(Icons.text_fields),
                    label: const Text('Export Text'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => appState.goHome(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      )))
    ]);
  }
}
