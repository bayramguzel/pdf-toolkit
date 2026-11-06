import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:path_provider/path_provider.dart';

/// Reads documents that iOS handed to the app through "Open in PDF Toolkit" or
/// "Copy to PDF Toolkit" (see `ios/Runner/AppDelegate.swift`).
///
/// The native side copies the file into the app's Documents folder — so it is
/// also listed in Files › On My iPhone › PDF Toolkit — and appends a small JSON
/// queue entry in Application Support. Dart drains that queue on launch and on
/// resume.
class IosIncomingFiles {
  static const _queueFileName = 'incoming_documents.json';

  static Future<File?> _queueFile() async {
    final support = await getApplicationSupportDirectory();
    if (!await support.exists()) return null;
    final file = File(
      '${support.path}${Platform.pathSeparator}$_queueFileName',
    );
    return await file.exists() ? file : null;
  }

  /// Returns the newest queued document path and clears the queue.
  static Future<String?> takeLatestPath() async {
    if (kIsWeb || !Platform.isIOS) return null;
    try {
      final queue = await _queueFile();
      if (queue == null) return null;
      final raw = await queue.readAsString();
      await queue.delete();
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      // The native side appends, so the newest document is last.
      for (final entry in decoded.reversed) {
        if (entry is! Map) continue;
        final path = entry['path'];
        if (path is String && File(path).existsSync()) return path;
      }
    } catch (e) {
      debugPrint('Could not read incoming iOS documents: $e');
    }
    return null;
  }
}
