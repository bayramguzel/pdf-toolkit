import 'dart:io';
import 'package:flutter/foundation.dart';

enum ToolType {
  home,
  reader,
  merger,
  splitter,
  compressor,
  pdfToImage,
  encryptor,
  unlocker,
  pdfToWord,
  rotate,
  watermark,
  removePages,
  reorder,
  imageToPdf,
  wordToPdf,
  notepad,
  folderBrowser,
}

class AppState extends ChangeNotifier {
  ToolType _activeTool = ToolType.home;
  File? _initialReaderFile;

  ToolType get activeTool => _activeTool;
  File? get initialReaderFile => _initialReaderFile;

  void selectTool(ToolType tool, {File? file}) {
    _activeTool = tool;
    _initialReaderFile = file;
    notifyListeners();
  }

  void handleIncomingFile(String path) {
    if (path.toLowerCase().endsWith('.pdf')) {
      selectTool(ToolType.reader, file: File(path));
    } else if (File(path).existsSync()) {
      // Non-PDF imports (images, Word, text) are copied into the app folder;
      // show the user where they landed.
      selectTool(ToolType.folderBrowser);
    }
  }

  void goHome() {
    _activeTool = ToolType.home;
    _initialReaderFile = null;
    notifyListeners();
  }

  void onOperationComplete(File file) {
    _activeTool = ToolType.reader;
    _initialReaderFile = file;
    notifyListeners();
  }
}
