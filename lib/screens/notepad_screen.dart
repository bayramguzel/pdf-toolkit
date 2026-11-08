import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import 'package:pdf_toolkit/utils/file_utils.dart';
import 'package:pdf_toolkit/utils/platform_helper.dart';
import 'package:pdf_toolkit/widgets/file_dropzone.dart';
import 'package:provider/provider.dart';
import 'package:pdf_toolkit/providers/settings_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';

class NotepadScreen extends StatefulWidget {
  const NotepadScreen({super.key});

  @override
  State<NotepadScreen> createState() => _NotepadScreenState();
}

class _NotepadScreenState extends State<NotepadScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Enhanced formatting options
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  double _fontSize = 16.0;
  Color? _selectedColor;
  String _selectedFontFamily = 'Roboto';
  TextAlign _textAlign = TextAlign.left;

  // Store embedded images as base64
  final List<Map<String, dynamic>> _embeddedImages = [];

  bool _isLoadingDialogOpen = false;

  final List<String> _fontFamilies = [
    'Roboto',
    'Arial',
    'Times New Roman',
    'Courier New',
    'Georgia',
    'Verdana',
    'Comic Sans MS',
    'Impact',
    'Trebuchet MS',
    'Palatino'
  ];

  @override
  void initState() {
    super.initState();
    _fileNameController.text = 'My Note';
  }

  @override
  void dispose() {
    _textController.dispose();
    _fileNameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _insertImage() async {
    try {
      PickedFile? picked;
      // iOS: let the user pick from Photos as well as the Files app. Photos
      // picks are re-encoded to JPEG by the image picker / native converter,
      // which also handles HEIC.
      if (PlatformHelper.isIOS) {
        final photos = await FileDropzone.pickImagesWithSourceSheet(context);
        if (photos != null) {
          if (photos.isEmpty) return;
          picked = photos.first;
        }
      }

      if (picked == null) {
        final result = await FilePicker.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: kIsWeb,
        );
        if (result == null || result.files.isEmpty) return;
        final pickedFile = result.files.single;
        if (kIsWeb) {
          if (pickedFile.bytes == null) return;
          picked = PickedFile.fromWeb(
            name: pickedFile.name,
            bytes: pickedFile.bytes!,
          );
        } else if (pickedFile.path != null) {
          picked = await FileDropzone.normalizeImage(
            PickedFile.fromMobile(File(pickedFile.path!)),
          );
        }
      }

      if (picked == null) return;
      _embedImage(await picked.readAsBytes(), picked.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inserting image: $e')),
        );
      }
    }
  }

  void _embedImage(Uint8List bytes, String name) {
    // Resize image if too large (fit within 600x400 box)
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported image format.')),
        );
      }
      return;
    }

    final scaleX = 600 / image.width;
    final scaleY = 400 / image.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    if (scale < 1.0) {
      image = img.copyResize(
        image,
        width: (image.width * scale).round(),
        interpolation: img.Interpolation.linear,
      );
    }

    final resizedBytes = img.encodePng(image);
    final base64String = base64Encode(resizedBytes);

    final imageId = 'img_${_embeddedImages.length}';
    _embeddedImages.add({
      'id': imageId,
      'base64': base64String,
      'name': name,
    });

    final currentText = _textController.text;
    final selection = _textController.selection;
    final placeholder = '[IMAGE:$imageId]';
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      placeholder,
    );
    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(
      offset: selection.start + placeholder.length,
    );
  }

  void _insertEmoji() {
    final emojis = <String>[
      // Smileys & emotion
      '\u{1F600}', '\u{1F603}', '\u{1F604}', '\u{1F601}', '\u{1F606}',
      '\u{1F605}', '\u{1F602}', '\u{1F923}', '\u{1F60A}', '\u{1F607}',
      '\u{1F642}', '\u{1F643}', '\u{1F609}', '\u{1F60C}', '\u{1F60D}',
      '\u{1F970}', '\u{1F618}', '\u{1F617}', '\u{1F619}', '\u{1F61A}',
      '\u{1F60B}', '\u{1F61B}', '\u{1F61D}', '\u{1F61C}', '\u{1F92A}',
      '\u{1F928}', '\u{1F9D0}', '\u{1F913}', '\u{1F60E}', '\u{1F929}',
      '\u{1F973}', '\u{1F60F}', '\u{1F612}', '\u{1F61E}', '\u{1F614}',
      '\u{1F61F}', '\u{1F615}', '\u{1F641}', '\u{1F622}', '\u{1F62D}',
      '\u{1F624}', '\u{1F620}', '\u{1F621}', '\u{1F92C}', '\u{1F92F}',
      '\u{1F633}', '\u{1F631}', '\u{1F632}', '\u{1F635}', '\u{1F644}',
      // Gestures
      '\u{1F44D}', '\u{1F44E}', '\u{1F44C}', '\u270C\u{FE0F}', '\u{1F91E}',
      '\u{1F91F}', '\u{1F918}', '\u{1F919}', '\u{1F448}', '\u{1F449}',
      '\u{1F44F}',
      // Hearts
      '\u2764\u{FE0F}', '\u{1F9E1}', '\u{1F49B}', '\u{1F49A}', '\u{1F499}',
      '\u{1F49C}', '\u{1F5A4}', '\u{1F49D}',
      // Symbols
      '\u{1F4A3}', '\u2B50', '\u{1F31F}', '\u{1F4AB}', '\u2728', '\u{1F525}',
      '\u{1F4AF}', '\u{1F4A2}', '\u{1F4A5}', '\u{1F4A6}', '\u{1F4A8}',
      // Turkish characters
      '\u011F', '\u00FC', '\u015F', '\u0131', '\u00F6', '\u00E7',
      '\u011E', '\u00DC', '\u015E', '\u0130', '\u00D6', '\u00C7',
      // German characters
      '\u00E4', '\u00F6', '\u00FC', '\u00DF', '\u00C4', '\u00D6', '\u00DC',
      // Common symbols
      '\u20AC', '\u00A3', '\$', '\u00A5', '\u00A9', '\u00AE', '\u2122',
      '\u00B0', '\u00B1', '\u00D7', '\u00F7', '\u00A7',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Emoji or Character'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              childAspectRatio: 1,
            ),
            itemCount: emojis.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  final currentText = _textController.text;
                  final selection = _textController.selection;
                  final newText = currentText.replaceRange(
                    selection.start,
                    selection.end,
                    emojis[index],
                  );
                  _textController.text = newText;
                  _textController.selection = TextSelection.collapsed(
                    offset: selection.start + emojis[index].length,
                  );
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      emojis[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAsPdf() async {
    final l10n = AppLocalizations.of(context)!;

    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterSomeText)),
      );
      return;
    }

    // Show file name dialog
    String? fileName = await _showFileNameDialog();
    if (fileName == null || fileName.trim().isEmpty) {
      return;
    }

    // Show loading indicator
    if (mounted) {
      _isLoadingDialogOpen = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Creating PDF...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ).then((_) {
        _isLoadingDialogOpen = false;
      });
    }

    try {
      final customDirectory = mounted
          ? Provider.of<SettingsProvider>(context, listen: false).saveDirectory
          : null;

      final pdf = pw.Document();

      // Load fonts that support Unicode characters including emojis
      final fontData =
          await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final boldFontData =
          await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      final regularFont = pw.Font.ttf(fontData);
      final boldFont = pw.Font.ttf(boldFontData);

      // Try to load emoji font (fallback if not available)
      pw.Font? emojiFont;
      try {
        final emojiFontData =
            await rootBundle.load('assets/fonts/NotoColorEmoji.ttf');
        emojiFont = pw.Font.ttf(emojiFontData);
      } catch (e) {
        // Emoji font not available, will use regular font
        emojiFont = null;
      }

      // Process text and images
      String processedText = _textController.text;
      final List<pw.Widget> pageContent = [];

      // Split text by image placeholders and create content
      final parts = processedText.split(RegExp(r'\[IMAGE:img_\d+\]'));
      final imageMatches =
          RegExp(r'\[IMAGE:(img_\d+)\]').allMatches(processedText);

      int imageIndex = 0;
      for (int i = 0; i < parts.length; i++) {
        // Add text part
        if (parts[i].isNotEmpty) {
          pw.Font pdfFont;
          switch (_selectedFontFamily) {
            case 'Arial':
              pdfFont = _isBold ? pw.Font.helveticaBold() : pw.Font.helvetica();
              break;
            case 'Times New Roman':
              pdfFont = _isBold ? pw.Font.timesBold() : pw.Font.times();
              break;
            case 'Courier New':
              pdfFont = _isBold ? pw.Font.courierBold() : pw.Font.courier();
              break;
            default:
              pdfFont = _isBold ? boldFont : regularFont;
          }
          pageContent.add(
            pw.Paragraph(
              text: parts[i],
              style: pw.TextStyle(
                font: pdfFont,
                fontSize: _fontSize * 0.75, // Adjust for PDF
                fontStyle:
                    _isItalic ? pw.FontStyle.italic : pw.FontStyle.normal,
                decoration: _isUnderline
                    ? pw.TextDecoration.underline
                    : pw.TextDecoration.none,
                color: PdfColor.fromInt(
                    (_selectedColor ?? Colors.black).toARGB32()),
                fontFallback: emojiFont != null ? [emojiFont] : [],
              ),
              textAlign: _textAlign == TextAlign.left
                  ? pw.TextAlign.left
                  : _textAlign == TextAlign.center
                      ? pw.TextAlign.center
                      : pw.TextAlign.right,
            ),
          );
        }

        // Add image if exists
        if (imageIndex < imageMatches.length && i < parts.length - 1) {
          final imageId = imageMatches.elementAt(imageIndex).group(1);
          final imageData = _embeddedImages.firstWhere(
            (img) => img['id'] == imageId,
            orElse: () => {},
          );

          if (imageData.isNotEmpty) {
            final imageBytes = base64Decode(imageData['base64']);
            pageContent.add(pw.SizedBox(height: 10));
            pageContent.add(
              pw.Image(
                pw.MemoryImage(imageBytes),
                width: 400,
                height: 300,
                fit: pw.BoxFit.contain,
              ),
            );
            pageContent.add(pw.SizedBox(height: 10));
          }
          imageIndex++;
        }
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => pageContent,
        ),
      );

      final pdfBytes = await pdf.save();

      if (kIsWeb) {
        if (mounted) {
          _dismissLoadingDialog();
          await FileUtils.downloadBytesWeb(
              Uint8List.fromList(pdfBytes), '$fileName.pdf');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('${l10n.pdfCreatedSuccessfully}: $fileName.pdf')),
            );
          }
        }
      } else {
        final directory = await FileUtils.getOutputDirectory(customDirectory);
        final file = File('${directory.path}/$fileName.pdf');
        await FileUtils.writeAndScan(file, pdfBytes);

        if (mounted) {
          _dismissLoadingDialog();

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.pdfCreatedSuccessfully),
              content: Text('PDF saved as: $fileName.pdf'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _openPdfPreview(file.path);
                  },
                  child: const Text('Preview'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await SharePlus.instance.share(
                      ShareParams(
                        files: [XFile(file.path)],
                        text: l10n.pdfFiles,
                        sharePositionOrigin:
                            FileUtils.shareAnchorRect(this.context),
                      ),
                    );
                  },
                  child: const Text('Share'),
                ),
                if (PlatformHelper.isIOS)
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _savePdfToDevice(file);
                    },
                    child: Text(l10n.saveToFiles),
                  ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _dismissLoadingDialog();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    }
  }

  void _dismissLoadingDialog() {
    if (!mounted) return;
    if (_isLoadingDialogOpen) {
      _isLoadingDialogOpen = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  /// iOS: export the generated PDF through the system "Save to Files" panel.
  Future<void> _savePdfToDevice(File file) async {
    final l10n = AppLocalizations.of(context);
    String? savedPath;
    try {
      savedPath = await FileUtils.saveFileWithPanel(file);
    } catch (_) {
      savedPath = null;
      if (!mounted) return;
      // Panel unavailable: the share sheet also offers "Save to Files".
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          sharePositionOrigin: FileUtils.shareAnchorRect(context),
        ),
      );
      return;
    }
    if (!mounted || savedPath == null || l10n == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.savedToFiles}\n${FileUtils.baseName(savedPath)}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _openPdfPreview(String filePath) async {
    try {
      // Navigate to PDF viewer screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('PDF Preview'),
              automaticallyImplyLeading: false, // Remove back button
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () async {
                    await SharePlus.instance.share(
                      ShareParams(
                        files: [XFile(filePath)],
                        sharePositionOrigin: FileUtils.shareAnchorRect(context),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            body: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: InteractiveViewer(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'PDF Created Successfully!',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Use the share button to open with PDF viewer',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening PDF: $e')),
        );
      }
    }
  }

  Future<String?> _showFileNameDialog() async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save PDF'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter file name:'),
            const SizedBox(height: 16),
            TextField(
              controller: _fileNameController,
              decoration: const InputDecoration(
                hintText: 'File name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _fileNameController.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF111827) : Colors.white;
    final textColor = _selectedColor ?? (isDark ? Colors.white : Colors.black);

    return Column(
      children: [
        // Custom Toolbar replacing AppBar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isDark ? const Color(0xFF1F2937) : Colors.grey[200],
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.notepad,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.emoji_emotions),
                tooltip: 'Insert Emoji/Character',
                onPressed: _insertEmoji,
              ),
              IconButton(
                icon: const Icon(Icons.image),
                tooltip: 'Insert Image',
                onPressed: _insertImage,
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: l10n.saveAsPdf,
                onPressed: _saveAsPdf,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              // Enhanced formatting toolbar
              Container(
                color: isDark ? const Color(0xFF1F2937) : Colors.grey[100],
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Font family selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFontFamily,
                            items: _fontFamilies.map((font) {
                              return DropdownMenuItem(
                                value: font,
                                child: Text(
                                  font,
                                  style:
                                      TextStyle(fontFamily: font, fontSize: 12),
                                ),
                              );
                            }).toList(),
                            onChanged: (font) {
                              if (font != null) {
                                setState(() {
                                  _selectedFontFamily = font;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Bold button
                      IconButton(
                        icon: Icon(
                          Icons.format_bold,
                          color: _isBold ? Colors.blue : null,
                        ),
                        onPressed: () {
                          setState(() {
                            _isBold = !_isBold;
                          });
                        },
                      ),

                      // Italic button
                      IconButton(
                        icon: Icon(
                          Icons.format_italic,
                          color: _isItalic ? Colors.blue : null,
                        ),
                        onPressed: () {
                          setState(() {
                            _isItalic = !_isItalic;
                          });
                        },
                      ),

                      // Underline button
                      IconButton(
                        icon: Icon(
                          Icons.format_underlined,
                          color: _isUnderline ? Colors.blue : null,
                        ),
                        onPressed: () {
                          setState(() {
                            _isUnderline = !_isUnderline;
                          });
                        },
                      ),

                      // Text alignment buttons
                      IconButton(
                        icon: Icon(
                          Icons.format_align_left,
                          color:
                              _textAlign == TextAlign.left ? Colors.blue : null,
                        ),
                        onPressed: () {
                          setState(() {
                            _textAlign = TextAlign.left;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.format_align_center,
                          color: _textAlign == TextAlign.center
                              ? Colors.blue
                              : null,
                        ),
                        onPressed: () {
                          setState(() {
                            _textAlign = TextAlign.center;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.format_align_right,
                          color: _textAlign == TextAlign.right
                              ? Colors.blue
                              : null,
                        ),
                        onPressed: () {
                          setState(() {
                            _textAlign = TextAlign.right;
                          });
                        },
                      ),

                      const SizedBox(width: 16),

                      // Color picker button
                      IconButton(
                        icon: Icon(Icons.color_lens, color: textColor),
                        tooltip: 'Text Color',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Select Text Color'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: textColor,
                                  onColorChanged: (color) {
                                    setState(() {
                                      _selectedColor = color;
                                    });
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Done'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(width: 16),

                      // Font size controls
                      const Text('Size: '),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (_fontSize > 10) _fontSize--;
                          });
                        },
                      ),
                      Text('${_fontSize.toInt()}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            if (_fontSize < 32) _fontSize++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Rich text editor
              Expanded(
                child: Container(
                  color: backgroundColor,
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    textAlign: _textAlign,
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: textColor,
                      fontFamily: _selectedFontFamily,
                      fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                      fontStyle:
                          _isItalic ? FontStyle.italic : FontStyle.normal,
                      decoration: _isUnderline
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.notepadDescription,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
