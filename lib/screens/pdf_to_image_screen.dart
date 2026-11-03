import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf_pdf;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/settings_provider.dart';
import '../utils/file_utils.dart';
import '../widgets/file_dropzone.dart';
import '../widgets/loading_spinner.dart';
import '../widgets/image_gallery_success_screen.dart';

class PdfToImageScreen extends StatefulWidget {
  const PdfToImageScreen({super.key});

  @override
  State<PdfToImageScreen> createState() => _PdfToImageScreenState();
}

class _PdfToImageScreenState extends State<PdfToImageScreen> {
  // Mobile result
  List<File> _savedImageFiles = [];
  // Web result
  List<Uint8List> _imageBytes = [];
  List<String> _imageNames = [];

  bool _isLoading = false;
  String _statusText = '';
  String? _error;
  String _outputFormat = 'png';
  int _jpegQuality = 80;

  PickedFile? _pickedFile;

  Future<void> _handleFileSelect(List<PickedFile> files) async {
    if (files.isEmpty) return;
    setState(() {
      _pickedFile = files.first;
      _error = null;
    });
  }

  Future<void> _convertToImages() async {
    if (_pickedFile == null) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
      _statusText = l10n.preparingConversion;
      _error = null;
      _savedImageFiles.clear();
      _imageBytes.clear();
      _imageNames.clear();
    });

    final customDirectory =
        Provider.of<SettingsProvider>(context, listen: false).saveDirectory;

    sf_pdf.PdfDocument? document;
    try {
      final bytes = await _pickedFile!.readAsBytes();
      document = sf_pdf.PdfDocument(inputBytes: bytes);
      final totalPages = document.pages.count;

      Directory? outputDir;
      if (!kIsWeb) {
        final directory = await FileUtils.getOutputDirectory(customDirectory);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        outputDir = Directory('${directory.path}/pdf_images_$timestamp');
        await outputDir.create(recursive: true);
      }

      final bool isJpeg = _outputFormat == 'jpeg';
      final String ext = isJpeg ? 'jpg' : 'png';
      final List<File> imageFiles = [];
      final List<Uint8List> webImages = [];
      final List<String> webNames = [];

      for (int i = 0; i < totalPages; i++) {
        if (!mounted) return;
        setState(() {
          _statusText = l10n.convertingPage(i + 1, totalPages);
        });

        try {
          final raster =
              await Printing.raster(bytes, pages: [i], dpi: 300).first;

          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder);
          final paint = Paint()..color = Colors.white;
          final width = raster.width.toDouble();
          final height = raster.height.toDouble();
          canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
          final image = await raster.toImage();
          canvas.drawImage(image, Offset.zero, Paint());
          image.dispose();
          final picture = recorder.endRecording();
          final finalImage =
              await picture.toImage(width.toInt(), height.toInt());
          final finalWidth = finalImage.width;
          final finalHeight = finalImage.height;

          final Uint8List? imgBytes;
          if (isJpeg) {
            final byteData = await finalImage.toByteData(
                format: ui.ImageByteFormat.rawRgba);
            finalImage.dispose();
            if (byteData == null) continue;
            final decoded = img.Image.fromBytes(
                width: finalWidth,
                height: finalHeight,
                bytes: byteData.buffer,
                order: img.ChannelOrder.rgba);
            imgBytes = Uint8List.fromList(
                img.encodeJpg(decoded, quality: _jpegQuality));
          } else {
            final byteData = await finalImage.toByteData(
                format: ui.ImageByteFormat.png);
            finalImage.dispose();
            imgBytes = byteData?.buffer.asUint8List();
          }

          if (imgBytes != null) {
            final fileName = 'page_${i + 1}.$ext';

            if (kIsWeb) {
              webImages.add(imgBytes);
              webNames.add(fileName);
            } else {
              final imageFile = File('${outputDir!.path}/$fileName');
              await FileUtils.writeAndScan(imageFile, imgBytes);
              imageFiles.add(imageFile);
            }
          }
        } catch (e) {
          try {
            final fileName = 'page_${i + 1}.$ext';
            await for (final page
                in Printing.raster(bytes, pages: [i], dpi: 300)) {
              Uint8List imgBytes = await page.toPng();
              if (isJpeg) {
                final decoded = img.decodeImage(imgBytes);
                if (decoded != null) {
                  imgBytes = Uint8List.fromList(
                      img.encodeJpg(decoded, quality: _jpegQuality));
                }
              }
              if (kIsWeb) {
                webImages.add(imgBytes);
                webNames.add(fileName);
              } else {
                final imageFile = File('${outputDir!.path}/$fileName');
                await FileUtils.writeAndScan(imageFile, imgBytes);
                imageFiles.add(imageFile);
              }
              break;
            }
          } catch (_) {
            continue;
          }
        }
      }
      document.dispose();
      document = null;

      if (kIsWeb && webImages.isEmpty) throw Exception(l10n.noImagesCreated);
      if (!kIsWeb && imageFiles.isEmpty) throw Exception(l10n.noImagesCreated);

      if (!mounted) return;
      setState(() {
        _savedImageFiles = imageFiles;
        _imageBytes = webImages;
        _imageNames = webNames;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = l10n.errorConvertingPdfToImages(e.toString());
        _isLoading = false;
      });
    } finally {
      document?.dispose();
    }
  }

  void _reset() {
    setState(() {
      _pickedFile = null;
      _savedImageFiles.clear();
      _imageBytes.clear();
      _imageNames.clear();
      _error = null;
    });
  }

  bool get _hasResult =>
      kIsWeb ? _imageBytes.isNotEmpty : _savedImageFiles.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Column(
          children: [Expanded(child: LoadingSpinner(text: _statusText))]);
    }

    if (_hasResult) {
      return Column(children: [
        Expanded(
            child: ImageGallerySuccessScreen(
          imageFiles: kIsWeb ? null : _savedImageFiles,
          imageBytes: kIsWeb ? _imageBytes : null,
          imageNames: kIsWeb ? _imageNames : null,
          onGoHome: () {
            _reset();
            appState.goHome();
          },
          successMessage: l10n.pdfConvertedToImagesSuccess,
        ))
      ]);
    }

    if (_pickedFile != null) {
      return Column(children: [
        Expanded(
            child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.readyToConvert,
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Icon(Icons.picture_as_pdf,
                              size: 60, color: Color(0xFF22D3EE)),
                          const SizedBox(height: 16),
                          Text(
                            _pickedFile!.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha((0.2 * 255).round()),
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.orange),
                          textAlign: TextAlign.center),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.pdfToImageDescription,
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _convertToImages,
                      icon: const Icon(Icons.image),
                      label: Text(l10n.convertToImages),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ))
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image, size: 64, color: Color(0xFFDB2777)),
                const SizedBox(height: 16),
                Text(
                  l10n.pdfToImage,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.outputFormat,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _outputFormat = 'png'),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _outputFormat == 'png'
                                        ? const Color(0xFF22D3EE)
                                        : Colors.grey[700],
                                    border: Border.all(
                                      color: _outputFormat == 'png'
                                          ? const Color(0xFF22D3EE)
                                          : Colors.grey[600]!,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text('PNG',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(l10n.losslessBestQuality,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[300])),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _outputFormat = 'jpeg'),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _outputFormat == 'jpeg'
                                        ? const Color(0xFF22D3EE)
                                        : Colors.grey[700],
                                    border: Border.all(
                                      color: _outputFormat == 'jpeg'
                                          ? const Color(0xFF22D3EE)
                                          : Colors.grey[600]!,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text('JPEG',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(l10n.smallerFileSize,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[300])),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_outputFormat == 'jpeg') ...[
                          const SizedBox(height: 24),
                          Text(l10n.jpegQuality,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(l10n.low),
                              Expanded(
                                child: Slider(
                                  value: _jpegQuality.toDouble(),
                                  min: 10,
                                  max: 100,
                                  divisions: 9,
                                  label: '$_jpegQuality%',
                                  onChanged: (value) => setState(
                                      () => _jpegQuality = value.round()),
                                ),
                              ),
                              Text(l10n.high),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[700],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('$_jpegQuality%',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF22D3EE))),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FileDropzone(onFileSelect: _handleFileSelect),
              ],
            ),
          ),
        ),
      ))
    ]);
  }
}
