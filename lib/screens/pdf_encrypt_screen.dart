import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../providers/settings_provider.dart';
import '../utils/file_utils.dart';
import '../widgets/file_dropzone.dart';
import '../widgets/loading_spinner.dart';
import '../widgets/operation_success_screen.dart';

class PdfEncryptScreen extends StatefulWidget {
  const PdfEncryptScreen({super.key});

  @override
  State<PdfEncryptScreen> createState() => _PdfEncryptScreenState();
}

class _PdfEncryptScreenState extends State<PdfEncryptScreen> {
  File? _pdfFile;
  PickedFile? _pickedFile;
  bool _isProcessing = false;
  String _statusText = '';
  String? _error;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  File? _encryptedFile;
  Uint8List? _encryptedBytes;
  String? _encryptedFileName;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleFileSelect(List<PickedFile> files) async {
    if (files.isEmpty) return;
    setState(() {
      _pickedFile = files.first;
      _pdfFile = files.first.isWeb ? null : files.first.ioFile;
      _error = null;
    });
  }

  Future<void> _encryptPdf() async {
    final l10n = AppLocalizations.of(context)!;
    if (_pickedFile == null) {
      setState(() {
        _error = l10n.pleaseSelectPdfFirst;
      });
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() {
        _error = l10n.passwordCannotBeEmpty;
      });
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _error = l10n.passwordsDoNotMatch;
      });
      return;
    }

    final customDirectory =
        Provider.of<SettingsProvider>(context, listen: false).saveDirectory;

    setState(() {
      _isProcessing = true;
      _statusText = l10n.encryptingPdf;
      _error = null;
    });

    PdfDocument? document;
    try {
      final bytes = await _pickedFile!.readAsBytes();
      document = PdfDocument(inputBytes: bytes);

      final security = document.security;
      security.userPassword = _passwordController.text;
      security.ownerPassword = _passwordController.text;
      security.algorithm = PdfEncryptionAlgorithm.aesx128Bit;
      security.permissions.add(PdfPermissionsFlags.print);
      security.permissions.add(PdfPermissionsFlags.fullQualityPrint);

      final List<int> encryptedBytes = await document.save();
      document.dispose();
      document = null;

      final outputName = 'encrypted_${_pickedFile!.name}';

      if (kIsWeb) {
        if (!mounted) return;
        setState(() {
          _encryptedBytes = Uint8List.fromList(encryptedBytes);
          _encryptedFileName = outputName;
          _isProcessing = false;
        });
      } else {
        final directory = await FileUtils.getOutputDirectory(customDirectory);
        final outputFile = File('${directory.path}/$outputName');
        await FileUtils.writeAndScan(outputFile, encryptedBytes);
        if (!mounted) return;
        setState(() {
          _encryptedFile = outputFile;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = l10n.failedToEncryptPdf(e.toString());
        _isProcessing = false;
      });
    } finally {
      document?.dispose();
    }
  }

  void _reset() {
    setState(() {
      _pdfFile = null;
      _pickedFile = null;
      _encryptedFile = null;
      _encryptedBytes = null;
      _encryptedFileName = null;
      _passwordController.clear();
      _confirmPasswordController.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (_isProcessing) {
      return Column(
          children: [Expanded(child: LoadingSpinner(text: _statusText))]);
    }

    if (_encryptedFile != null || _encryptedBytes != null) {
      return Column(children: [
        Expanded(
            child: OperationSuccessScreen(
          file: _encryptedFile,
          bytes: _encryptedBytes,
          fileName: _encryptedFileName,
          onGoHome: () {
            _reset();
            appState.goHome();
          },
          successMessage: l10n.pdfEncryptedSuccessfully,
          isPdf: true,
        ))
      ]);
    }

    if (_pickedFile == null) {
      return Column(children: [
        Expanded(
            child: Center(
                child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock,
                  size: 64, color: Color(0xFFE11D48)), // Rose
              const SizedBox(height: 16),
              Text(
                l10n.encryptPdf,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.addPassword,
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FileDropzone(onFileSelect: _handleFileSelect),
            ],
          ),
        )))
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
            children: [
              Text(
                l10n.encryptPdf,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.setPasswordDescription,
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    _pickedFile!.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.password,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: l10n.enterStrongPassword,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.confirmPassword,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: l10n.reEnterPassword,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.encryptionNote,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _encryptPdf,
                  icon: const Icon(Icons.lock),
                  label: Text(l10n.encryptPdf),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )))
    ]);
  }
}
