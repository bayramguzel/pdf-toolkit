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
import '../widgets/tool_page_badge.dart';
import '../providers/app_state.dart';
import '../widgets/loading_spinner.dart';
import '../widgets/operation_success_screen.dart';

class PdfWatermarkScreen extends StatefulWidget {
  const PdfWatermarkScreen({super.key});

  @override
  State<PdfWatermarkScreen> createState() => _PdfWatermarkScreenState();
}

class _PdfWatermarkScreenState extends State<PdfWatermarkScreen> {
  File? _pdfFile;
  PickedFile? _pickedFile;
  sf_pdf.PdfDocument? _pdfDocument;
  bool _isProcessing = false;
  File? _watermarkedFile;
  Uint8List? _watermarkedBytes;
  String? _watermarkedFileName;
  String _statusText = '';
  final TextEditingController _watermarkController = TextEditingController();
  double _opacity = 0.3;
  double _fontSize = 48.0;
  int _rotationAngle = 45;
  Color _watermarkColor = Colors.grey;
  String _position = 'center';

  @override
  void initState() {
    super.initState();
    _watermarkController.text = 'CONFIDENTIAL';
  }

  Alignment _getPreviewAlignment() {
    switch (_position) {
      case 'top-left':
        return Alignment.topLeft;
      case 'top-right':
        return Alignment.topRight;
      case 'bottom-left':
        return Alignment.bottomLeft;
      case 'bottom-right':
        return Alignment.bottomRight;
      case 'center':
      default:
        return Alignment.center;
    }
  }

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
        _watermarkedFile = null;
        _watermarkedBytes = null;
        _watermarkedFileName = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not read PDF file: $e')),
      );
    }
  }

  Future<void> _addWatermark() async {
    if (_pickedFile == null ||
        _pdfDocument == null ||
        _watermarkController.text.isEmpty) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isProcessing = true;
      _statusText = l10n.addingWatermark;
    });

    final customDirectory =
        Provider.of<SettingsProvider>(context, listen: false).saveDirectory;

    sf_pdf.PdfDocument? document;
    try {
      final bytes = await _pickedFile!.readAsBytes();
      document = sf_pdf.PdfDocument(inputBytes: bytes);
      final font = sf_pdf.PdfStandardFont(
        sf_pdf.PdfFontFamily.helvetica,
        _fontSize,
      );

      final watermarkText = _watermarkController.text;
      final textSize = font.measureString(watermarkText);

      for (int i = 0; i < document.pages.count; i++) {
        if (!mounted) return;
        setState(() {
          _statusText =
              l10n.addingWatermarkToPage(i + 1, document!.pages.count);
        });

        final page = document.pages[i];
        final graphics = page.graphics;

        // Save the current graphics state
        graphics.save();

        // Calculate position
        final pageSize = page.size;
        double x, y;

        switch (_position) {
          case 'top-left':
            x = 50 + textSize.width / 2;
            y = 50 + textSize.height / 2;
            break;
          case 'top-right':
            x = pageSize.width - 50 - textSize.width / 2;
            y = 50 + textSize.height / 2;
            break;
          case 'bottom-left':
            x = 50 + textSize.width / 2;
            y = pageSize.height - 50 - textSize.height / 2;
            break;
          case 'bottom-right':
            x = pageSize.width - 50 - textSize.width / 2;
            y = pageSize.height - 50 - textSize.height / 2;
            break;
          case 'center':
          default:
            x = pageSize.width / 2;
            y = pageSize.height / 2;
            break;
        }

        // Set transparency
        graphics.setTransparency(_opacity);

        // Apply rotation
        if (_rotationAngle != 0) {
          graphics.translateTransform(x, y);
          graphics.rotateTransform(-_rotationAngle.toDouble());
          x = 0;
          y = 0;
        }

        // Draw watermark
        graphics.drawString(
          watermarkText,
          font,
          brush: sf_pdf.PdfSolidBrush(
            sf_pdf.PdfColor(
              (_watermarkColor.r * 255.0).round(),
              (_watermarkColor.g * 255.0).round(),
              (_watermarkColor.b * 255.0).round(),
            ),
          ),
          bounds: Rect.fromLTWH(x, y, 0, 0),
          format: sf_pdf.PdfStringFormat(
            alignment: sf_pdf.PdfTextAlignment.center,
            lineAlignment: sf_pdf.PdfVerticalAlignment.middle,
          ),
        );

        // Restore the graphics state
        graphics.restore();
      }

      final List<int> outputBytes = await document.save();
      document.dispose();
      document = null;

      final outputName = 'watermarked_${_pickedFile!.name}';

      if (kIsWeb) {
        if (!mounted) return;
        setState(() {
          _watermarkedBytes = Uint8List.fromList(outputBytes);
          _watermarkedFileName = outputName;
          _isProcessing = false;
        });
      } else {
        final directory = await FileUtils.getOutputDirectory(customDirectory);
        final outputFile = File('${directory.path}/$outputName');
        await FileUtils.writeAndScan(outputFile, outputBytes);
        if (!mounted) return;
        setState(() {
          _watermarkedFile = outputFile;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorAddingWatermark(e.toString()))),
      );
    } finally {
      document?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_watermarkedFile != null || _watermarkedBytes != null) {
      return Column(
        children: [
          Expanded(
            child: OperationSuccessScreen(
              successMessage: l10n.watermarkAddedSuccessfully,
              file: _watermarkedFile,
              bytes: _watermarkedBytes,
              fileName: _watermarkedFileName,
              onGoHome: () {
                setState(() {
                  _pdfFile = null;
                  _pickedFile = null;
                  _pdfDocument?.dispose();
                  _pdfDocument = null;
                  _watermarkedFile = null;
                  _watermarkedBytes = null;
                  _watermarkedFileName = null;
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
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const ToolPageBadge(tool: ToolType.watermark),
                              const SizedBox(height: 16),
                              Text(
                                l10n.watermarkPdf,
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.addTextImage,
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
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
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
                                    l10n.pagesCount(_pdfDocument!.pages.count),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Live Preview Section
                          Card(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[850]
                                    : Colors.grey[100],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.preview, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.livePreview,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey[400]!,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Stack(
                                        children: [
                                          // Sample page background
                                          Container(
                                            color: Colors.white,
                                            child: Center(
                                              child: Icon(
                                                Icons.description,
                                                size: 80,
                                                color: Colors.grey[300],
                                              ),
                                            ),
                                          ),
                                          // Watermark preview
                                          Align(
                                            alignment: _getPreviewAlignment(),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Transform.rotate(
                                                angle: -_rotationAngle *
                                                    3.14159 /
                                                    180,
                                                child: Opacity(
                                                  opacity: _opacity,
                                                  child: Text(
                                                    _watermarkController
                                                            .text.isEmpty
                                                        ? 'SAMPLE'
                                                        : _watermarkController
                                                            .text,
                                                    style: TextStyle(
                                                      fontSize: _fontSize * 0.5,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: _watermarkColor,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.previewInstructions,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          Text(
                            l10n.watermarkSettings,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _watermarkController,
                            decoration: InputDecoration(
                              labelText: l10n.watermarkText,
                              border: const OutlineInputBorder(),
                              hintText: l10n.enterWatermarkText,
                            ),
                            onChanged: (value) {
                              setState(() {}); // Update preview
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '${l10n.fontSize}: ${_fontSize.toInt()}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Slider(
                            value: _fontSize,
                            min: 12,
                            max: 100,
                            divisions: 88,
                            label: _fontSize.toInt().toString(),
                            onChanged: (value) {
                              setState(() {
                                _fontSize = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${l10n.opacity}: ${(_opacity * 100).toInt()}%',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Slider(
                            value: _opacity,
                            min: 0.1,
                            max: 1.0,
                            divisions: 9,
                            label: '${(_opacity * 100).toInt()}%',
                            onChanged: (value) {
                              setState(() {
                                _opacity = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${l10n.rotation}: $_rotationAngle\u00B0',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Slider(
                            value: _rotationAngle.toDouble(),
                            min: 0,
                            max: 360,
                            divisions: 72,
                            label: '$_rotationAngle\u00B0',
                            onChanged: (value) {
                              setState(() {
                                _rotationAngle = value.toInt();
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${l10n.color}:',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildColorChip(Colors.grey, l10n.grey),
                              _buildColorChip(Colors.red, l10n.red),
                              _buildColorChip(Colors.blue, l10n.blue),
                              _buildColorChip(Colors.green, l10n.green),
                              _buildColorChip(Colors.black, l10n.black),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '${l10n.position}:',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildPositionChip('center', l10n.center),
                              _buildPositionChip('top-left', l10n.topLeft),
                              _buildPositionChip('top-right', l10n.topRight),
                              _buildPositionChip(
                                  'bottom-left', l10n.bottomLeft),
                              _buildPositionChip(
                                  'bottom-right', l10n.bottomRight),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Center(
                            child: FilledButton.icon(
                              onPressed: _watermarkController.text.isNotEmpty
                                  ? _addWatermark
                                  : null,
                              icon: const Icon(Icons.water_drop),
                              label: Text(l10n.addWatermarkButton),
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
                                });
                              },
                              child: Text(l10n.selectDifferentFile),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildColorChip(Color color, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _watermarkColor == color,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _watermarkColor = color;
          });
        }
      },
      avatar: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  Widget _buildPositionChip(String value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _position == value,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _position = value;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _pdfDocument?.dispose();
    _watermarkController.dispose();
    super.dispose();
  }
}
