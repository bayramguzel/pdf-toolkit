import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;

import 'package:pdf_toolkit/providers/app_state.dart';
import 'package:pdf_toolkit/utils/platform_helper.dart';

/// Per-tool icon and colour shared between the home cards and the tool
/// screens, so the "operation icon" shown inside a tool (e.g. the file
/// dropzone) always looks like the card the user tapped to get there.
///
/// Android/web use Material icons with the pastel card fill; iOS uses
/// Cupertino (SF-Symbol-like) icons with the card accent colour.
class ToolMeta {
  final IconData icon;
  final Color color;

  const ToolMeta(this.icon, this.color);

  static ToolMeta of(ToolType tool) => PlatformHelper.isIOS
      ? _ios[tool] ?? _fallback
      : _android[tool] ?? _fallback;

  static const _fallback = ToolMeta(
    Icons.cloud_upload_outlined,
    Color(0xFF2563EB),
  );

  static const Map<ToolType, ToolMeta> _android = {
    ToolType.reader: ToolMeta(Icons.menu_book, Color(0xFF2563EB)),
    ToolType.folderBrowser: ToolMeta(Icons.folder, Color(0xFF059669)),
    ToolType.merger: ToolMeta(Icons.merge, Color(0xFFE0F2FE)),
    ToolType.splitter: ToolMeta(Icons.call_split, Color(0xFFDCFCE7)),
    ToolType.compressor: ToolMeta(Icons.compress, Color(0xFFFEF9C3)),
    ToolType.rotate: ToolMeta(Icons.rotate_right, Color(0xFFFFEDD5)),
    ToolType.removePages: ToolMeta(Icons.delete_sweep, Color(0xFFFEE2E2)),
    ToolType.reorder: ToolMeta(Icons.reorder, Color(0xFFE0E7FF)),
    ToolType.watermark: ToolMeta(Icons.water_drop, Color(0xFFDBEAFE)),
    ToolType.encryptor: ToolMeta(Icons.lock, Color(0xFFFCE7F3)),
    ToolType.unlocker: ToolMeta(Icons.lock_open, Color(0xFFF3E8FF)),
    ToolType.pdfToImage: ToolMeta(Icons.image, Color(0xFFFBCFE8)),
    ToolType.pdfToWord: ToolMeta(Icons.article, Color(0xFFE9D5FF)),
    ToolType.imageToPdf: ToolMeta(Icons.add_photo_alternate, Color(0xFFDDD6FE)),
    ToolType.wordToPdf: ToolMeta(Icons.text_snippet, Color(0xFFCCFBF1)),
    ToolType.notepad: ToolMeta(Icons.note_alt, Color(0xFFFDE68A)),
  };

  static const Map<ToolType, ToolMeta> _ios = {
    ToolType.reader: ToolMeta(CupertinoIcons.book_fill, Color(0xFF2563EB)),
    ToolType.folderBrowser:
        ToolMeta(CupertinoIcons.folder_fill, Color(0xFF059669)),
    ToolType.merger:
        ToolMeta(CupertinoIcons.square_on_square, Color(0xFF0284C7)),
    ToolType.splitter: ToolMeta(CupertinoIcons.scissors, Color(0xFF16A34A)),
    ToolType.compressor: ToolMeta(CupertinoIcons.archivebox, Color(0xFFCA8A04)),
    ToolType.rotate: ToolMeta(CupertinoIcons.rotate_right, Color(0xFFEA580C)),
    ToolType.removePages: ToolMeta(CupertinoIcons.delete, Color(0xFFDC2626)),
    ToolType.reorder:
        ToolMeta(CupertinoIcons.square_grid_2x2, Color(0xFF4F46E5)),
    ToolType.watermark: ToolMeta(CupertinoIcons.drop, Color(0xFF0891B2)),
    ToolType.encryptor: ToolMeta(CupertinoIcons.lock, Color(0xFFDB2777)),
    ToolType.unlocker: ToolMeta(CupertinoIcons.lock_open, Color(0xFF9333EA)),
    ToolType.pdfToImage: ToolMeta(CupertinoIcons.photo, Color(0xFFC026D3)),
    ToolType.pdfToWord: ToolMeta(CupertinoIcons.doc_text, Color(0xFF7C3AED)),
    ToolType.imageToPdf:
        ToolMeta(CupertinoIcons.photo_on_rectangle, Color(0xFF0D9488)),
    ToolType.wordToPdf:
        ToolMeta(CupertinoIcons.doc_plaintext, Color(0xFFE11D48)),
    ToolType.notepad: ToolMeta(CupertinoIcons.pencil, Color(0xFFD97706)),
  };
}
