import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf_pdf;
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../providers/settings_provider.dart';
import '../utils/file_utils.dart';
import '../widgets/file_dropzone.dart';
import '../utils/tool_meta.dart';
import '../widgets/loading_spinner.dart';
import '../widgets/operation_success_screen.dart';

class PdfRotateScreen extends StatefulWidget {
  const PdfRotateScreen({super.key});

  @override
  State<PdfRotateScreen> createState() => _PdfRotateScreenState();
}

class _PdfRotateScreenState extends State<PdfRotateScreen> {
  File? _pdfFile;
  PickedFile? _pickedFile;
  sf_pdf.PdfDocument? _pdfDocument;
  bool _isProcessing = false;
  File? _rotatedFile;
  Uint8List? _rotatedBytes;
  String? _rotatedFileName;
  String _statusText = '';
  int _rotationAngle = 90;
  List<bool> _selectedPages = [];

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
        _selectedPages = List.filled(document.pages.count, true);
        _rotatedFile = null;
        _rotatedBytes = null;
        _rotatedFileName = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not read PDF file: $e')),
      );
    }
  }

  Future<void> _rotatePdf() async {
    if (_pickedFile == null || _pdfDocument == null) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isProcessing = true;
      _statusText = l10n.rotatingPdf;
    });

    final customDirectory =
        Provider.of<SettingsProvider>(context, listen: false).saveDirectory;

    sf_pdf.PdfDocument? document;
    try {
      final bytes = await _pickedFile!.readAsBytes();
      document = sf_pdf.PdfDocument(inputBytes: bytes);

      int rotateDelta;
      switch (_rotationAngle) {
        case 90:
          rotateDelta = 1;
          break;
        case 180:
          rotateDelta = 2;
          break;
        case 270:
          rotateDelta = 3;
          break;
        default:
          rotateDelta = 0;
      }

      for (int i = 0; i < document.pages.count; i++) {
        if (!mounted) return;
        if (_selectedPages[i]) {
          if (rotateDelta != 0) {
            setState(() {
              _statusText = l10n.rotatingPage(i + 1, document!.pages.count);
            });
            final current = document.pages[i].rotation;
            document.pages[i].rotation = sf_pdf
                .PdfPageRotateAngle.values[(current.index + rotateDelta) % 4];
          }
        }
      }

      final List<int> outputBytes = await document.save();
      document.dispose();
      document = null;

      final outputName = 'rotated_${_pickedFile!.name}';

      if (kIsWeb) {
        if (!mounted) return;
        setState(() {
          _rotatedBytes = Uint8List.fromList(outputBytes);
          _rotatedFileName = outputName;
          _isProcessing = false;
        });
      } else {
        final directory = await FileUtils.getOutputDirectory(customDirectory);
        final outputFile = File('${directory.path}/$outputName');
        await FileUtils.writeAndScan(outputFile, outputBytes);
        if (!mounted) return;
        setState(() {
          _rotatedFile = outputFile;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorRotatingPdf(e.toString()))),
      );
    } finally {
      document?.dispose();
    }
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

    if (_rotatedFile != null || _rotatedBytes != null) {
      return OperationSuccessScreen(
        file: _rotatedFile,
        bytes: _rotatedBytes,
        fileName: _rotatedFileName,
        onGoHome: () {
          setState(() {
            _pdfFile = null;
            _pickedFile = null;
            _pdfDocument?.dispose();
            _pdfDocument = null;
            _rotatedFile = null;
            _rotatedBytes = null;
            _rotatedFileName = null;
            _selectedPages = [];
          });
          appState.goHome();
        },
        successMessage: l10n.pdfRotatedSuccessfully,
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
              const Icon(Icons.rotate_right,
                  size: 64, color: Color(0xFFFB923C)),
              const SizedBox(height: 16),
              Text(
                l10n.rotatePdf,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.turnPages,
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
                FileDropzone(
                    icon: ToolMeta.of(ToolType.rotate).icon,
                    accent: ToolMeta.of(ToolType.rotate).color,
                    onFileSelect: _selectPdfFile),
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                    l10n.pagesCount(_pdfDocument!.pages.count),
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
                              onPressed: () => setState(() {
                                _pdfFile = null;
                                _pickedFile = null;
                                _pdfDocument?.dispose();
                                _pdfDocument = null;
                              }),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        Text(
                          l10n.rotationAngle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRotationOption(90, '90\u00B0'),
                            _buildRotationOption(180, '180\u00B0'),
                            _buildRotationOption(270, '270\u00B0'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.selectPages,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            _selectedPages.length,
                            (index) => FilterChip(
                              label: Text(l10n.pageNumber(index + 1)),
                              selected: _selectedPages[index],
                              onSelected: (selected) {
                                setState(() {
                                  _selectedPages[index] = selected;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _selectedPages.contains(true)
                                ? _rotatePdf
                                : null,
                            icon: const Icon(Icons.rotate_right),
                            label: Text(l10n.rotatePdfButton),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF59E0B),
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

  Widget _buildRotationOption(int angle, String label) {
    final isSelected = _rotationAngle == angle;
    return InkWell(
      onTap: () => setState(() => _rotationAngle = angle),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF59E0B).withAlpha((0.1 * 255).round())
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF59E0B)
                : Colors.grey.withAlpha((0.3 * 255).round()),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFFF59E0B) : null,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pdfDocument?.dispose();
    super.dispose();
  }
}
