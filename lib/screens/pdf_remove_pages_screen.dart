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
import '../utils/tool_meta.dart';
import '../providers/app_state.dart';
import '../widgets/loading_spinner.dart';
import '../widgets/operation_success_screen.dart';

class PdfRemovePagesScreen extends StatefulWidget {
  const PdfRemovePagesScreen({super.key});

  @override
  State<PdfRemovePagesScreen> createState() => _PdfRemovePagesScreenState();
}

class _PdfRemovePagesScreenState extends State<PdfRemovePagesScreen> {
  File? _pdfFile;
  PickedFile? _pickedFile;
  sf_pdf.PdfDocument? _pdfDocument;
  bool _isProcessing = false;
  File? _outputFile;
  Uint8List? _outputBytes;
  String? _outputFileName;
  String _statusText = '';
  final Set<int> _pagesToRemove = {};

  Future<void> _selectPdfFile(List<PickedFile> files) async {
    if (files.isEmpty) return;

    final file = files.first;
    try {
      final bytes = await file.readAsBytes();
      final document = sf_pdf.PdfDocument(inputBytes: bytes);
      if (!mounted) {
        document.dispose();
        return;
      }
      setState(() {
        _pickedFile = file;
        _pdfFile = file.isWeb ? null : file.ioFile;
        _pdfDocument = document;
        _pagesToRemove.clear();
        _outputFile = null;
        _outputBytes = null;
        _outputFileName = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not read PDF file: $e')),
      );
    }
  }

  Future<void> _removePages() async {
    if (_pickedFile == null || _pdfDocument == null || _pagesToRemove.isEmpty) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final customDirectory =
        Provider.of<SettingsProvider>(context, listen: false).saveDirectory;

    if (_pagesToRemove.length >= _pdfDocument!.pages.count) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotRemoveAllPages)),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusText = l10n.removingPages;
    });

    sf_pdf.PdfDocument? sourceDocument;
    sf_pdf.PdfDocument? outputDocument;
    try {
      final bytes = await _pickedFile!.readAsBytes();
      sourceDocument = sf_pdf.PdfDocument(inputBytes: bytes);
      outputDocument = sf_pdf.PdfDocument();
      outputDocument.pageSettings.margins.all = 0;

      final totalPages = sourceDocument.pages.count;

      for (int i = 0; i < totalPages; i++) {
        if (!_pagesToRemove.contains(i)) {
          if (!mounted) return;
          setState(() {
            _statusText = l10n.processingPage(i + 1, totalPages);
          });
          final sourcePage = sourceDocument.pages[i];
          final template = sourcePage.createTemplate();
          outputDocument.pageSettings.size = sourcePage.size;
          outputDocument.pageSettings.orientation =
              sourcePage.size.width > sourcePage.size.height
                  ? sf_pdf.PdfPageOrientation.landscape
                  : sf_pdf.PdfPageOrientation.portrait;
          outputDocument.pages
              .add()
              .graphics
              .drawPdfTemplate(template, Offset.zero, sourcePage.size);
        }
      }

      sourceDocument.dispose();
      sourceDocument = null;
      final List<int> outputBytes = await outputDocument.save();
      outputDocument.dispose();
      outputDocument = null;

      final outputName = 'removed_pages_${_pickedFile!.name}';

      if (kIsWeb) {
        if (!mounted) return;
        setState(() {
          _outputBytes = Uint8List.fromList(outputBytes);
          _outputFileName = outputName;
          _isProcessing = false;
        });
      } else {
        final directory = await FileUtils.getOutputDirectory(customDirectory);
        final outputFile = File('${directory.path}/$outputName');
        await FileUtils.writeAndScan(outputFile, outputBytes);
        if (!mounted) return;
        setState(() {
          _outputFile = outputFile;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorRemovingPages(e.toString()))),
      );
    } finally {
      sourceDocument?.dispose();
      outputDocument?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_outputFile != null || _outputBytes != null) {
      return Column(
        children: [
          Expanded(
            child: OperationSuccessScreen(
              successMessage: l10n.pagesRemovedSuccessfully,
              file: _outputFile,
              bytes: _outputBytes,
              fileName: _outputFileName,
              onGoHome: () {
                setState(() {
                  _pdfFile = null;
                  _pickedFile = null;
                  _pdfDocument?.dispose();
                  _pdfDocument = null;
                  _outputFile = null;
                  _outputBytes = null;
                  _outputFileName = null;
                  _pagesToRemove.clear();
                });
              },
              isPdf: true,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: _isProcessing
              ? LoadingSpinner(text: _statusText)
              : _pickedFile == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.delete_sweep,
                                size: 64, color: Color(0xFFF87171)), // Red
                            const SizedBox(height: 16),
                            Text(
                              l10n.removePdf,
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.deletePages,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            FileDropzone(
                              icon: ToolMeta.of(ToolType.removePages).icon,
                              accent: ToolMeta.of(ToolType.removePages).color,
                              onFileSelect: _selectPdfFile,
                              allowMultiple: false,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
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
                                  if (_pagesToRemove.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.pagesToRemove(_pagesToRemove.length),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                    ),
                                    Text(
                                      l10n.remainingPages(
                                          _pdfDocument!.pages.count -
                                              _pagesToRemove.length),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.selectPagesToRemove,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _pagesToRemove.clear();
                                        for (int i = 0;
                                            i < _pdfDocument!.pages.count;
                                            i++) {
                                          _pagesToRemove.add(i);
                                        }
                                      });
                                    },
                                    child: Text(l10n.selectAll),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _pagesToRemove.clear();
                                      });
                                    },
                                    child: Text(l10n.clear),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: _pdfDocument!.pages.count,
                            itemBuilder: (context, index) {
                              final isSelected = _pagesToRemove.contains(index);
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _pagesToRemove.remove(index);
                                    } else {
                                      _pagesToRemove.add(index);
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(context)
                                              .colorScheme
                                              .outlineVariant,
                                      width: isSelected ? 3 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .error
                                            .withAlpha((0.1 * 255).round())
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.delete
                                            : Icons.insert_drive_file,
                                        size: 48,
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .error
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.pageNumber(index + 1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                      if (isSelected)
                                        Text(
                                          l10n.toRemove,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          Center(
                            child: FilledButton.icon(
                              onPressed: _pagesToRemove.isNotEmpty &&
                                      _pagesToRemove.length <
                                          _pdfDocument!.pages.count
                                  ? _removePages
                                  : null,
                              icon: const Icon(Icons.delete_outline),
                              label: Text(_pagesToRemove.isEmpty
                                  ? l10n.selectPagesToRemoveButton
                                  : l10n.removePagesCountButton(
                                      _pagesToRemove.length)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _pdfFile = null;
                                  _pickedFile = null;
                                  _pdfDocument?.dispose();
                                  _pdfDocument = null;
                                  _pagesToRemove.clear();
                                });
                              },
                              child: Text(l10n.selectDifferentFile),
                            ),
                          ),
                        ],
                      ),
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
