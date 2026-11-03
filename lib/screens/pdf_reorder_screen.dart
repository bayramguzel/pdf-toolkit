import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf_pdf;
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../utils/file_utils.dart';
import '../widgets/file_dropzone.dart';
import '../widgets/loading_spinner.dart';
import '../widgets/operation_success_screen.dart';

class PdfReorderScreen extends StatefulWidget {
  const PdfReorderScreen({super.key});

  @override
  State<PdfReorderScreen> createState() => _PdfReorderScreenState();
}

class _PdfReorderScreenState extends State<PdfReorderScreen> {
  File? _pdfFile;
  PickedFile? _pickedFile;
  sf_pdf.PdfDocument? _pdfDocument;
  bool _isProcessing = false;
  File? _reorderedFile;
  Uint8List? _reorderedBytes;
  String? _reorderedFileName;
  String _statusText = '';
  List<int> _pageOrder = [];

  Future<void> _selectPdfFile(List<PickedFile> files) async {
    if (files.isEmpty) return;

    final file = files.first;
    final bytes = await file.readAsBytes();
    final document = sf_pdf.PdfDocument(inputBytes: bytes);

    setState(() {
      _pickedFile = file;
      _pdfFile = file.isWeb ? null : file.ioFile;
      _pdfDocument = document;
      _pageOrder = List.generate(document.pages.count, (index) => index);
      _reorderedFile = null;
      _reorderedBytes = null;
      _reorderedFileName = null;
    });
  }

