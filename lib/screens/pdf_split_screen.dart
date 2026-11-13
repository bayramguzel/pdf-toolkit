import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf_pdf;
import 'package:provider/provider.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../providers/settings_provider.dart';
import '../widgets/file_dropzone.dart';
import '../widgets/tool_page_badge.dart';
import '../widgets/loading_spinner.dart';
import '../widgets/operation_success_screen.dart';
import '../utils/file_utils.dart';

class PdfSplitScreen extends StatefulWidget {
  const PdfSplitScreen({super.key});

  @override
  State<PdfSplitScreen> createState() => _PdfSplitScreenState();
}

class _PdfSplitScreenState extends State<PdfSplitScreen> {
  File? _pdfFile;
  PickedFile? _pickedFile;
  sf_pdf.PdfDocument? _pdfDocument;
  int _totalPages = 0;
  final Set<int> _selectedPages = {};
  bool _isLoading = false;
  bool _isSplitting = false;
  String? _error;
  File? _splitFile;
  Uint8List? _splitBytes;
  String? _splitFileName;

  Future<void> _handleFileSelect(List<PickedFile> files) async {
    if (files.isEmpty) return;
    final pf = files.first;

    setState(() {
      _isLoading = true;
      _error = null;
      _pickedFile = pf;
      _pdfFile = pf.isWeb ? null : pf.ioFile;
      _selectedPages.clear();
    });

    try {
      final bytes = await pf.readAsBytes();
      final document = sf_pdf.PdfDocument(inputBytes: bytes);

      setState(() {
        _pdfDocument = document;
        _totalPages = document.pages.count;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading PDF: $e';
        _isLoading = false;
        _pickedFile = null;
        _pdfFile = null;
      });
    }
  }

  void _togglePageSelection(int pageNum) {
    setState(() {
      if (_selectedPages.contains(pageNum)) {
        _selectedPages.remove(pageNum);
      } else {
        _selectedPages.add(pageNum);
      }
    });
  }

  void _selectAllPages() {
    setState(() {
      _selectedPages.addAll(List.generate(_totalPages, (i) => i + 1));
    });
  }

  void _deselectAllPages() {
    setState(() {
      _selectedPages.clear();
    });
  }

  Future<void> _splitPdf() async {
    if (_pdfDocument == null || _selectedPages.isEmpty) {
      setState(() {
        _error = 'Please select at least one page to split.';
      });
      return;
    }

    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final customDirectory = settingsProvider.saveDirectory;

    setState(() {
      _isSplitting = true;
      _error = null;
    });

    sf_pdf.PdfDocument? newDocument;
    try {
      newDocument = sf_pdf.PdfDocument();
      newDocument.pageSettings.margins.all = 0;
      final sortedPages = _selectedPages.toList()..sort();

      for (final pageNum in sortedPages) {
        if (!mounted) return;
        if (pageNum < 1 || pageNum > _pdfDocument!.pages.count) continue;

        final sourcePage = _pdfDocument!.pages[pageNum - 1];

        try {
          // Create new page and draw template preserving exact dimensions
          final template = sourcePage.createTemplate();
          newDocument.pageSettings.size = sourcePage.size;
          newDocument.pageSettings.orientation =
              sourcePage.size.width > sourcePage.size.height
                  ? sf_pdf.PdfPageOrientation.landscape
                  : sf_pdf.PdfPageOrientation.portrait;
          final sf_pdf.PdfPage newPage = newDocument.pages.add();

          newPage.graphics
              .drawPdfTemplate(template, Offset.zero, sourcePage.size);
        } catch (e) {
          // Continue even if a single page fails
          continue;
        }
      }

      final List<int> bytes = await newDocument.save();
      newDocument.dispose();
      newDocument = null;

      final outputName = 'split_${_pickedFile!.name}';

      if (kIsWeb) {
        if (!mounted) return;
        setState(() {
          _splitBytes = Uint8List.fromList(bytes);
          _splitFileName = outputName;
          _isSplitting = false;
        });
      } else {
        final directory = await FileUtils.getOutputDirectory(customDirectory);
        final outputFile = File('${directory.path}/$outputName');
        await FileUtils.writeAndScan(outputFile, bytes);
        if (!mounted) return;
        setState(() {
          _splitFile = outputFile;
          _isSplitting = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to split PDF: $e';
        _isSplitting = false;
      });
    } finally {
      newDocument?.dispose();
    }
  }

  void _reset() {
    _pdfDocument?.dispose();
    setState(() {
      _pdfFile = null;
      _pickedFile = null;
      _pdfDocument = null;
      _totalPages = 0;
      _selectedPages.clear();
      _splitFile = null;
      _splitBytes = null;
      _splitFileName = null;
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

    if (_isLoading) {
      return Column(
        children: [
          Expanded(child: LoadingSpinner(text: l10n.loading)),
        ],
      );
    }

    if (_isSplitting) {
      return Column(
        children: [
          Expanded(child: LoadingSpinner(text: l10n.splitting)),
        ],
      );
    }

    if (_splitFile != null || _splitBytes != null) {
      return Column(
        children: [
          Expanded(
            child: OperationSuccessScreen(
              file: _splitFile,
              bytes: _splitBytes,
              fileName: _splitFileName,
              onGoHome: () {
                _reset();
                appState.goHome();
              },
              successMessage: l10n.success,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ToolPageBadge(tool: ToolType.splitter),
                      const SizedBox(height: 16),
                      Text(
                        l10n.splitPdf,
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.extractPages,
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
          ),
        ],
      );
    }

    return Column(children: [
      Expanded(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                Text(
                  l10n.splitPdf,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.splitInstructions,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[700],
                  ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _selectAllPages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                      ),
                      child: Text(l10n.selectAll),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _deselectAllPages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                      ),
                      child: Text(l10n.deselectAll),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _totalPages,
                  itemBuilder: (context, index) {
                    final pageNum = index + 1;
                    final isSelected = _selectedPages.contains(pageNum);

                    return InkWell(
                      onTap: () => _togglePageSelection(pageNum),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF22D3EE)
                                : Colors.grey[700]!,
                            width: isSelected ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? const Color(0xFF22D3EE)
                                  .withAlpha((0.2 * 255).round())
                              : Colors.grey[850],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF22D3EE)
                                    : Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$pageNum',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF22D3EE),
                                size: 32,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selectedPages.isNotEmpty ? _splitPdf : null,
                    icon: const Icon(Icons.call_split),
                    label: Text('${l10n.splitPdf} (${_selectedPages.length})'),
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
      ))
    ]);
  }
}
