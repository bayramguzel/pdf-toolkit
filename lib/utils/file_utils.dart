import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show BuildContext, MediaQuery, Rect;
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'web_download_stub.dart' if (dart.library.js_interop) 'web_download.dart'
    as web_dl;

class FileUtils {
  static const _mediaScannerChannel =
      MethodChannel('com.software41.pdftoolkit/media_scanner');

  /// Notify Android MediaStore about a newly saved file so all apps can see it.
  static Future<void> scanFileForMediaStore(String filePath) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _mediaScannerChannel.invokeMethod('scanFile', {'path': filePath});
    } catch (_) {}
  }

  /// Save bytes to the public Downloads folder on Android using MediaStore.
  /// Returns the saved path on success, or null on failure / non-Android.
  static Future<String?> saveToDownloads(
      Uint8List bytes, String fileName) async {
    if (kIsWeb || !Platform.isAndroid) return null;
    try {
      return await _mediaScannerChannel.invokeMethod(
        'saveToDownloads',
        {'fileName': fileName, 'bytes': bytes},
      );
    } catch (_) {
      return null;
    }
  }

  /// Write bytes to file and trigger MediaStore scan on Android.
  static Future<void> writeAndScan(File file, List<int> bytes) async {
    await file.writeAsBytes(bytes);
    await scanFileForMediaStore(file.path);
  }

  /// iOS: shows the system **Save to Files** panel so the user picks the folder
  /// (On My iPhone, iCloud Drive, …) and can rename the file before it is kept.
  ///
  /// Returns the destination path, or `null` when the user cancelled. Throws
  /// when the panel cannot be presented, so callers can fall back to the share
  /// sheet, which also offers "Save to Files".
  static Future<String?> saveWithSavePanel({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (kIsWeb || !Platform.isIOS) {
      throw UnsupportedError('saveWithSavePanel is iOS only');
    }
    return fp.FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      type: fp.FileType.any,
    );
  }

  /// iOS convenience wrapper around [saveWithSavePanel] for a file that already
  /// lives in the app sandbox.
  static Future<String?> saveFileWithPanel(File file) async {
    final data = await file.readAsBytes();
    return saveWithSavePanel(bytes: data, fileName: baseName(file.path));
  }

  /// Last path component, tolerant of both separators.
  static String baseName(String path) => path.split(RegExp(r'[/\\]')).last;

  /// iPad and Mac present the share sheet as a popover that must be anchored to
  /// a rect; without one the system throws. A point in the top trailing corner
  /// works for every full-screen tool bar and is ignored on iPhone.
  static Rect? shareAnchorRect(BuildContext context) {
    if (kIsWeb || !Platform.isIOS) return null;
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    return Rect.fromLTWH(size.width - 24, padding.top + 8, 1, 1);
  }

  /// Write string to file and trigger MediaStore scan on Android.
  static Future<void> writeStringAndScan(File file, String content) async {
    await file.writeAsString(content);
    await scanFileForMediaStore(file.path);
  }

  /// Request storage permissions for Android
  static Future<bool> requestStoragePermission() async {
    if (kIsWeb) return true;

    // Files are selected through the system picker and saved to app-controlled
    // or user-chosen locations, so no broad media/storage permission is needed.
    return true;
  }

  /// Open the directory in system file manager.
  /// Returns true when a file manager / Files app was opened.
  static Future<bool> openOutputDirectory(String? customDirectory) async {
    final directory = await getOutputDirectory(customDirectory);
    return openDirectoryPath(directory.path);
  }

  /// Open a directory in the platform file manager.
  ///
  /// iOS gives apps no way to open their sandbox folder in a file manager, so
  /// this opens the Files app instead, where the app's Documents folder is
  /// listed (requires UIFileSharingEnabled in Info.plist).
  static Future<bool> openDirectoryPath(String path) async {
    if (kIsWeb) return false;

    if (Platform.isIOS) {
      try {
        return await launchUrl(
          Uri.parse('shareddocuments://'),
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        return false;
      }
    }

    if (Platform.isAndroid) {
      try {
        final Uri fileUri = Uri.file(path);
        if (await canLaunchUrl(fileUri)) {
          await launchUrl(fileUri, mode: LaunchMode.externalApplication);
          return true;
        }

        // Fallback for public downloads-style locations.
        final Uri folderUri = Uri.parse(
            'content://com.android.externalstorage.documents/document/primary%3ADownload%2FPDFToolkit');
        if (await canLaunchUrl(folderUri)) {
          await launchUrl(folderUri, mode: LaunchMode.externalApplication);
          return true;
        } else {
          // Fallback to general downloads if specific folder fails.
          final Uri downloadsUri = Uri.parse(
              'content://com.android.externalstorage.documents/root/primary');
          if (await canLaunchUrl(downloadsUri)) {
            await launchUrl(downloadsUri, mode: LaunchMode.externalApplication);
            return true;
          }
        }
      } catch (e) {
        final Uri fileUri = Uri.file(path);
        if (await canLaunchUrl(fileUri)) {
          await launchUrl(fileUri, mode: LaunchMode.externalApplication);
          return true;
        }
      }
      return false;
    }

    final Uri folderUri = Uri.file(path);
    if (await canLaunchUrl(folderUri)) {
      await launchUrl(folderUri);
      return true;
    }
    return false;
  }

  /// Get the output directory for saving files based on user settings
  /// Falls back to Documents directory if custom directory is not set or invalid
  static Future<Directory> getOutputDirectory(String? customDirectory) async {
    if (kIsWeb) {
      // On web, return a dummy directory (files are downloaded via browser)
      return Directory('');
    }

    if (customDirectory != null && customDirectory.isNotEmpty) {
      final customDir = Directory(customDirectory);
      try {
        if (!await customDir.exists()) {
          await customDir.create(recursive: true);
        }
        return customDir;
      } catch (e) {
        // If custom directory fails, fall back
      }
    }

    // Default to app documents on Android so file access works without
    // broad external storage permissions.
    if (Platform.isAndroid) {
      final directory = await getApplicationDocumentsDirectory();
      try {
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        return directory;
      } catch (e) {
        // Fallback to app documents if directory creation fails.
      }
    }

    return await getApplicationDocumentsDirectory();
  }

  /// Format file size in human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Trigger a browser download on web
  static Future<void> downloadBytesWeb(Uint8List bytes, String fileName) async {
    web_dl.downloadFileWeb(bytes, fileName);
  }
}