  Future<void> _reorderPages() async {
    if (_pickedFile == null || _pdfDocument == null) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isProcessing = true;
      _statusText = l10n.reorderingPages;
    });

    final customDirectory =
        Provider.of<SettingsProvider>(context, listen: false).saveDirectory;

    try {
      final bytes = await _pickedFile!.readAsBytes();
      final sourceDocument = sf_pdf.PdfDocument(inputBytes: bytes);
      final outputDocument = sf_pdf.PdfDocument();
      outputDocument.pageSettings.margins.all = 0;

      for (int i = 0; i < _pageOrder.length; i++) {
        setState(() {
          _statusText = l10n.processingPage(i + 1, _pageOrder.length);
        });

        final sourcePageIndex = _pageOrder[i];
        final sourcePage = sourceDocument.pages[sourcePageIndex];

        final template = sourcePage.createTemplate();
        outputDocument.pageSettings.size = sourcePage.size;
        outputDocument.pageSettings.orientation =
            sourcePage.size.width > sourcePage.size.height
                ? sf_pdf.PdfPageOrientation.landscape
                : sf_pdf.PdfPageOrientation.portrait;
        final sf_pdf.PdfPage newPage = outputDocument.pages.add();
        newPage.graphics
            .drawPdfTemplate(template, Offset.zero, sourcePage.size);
      }

      sourceDocument.dispose();
      final List<int> outputBytes = await outputDocument.save();
      outputDocument.dispose();

      final outputName = 'reordered_${_pickedFile!.name}';

      if (kIsWeb) {
        setState(() {
          _reorderedBytes = Uint8List.fromList(outputBytes);
          _reorderedFileName = outputName;
          _isProcessing = false;
        });
      } else {
        final directory = await FileUtils.getOutputDirectory(customDirectory);
        final outputFile = File('${directory.path}/$outputName');
        await FileUtils.writeAndScan(outputFile, outputBytes);
        setState(() {
          _reorderedFile = outputFile;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorReorderingPages(e.toString()))),
      );
    }
  }

  void _movePageUp(int index) {
    if (index > 0) {
      setState(() {
        final temp = _pageOrder[index];
        _pageOrder[index] = _pageOrder[index - 1];
        _pageOrder[index - 1] = temp;
      });
    }
  }

  void _movePageDown(int index) {
    if (index < _pageOrder.length - 1) {
      setState(() {
        final temp = _pageOrder[index];
        _pageOrder[index] = _pageOrder[index + 1];
        _pageOrder[index + 1] = temp;
      });
    }
  }

  void _movePageToTop(int index) {
    if (index > 0) {
      setState(() {
        final page = _pageOrder.removeAt(index);
        _pageOrder.insert(0, page);
      });
    }
  }

  void _movePageToBottom(int index) {
    if (index < _pageOrder.length - 1) {
      setState(() {
        final page = _pageOrder.removeAt(index);
        _pageOrder.add(page);
      });
    }
  }

  void _resetOrder() {
    setState(() {
      _pageOrder = List.generate(_pdfDocument!.pages.count, (index) => index);
    });
  }

  void _reverseOrder() {
    setState(() {
      _pageOrder = _pageOrder.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_reorderedFile != null || _reorderedBytes != null) {
      return Column(children: [
        Expanded(
            child: OperationSuccessScreen(
          successMessage: l10n.pagesReorderedSuccessfully,
          file: _reorderedFile,
          bytes: _reorderedBytes,
          fileName: _reorderedFileName,
          onGoHome: () {
            setState(() {
              _pdfFile = null;
              _pickedFile = null;
              _pdfDocument?.dispose();
              _pdfDocument = null;
              _reorderedFile = null;
              _reorderedBytes = null;
              _reorderedFileName = null;
              _pageOrder = [];
            });
          },
          isPdf: true,
        ))
      ]);
    }

    return Column(
      children: [
        if (_pickedFile != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _resetOrder,
                  icon: const Icon(Icons.refresh),
                  tooltip: l10n.resetOrder,
                ),
                IconButton(
                  onPressed: _reverseOrder,
                  icon: const Icon(Icons.flip),
                  tooltip: l10n.reverseOrder,
                ),
              ],
            ),
          ),
        Expanded(
          child: _isProcessing
              ? LoadingSpinner(text: _statusText)
              : _pickedFile == null
                  ? Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.reorder,
                                  size: 64, color: Color(0xFF818CF8)), // Indigo
                              const SizedBox(height: 16),
                              Text(
                                l10n.reorderPdf,
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.arrangePages,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              FileDropzone(
                                onFileSelect: _selectPdfFile,
                                allowMultiple: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.selectedFile,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(_pickedFile!.name),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.totalPages(_pdfDocument!.pages.count),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.reorderInstructions,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ReorderableListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: _pageOrder.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }
                                final item = _pageOrder.removeAt(oldIndex);
                                _pageOrder.insert(newIndex, item);
                              });
                            },
                            itemBuilder: (context, index) {
                              final pageNumber = _pageOrder[index] + 1;
                              return Card(
                                key: ValueKey(_pageOrder[index]),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.drag_handle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 8),
                                      CircleAvatar(
                                        child: Text('${index + 1}'),
                                      ),
                                    ],
                                  ),
                                  title: Text(l10n.pageNumber(pageNumber)),
                                  subtitle:
                                      Text(l10n.originalPosition(pageNumber)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.vertical_align_top),
                                        onPressed: index > 0
                                            ? () => _movePageToTop(index)
                                            : null,
                                        tooltip: l10n.moveToTop,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_upward),
                                        onPressed: index > 0
                                            ? () => _movePageUp(index)
                                            : null,
                                        tooltip: l10n.moveUp,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_downward),
                                        onPressed: index < _pageOrder.length - 1
                                            ? () => _movePageDown(index)
                                            : null,
                                        tooltip: l10n.moveDown,
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.vertical_align_bottom),
                                        onPressed: index < _pageOrder.length - 1
                                            ? () => _movePageToBottom(index)
                                            : null,
                                        tooltip: l10n.moveToBottom,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              FilledButton.icon(
                                onPressed: _reorderPages,
                                icon: const Icon(Icons.save),
                                label: Text(l10n.saveReorderedPdf),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _pdfFile = null;
                                    _pickedFile = null;
                                    _pdfDocument?.dispose();
                                    _pdfDocument = null;
                                    _pageOrder = [];
                                  });
                                },
                                child: Text(l10n.selectDifferentFile),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pdfDocument?.dispose();
    super.dispose();
  }
}
