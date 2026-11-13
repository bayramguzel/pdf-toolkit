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

class PdfMergeScreen extends StatefulWidget {
  const PdfMergeScreen({super.key});

  @override
  State<PdfMergeScreen> createState() => _PdfMergeScreenState();
}

class _PdfMergeScreenState extends State<PdfMergeScreen> {
  final List<PickedFile> _pickedFiles = [];
  final List<File> _files = []; // mobile only
  bool _isMerging = false;
  String? _error;
  File? _mergedFile;
  Uint8List? _mergedBytes;
  String? _mergedFileName;

  void _handleFileSelect(List<PickedFile> files) {
    setState(() {
      _error = null;
      final pdfs =
          files.where((f) => (f.path ?? f.name).toLowerCase().endsWith('.pdf'));
      _pickedFiles.addAll(pdfs);
      if (!kIsWeb) {
        _files.addAll(pdfs.map((f) => f.ioFile));
      }
    });
  }

  void _removeFile(int index) {
    setState(() {
      _pickedFiles.removeAt(index);
      if (!kIsWeb) _files.removeAt(index);
    });
  }

  void _reorderFiles(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) newIndex -= 1;
      final pf = _pickedFiles.removeAt(oldIndex);
      _pickedFiles.insert(newIndex, pf);
      if (!kIsWeb) {
        final f = _files.removeAt(oldIndex);
        _files.insert(newIndex, f);
      }
    });
  }

  Future<String> _getPickedFileInfo(PickedFile pf) async {
    try {
      final bytes = await pf.readAsBytes();
      final fileSize = FileUtils.formatFileSize(bytes.length);
      final document = sf_pdf.PdfDocument(inputBytes: bytes);
      final pageCount = document.pages.count;
      document.dispose();
      return '$pageCount page${pageCount > 1 ? 's' : ''} • $fileSize';
    } catch (e) {
      return '';
    }
  }

  Future<void> _mergePdfs() async {
    if (_pickedFiles.length < 2) {
      setState(() {
        _error = 'Please select at least two PDF files to merge.';
      });
      return;
    }

    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final customDirectory = settingsProvider.saveDirectory;

    setState(() {
      _isMerging = true;
      _error = null;
    });

    sf_pdf.PdfDocument? mergedDocument;
    try {
      mergedDocument = sf_pdf.PdfDocument();
      mergedDocument.pageSettings.margins.all = 0;

      for (final pf in _pickedFiles) {
        if (!mounted) return;
        final List<int> bytes = await pf.readAsBytes();
        final sf_pdf.PdfDocument document =
            sf_pdf.PdfDocument(inputBytes: bytes);

        for (int i = 0; i < document.pages.count; i++) {
          try {
            mergedDocument.pageSettings.size = document.pages[i].size;
            mergedDocument.pageSettings.orientation =
                document.pages[i].size.width > document.pages[i].size.height
                    ? sf_pdf.PdfPageOrientation.landscape
                    : sf_pdf.PdfPageOrientation.portrait;
            final sf_pdf.PdfPage newPage = mergedDocument.pages.add();
            newPage.graphics.drawPdfTemplate(document.pages[i].createTemplate(),
                Offset.zero, document.pages[i].size);
          } catch (e) {
            continue;
          }
        }
        document.dispose();
      }

      final List<int> bytes = await mergedDocument.save();
      mergedDocument.dispose();
      mergedDocument = null;

      final outputName = 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (kIsWeb) {
        if (!mounted) return;
        setState(() {
          _mergedBytes = Uint8List.fromList(bytes);
          _mergedFileName = outputName;
          _isMerging = false;
        });
      } else {
        final directory = await FileUtils.getOutputDirectory(customDirectory);
        final outputFile = File('${directory.path}/$outputName');
        await FileUtils.writeAndScan(outputFile, bytes);
        if (!mounted) return;
        setState(() {
          _mergedFile = outputFile;
          _isMerging = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to merge PDFs: $e';
        _isMerging = false;
      });
    } finally {
      mergedDocument?.dispose();
    }
  }

  void _reset() {
    setState(() {
      _pickedFiles.clear();
      _files.clear();
      _mergedFile = null;
      _mergedBytes = null;
      _mergedFileName = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (_isMerging) {
      return Column(
        children: [
          Expanded(
            child: LoadingSpinner(text: l10n.merging),
          ),
        ],
      );
    }

    if (_mergedFile != null || _mergedBytes != null) {
      return Column(
        children: [
          Expanded(
            child: OperationSuccessScreen(
              file: _mergedFile,
              bytes: _mergedBytes,
              fileName: _mergedFileName,
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

    if (_pickedFiles.isEmpty) {
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
                      const ToolPageBadge(tool: ToolType.merger),
                      const SizedBox(height: 16),
                      Text(
                        l10n.mergePdf,
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.combineFiles,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FileDropzone(
                          onFileSelect: _handleFileSelect, allowMultiple: true),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  Text(
                    l10n.mergePdf,
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.mergeInstructions,
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
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _pickedFiles.length,
                    onReorder: _reorderFiles,
                    itemBuilder: (context, index) {
                      final pf = _pickedFiles[index];
                      return Card(
                        key: Key('$index'),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.drag_handle),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22D3EE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                                size: 32,
                              ),
                            ],
                          ),
                          title: Text(
                            pf.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: FutureBuilder<String>(
                            future: _getPickedFileInfo(pf),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(snapshot.data!);
                              }
                              return Text(l10n.loadingInfo);
                            },
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeFile(index),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[850]?.withAlpha((0.5 * 255).round())
                          : Colors.grey[200]?.withAlpha((0.5 * 255).round()),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]!
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FileDropzone(
                      onFileSelect: _handleFileSelect,
                      allowMultiple: true,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickedFiles.length >= 2 ? _mergePdfs : null,
                      icon: const Icon(Icons.merge),
                      label: Text('${l10n.mergePdf} (${_pickedFiles.length})'),
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
      ],
    );
  }
}
