import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// iOS images are often HEIC/HEIF (the iPhone camera default), which the pure
/// Dart `image` package cannot decode. This helper asks the native side
/// (`ios/Runner/AppDelegate.swift`) for a normalized JPEG copy in the temp
/// directory. It is a no-op on Android, web and desktop.
class IosImageConverter {
  static const MethodChannel _channel =
      MethodChannel('com.software41.pdftoolkit/image_converter');

  static bool get isSupported => !kIsWeb && Platform.isIOS;

  /// Returns a JPEG file for [file], or `null` when the conversion is not
  /// possible (unsupported format / channel error). Callers should fall back to
  /// the original file in that case.
  static Future<File?> toJpeg(File file) async {
    if (!isSupported) return null;
    try {
      final String? path = await _channel.invokeMethod<String>(
        'convertToJpeg',
        <String, String>{'path': file.path},
      );
      if (path == null || path.isEmpty) return null;
      final converted = File(path);
      if (!await converted.exists()) return null;
      return converted;
    } catch (_) {
      return null;
    }
  }
}
