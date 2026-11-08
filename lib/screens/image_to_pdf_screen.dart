import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../providers/settings_provider.dart';
import '../widgets/file_dropzone.dart';
import '../widgets/loading_spinner.dart';
import '../widgets/operation_success_screen.dart';
import '../utils/file_utils.dart';
import '../utils/platform_helper.dart';

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  final List<PickedFile> _pickedImages = [];
  final List<File> _imageFiles = []; // mobile only
  bool _isConverting = false;
  String? _error;
  File? _pdfFile;
  Uint8List? _pdfBytes;
  String? _pdfFileName;
  String _pageSize = 'A4';
  String _orientation = 'portrait';
  double _margin = 0.0;
  int _imagesPerPage = 1;
  bool _autoEnhanceColors = true;

  void _handleFileSelect(List<PickedFile> files) {
    setState(() {
      _error = null;
      final images = files.where((f) {
        final ext = (f.path ?? f.name).toLowerCase();
        return ext.endsWith('.jpg') ||
            ext.endsWith('.jpeg') ||
            ext.endsWith('.png') ||
            ext.endsWith('.bmp') ||
            ext.endsWith('.gif') ||
            ext.endsWith('.heic') ||
            ext.endsWith('.heif');
      });
      _pickedImages.addAll(images);
      if (!kIsWeb) {
        _imageFiles.addAll(images.map((f) => f.ioFile));
      }
    });
  }

  Future<void> _pickMoreImages() async {
    try {
      // iOS: offer Photos as well as Files.
      if (PlatformHelper.isIOS) {
        final photos = await FileDropzone.pickImagesWithSourceSheet(context);
        if (photos != null) {
          if (photos.isNotEmpty) _handleFileSelect(photos);
          return;
        }
      }

      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'gif', 'heic', 'heif'],
        allowMultiple: true,
        withData: kIsWeb,
      );
      if (result != null) {
        final picked = <PickedFile>[];
        for (final pf in result.files) {
          if (kIsWeb) {
            if (pf.bytes != null) {
              picked.add(PickedFile.fromWeb(name: pf.name, bytes: pf.bytes!));
            }
          } else if (pf.path != null) {
            final file = File(pf.path!);
            picked.add(await FileDropzone.normalizeImage(
              PickedFile.fromMobile(file),
            ));
          }
        }
        _handleFileSelect(picked);
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking images: $e';
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _pickedImages.removeAt(index);
      if (!kIsWeb) _imageFiles.removeAt(index);
    });
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) newIndex -= 1;
      final pf = _pickedImages.removeAt(oldIndex);
      _pickedImages.insert(newIndex, pf);
      if (!kIsWeb) {
        final f = _imageFiles.removeAt(oldIndex);
        _imageFiles.insert(newIndex, f);
      }
    });
  }

  img.Image _enhanceImageColors(img.Image image) {
    // Create a copy to modify
    final enhanced = img.Image.from(image);

    // Enhance brightness and contrast to make greyish scans look like white paper
    for (int y = 0; y < enhanced.height; y++) {
      for (int x = 0; x < enhanced.width; x++) {
        final pixel = enhanced.getPixel(x, y);

        // Extract RGB values
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Check if pixel is greyish (similar R, G, B values and relatively bright)
        final isGreyish =
            (r - g).abs() < 30 && (g - b).abs() < 30 && (r - b).abs() < 30;
        final brightness = (r + g + b) / 3;

        if (isGreyish && brightness > 120) {
          // Boost brightness towards white for light grey backgrounds
          final boost = ((brightness - 120) / (255 - 120)) * 0.6;
          r = (r + (255 - r) * boost).round().clamp(0, 255);
          g = (g + (255 - g) * boost).round().clamp(0, 255);
          b = (b + (255 - b) * boost).round().clamp(0, 255);
        }

        // Apply slight contrast boost
        final contrastFactor = 1.2;
        r = (((r / 255.0 - 0.5) * contrastFactor + 0.5) * 255)
            .round()
            .clamp(0, 255);
        g = (((g / 255.0 - 0.5) * contrastFactor + 0.5) * 255)
            .round()
            .clamp(0, 255);
        b = (((b / 255.0 - 0.5) * contrastFactor + 0.5) * 255)
            .round()
            .clamp(0, 255);

        enhanced.setPixelRgba(x, y, r, g, b, pixel.a.toInt());
      }
    }

    return enhanced;
  }

  Future<void> _convertToPdf() async {
    if (_pickedImages.isEmpty) {
      setState(() {
        _error = 'Please select at least one image file.';
      });
      return;
    }

    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final customDirectory = settingsProvider.saveDirectory;

    setState(() {
      _isConverting = true;
      _error = null;
    });

    PdfDocument? document;
    try {
      document = PdfDocument();
      document.pageSettings.margins.all = 0;
      final pageSize = _getPageSize();
      document.pageSettings.size = pageSize;

      for (int i = 0; i < _pickedImages.length; i += _imagesPerPage) {
        final page = document.pages.add();
        final availableWidth = pageSize.width - (_margin * 2);
        final availableHeight = pageSize.height - (_margin * 2);

        int imagesInThisPage =
            (_pickedImages.length - i).clamp(0, _imagesPerPage);

        if (_imagesPerPage == 1) {
          final pf = _pickedImages[i];
          final bytes = await pf.readAsBytes();
          var image = img.decodeImage(bytes);
          if (image == null) continue;

          // Scale down to max 2x PDF page resolution (~150 DPI) to reduce file size
          final maxPx = (availableWidth * 2).round();
          if (image.width > maxPx) {
            image = img.copyResize(image,
                width: maxPx, interpolation: img.Interpolation.linear);
          }

          if (_autoEnhanceColors) {
            image = _enhanceImageColors(image);
          }

          final imageAspect = image.width / image.height;
          final pageAspect = availableWidth / availableHeight;

          double drawWidth, drawHeight;
          if (imageAspect > pageAspect) {
            drawWidth = availableWidth;
            drawHeight = availableWidth / imageAspect;
          } else {
            drawHeight = availableHeight;
            drawWidth = availableHeight * imageAspect;
          }

          final x = _margin + (availableWidth - drawWidth) / 2;
          final y = _margin + (availableHeight - drawHeight) / 2;

          final enhancedBytes = img.encodeJpg(image, quality: 75);

          page.graphics.drawImage(
            PdfBitmap(enhancedBytes),
            Rect.fromLTWH(x, y, drawWidth, drawHeight),
          );
        } else {
          int cols = _imagesPerPage == 2 ? 2 : (_imagesPerPage <= 4 ? 2 : 3);
          int rows = (_imagesPerPage / cols).ceil();

          double cellWidth = availableWidth / cols;
          double cellHeight = availableHeight / rows;

          for (int j = 0; j < imagesInThisPage; j++) {
            final pf = _pickedImages[i + j];
            final bytes = await pf.readAsBytes();
            var image = img.decodeImage(bytes);
            if (image == null) continue;

            int row = j ~/ cols;
            int col = j % cols;

            double cellX = _margin + (col * cellWidth);
            double cellY = _margin + (row * cellHeight);
            double padding = 5.0;

            double maxWidth = cellWidth - (padding * 2);
            double maxHeight = cellHeight - (padding * 2);

            // Scale down to max 2x cell width (~150 DPI) to reduce file size
            final maxCellPx = (maxWidth * 2).round();
            if (image.width > maxCellPx) {
              image = img.copyResize(image,
                  width: maxCellPx, interpolation: img.Interpolation.linear);
            }

            if (_autoEnhanceColors) {
              image = _enhanceImageColors(image);
            }

            final imageAspect = image.width / image.height;
            final cellAspect = maxWidth / maxHeight;

            double drawWidth, drawHeight;
            if (imageAspect > cellAspect) {
              drawWidth = maxWidth;
              drawHeight = maxWidth / imageAspect;
            } else {
              drawHeight = maxHeight;
              drawWidth = maxHeight * imageAspect;
            }

            double x = cellX + padding + (maxWidth - drawWidth) / 2;
            double y = cellY + padding + (maxHeight - drawHeight) / 2;

            final enhancedBytes = img.encodeJpg(image, quality: 75);

            page.graphics.drawImage(
              PdfBitmap(enhancedBytes),
              Rect.fromLTWH(x, y, drawWidth, drawHeight),
            );
          }
        }
      }

      // Apply PDF-level compression to further reduce size
      document.compressionLevel = PdfCompressionLevel.best;
      final pdfBytes = await document.save();
      document.dispose();
      document = null;

      final outputName =
          'images_to_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';

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
        _error = 'Failed to convert images to PDF: $e';
        _isConverting = false;
      });
    } finally {
      document?.dispose();
    }
  }

  Size _getPageSize() {
    double width, height;
    switch (_pageSize) {
      case 'A4':
        width = 595;
        height = 842;
        break;
      case 'Letter':
        width = 612;
        height = 792;
        break;
      case 'Legal':
        width = 612;
        height = 1008;
        break;
      case 'A3':
        width = 842;
        height = 1191;
        break;
      default:
        width = 595;
        height = 842;
    }

    if (_orientation == 'landscape') {
      return Size(height, width);
    }
    return Size(width, height);
  }

  void _reset() {
    setState(() {
      _pickedImages.clear();
      _imageFiles.clear();
      _pdfFile = null;
      _pdfBytes = null;
      _pdfFileName = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (_isConverting) {
      return Column(
          children: [Expanded(child: LoadingSpinner(text: l10n.converting))]);
    }

    if (_pdfFile != null || _pdfBytes != null) {
      return Column(children: [
        Expanded(
            child: OperationSuccessScreen(
          file: _pdfFile,
          bytes: _pdfBytes,
          fileName: _pdfFileName,
          onGoHome: () {
            _reset();
            appState.goHome();
          },
          successMessage: l10n.success,
          isPdf: true,
        ))
      ]);
    }

    if (_pickedImages.isEmpty) {
      return Column(children: [
        Expanded(
            child: Center(
                child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_photo_alternate,
                  size: 64, color: Color(0xFF7C3AED)), // Violet
              const SizedBox(height: 16),
              Text(
                l10n.imageToPdf,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.convert,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FileDropzone(
                onFileSelect: _handleFileSelect,
                allowMultiple: true,
                allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'gif'],
                fileTypeLabel: 'Image',
              ),
            ],
          ),
        )))
      ]);
    }

    return Column(children: [
      Expanded(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Text(
                l10n.imageToPdf,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${_pickedImages.length} image(s) selected. Drag to reorder.',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Page Layout Settings
              Card(
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.settings, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.settings,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Page Size
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.pageSize),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: _pageSize,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'A4',
                                        child: Text('A4 (210 \u00D7 297 mm)')),
                                    DropdownMenuItem(
                                        value: 'Letter',
                                        child:
                                            Text('Letter (8.5 \u00D7 11 in)')),
                                    DropdownMenuItem(
                                        value: 'Legal',
                                        child:
                                            Text('Legal (8.5 \u00D7 14 in)')),
                                    DropdownMenuItem(
                                        value: 'A3',
                                        child: Text('A3 (297 \u00D7 420 mm)')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _pageSize = value);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Orientation
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.orientation),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: _orientation,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'portrait',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.portrait, size: 16),
                                          const SizedBox(width: 8),
                                          Text(l10n.portrait),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'landscape',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.landscape, size: 16),
                                          const SizedBox(width: 8),
                                          Text(l10n.landscape),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _orientation = value);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Images per page
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.imagesPerPage),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            initialValue: _imagesPerPage,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 1,
                                child: Text('1'),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('2'),
                              ),
                              DropdownMenuItem(
                                value: 4,
                                child: Text('4'),
                              ),
                              DropdownMenuItem(
                                value: 6,
                                child: Text('6'),
                              ),
                              DropdownMenuItem(
                                value: 9,
                                child: Text('9'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _imagesPerPage = value);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Margins
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.marginLabel),
                          const SizedBox(height: 8),
                          Text('${_margin.toInt()} pt'),
                          Slider(
                            value: _margin,
                            min: 0,
                            max: 50,
                            divisions: 10,
                            label: '${_margin.toInt()} pt',
                            onChanged: (value) {
                              setState(() => _margin = value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Auto Enhance Colors
                      SwitchListTile(
                        title: Text(l10n.autoEnhanceColors),
                        subtitle: const Text(
                          'Automatically brighten grey backgrounds to white paper tone',
                        ),
                        value: _autoEnhanceColors,
                        onChanged: (value) {
                          setState(() => _autoEnhanceColors = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),

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
                itemCount: _pickedImages.length,
                onReorder: _reorderImages,
                itemBuilder: (context, index) {
                  final pf = _pickedImages[index];
                  return Card(
                    key: ValueKey(pf.name + index.toString()),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: kIsWeb
                          ? const Icon(Icons.image, size: 60)
                          : Image.file(
                              _imageFiles[index],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                      title: Text(
                        pf.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.drag_handle),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _removeImage(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickMoreImages,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addMoreImages),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _convertToPdf,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: Text(l10n.convert),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ))
    ]);
  }
}
