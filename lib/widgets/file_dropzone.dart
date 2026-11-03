import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';

/// Unified file model for both web and mobile.
/// On mobile: wraps dart:io File. On web: holds bytes + name.
class PickedFile {
  final String name;
  final String? path; // null on web
  final Uint8List? _cachedBytes;
  final File? _ioFile; // mobile only

  PickedFile._({
    required this.name,
    this.path,
    Uint8List? bytes,
    File? ioFile,
  })  : _cachedBytes = bytes,
        _ioFile = ioFile;

  factory PickedFile.fromMobile(File file) => PickedFile._(
        name: file.path.split('/').last,
        path: file.path,
        ioFile: file,
      );

  factory PickedFile.fromWeb(
          {required String name, required Uint8List bytes}) =>
      PickedFile._(name: name, bytes: bytes);

  bool get isWeb => _ioFile == null;

  /// dart:io File â€” throws on web
  File get ioFile {
    assert(!isWeb, 'ioFile is not available on web');
    return _ioFile!;
  }

  /// Read bytes â€” works on both platforms
  Future<Uint8List> readAsBytes() async {
    if (_cachedBytes != null) return _cachedBytes;
    return await _ioFile!.readAsBytes();
  }
}

class FileDropzone extends StatefulWidget {
  final Function(List<PickedFile>) onFileSelect;
  final bool allowMultiple;
  final List<String>? allowedExtensions;
  final String? fileTypeLabel;

  const FileDropzone({
    super.key,
    required this.onFileSelect,
    this.allowMultiple = false,
    this.allowedExtensions,
    this.fileTypeLabel,
  });

  @override
  State<FileDropzone> createState() => _FileDropzoneState();
}

class _FileDropzoneState extends State<FileDropzone> {
  final bool _isDragging = false;

  Future<void> _pickFiles() async {
    try {
      final extensions = widget.allowedExtensions ?? ['pdf'];
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        allowMultiple: widget.allowMultiple,
        withData: kIsWeb, // load bytes on web
      );

      if (result == null || result.files.isEmpty) return;

      final picked = <PickedFile>[];
      for (final pf in result.files) {
        if (kIsWeb) {
          if (pf.bytes != null) {
            picked.add(PickedFile.fromWeb(name: pf.name, bytes: pf.bytes!));
          }
        } else {
          if (pf.path != null) {
            picked.add(PickedFile.fromMobile(File(pf.path!)));
          }
        }
      }

      if (picked.isNotEmpty) widget.onFileSelect(picked);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking files: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fileType = widget.fileTypeLabel ?? 'PDF';
    const plural = '';

    return InkWell(
      onTap: _pickFiles,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        decoration: BoxDecoration(
          color: _isDragging ? Colors.cyan.withAlpha(25) : Colors.transparent,
          border: Border.all(
            color: _isDragging ? const Color(0xFF22D3EE) : Colors.grey[600]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 44,
              color: _isDragging ? const Color(0xFF22D3EE) : Colors.grey[500],
            ),
            const SizedBox(height: 10),
            Text(
              l10n.clickToSelectFile(fileType, plural),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _isDragging ? const Color(0xFF22D3EE) : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.allowMultiple
                  ? l10n.youCanSelectMultiple(fileType)
                  : l10n.supportedFormats(
                      widget.allowedExtensions?.join(', ') ?? 'PDF'),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
