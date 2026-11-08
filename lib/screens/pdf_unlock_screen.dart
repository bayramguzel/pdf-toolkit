import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf_pdf;
import 'package:provider/provider.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../providers/settings_provider.dart';
import '../utils/file_utils.dart';
import '../widgets/file_dropzone.dart';
import '../widgets/tool_page_badge.dart';
import '../widgets/loading_spinner.dart';
import '../widgets/operation_success_screen.dart';

class PdfUnlockScreen extends StatefulWidget {
  const PdfUnlockScreen({super.key});

  @override
  State<PdfUnlockScreen> createState() => _PdfUnlockScreenState();
}

class _PdfUnlockScreenState extends State<PdfUnlockScreen> {
  File? _pdfFile;
  PickedFile? _pickedFile;
  bool _isProcessing = false;
  String _statusText = '';
  String? _error;
  String? _info;
  File? _unlockedFile;
  Uint8List? _unlockedBytes;
  String? _unlockedFileName;
  final _passwordController = TextEditingController();

  Future<void> _handleFileSelect(List<PickedFile> files) async {
    if (files.isEmpty) return;
    setState(() {
      _pickedFile = files.first;
      _pdfFile = files.first.isWeb ? null : files.first.ioFile;
      _error = null;
      _info = null;
      _passwordController.clear();
    });
  }

  Future<void> _unlockPdf() async {
    if (_pickedFile == null) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isProcessing = true;
      _statusText = l10n.unlockingPdf;
      _error = null;
      _info = null;
    });

    final customDirectory =
        Provider.of<SettingsProvider>(context, listen: false).saveDirectory;

    try {
      final bytes = await _pickedFile!.readAsBytes();

      // If the PDF can be opened without a password, there is nothing to unlock.
      bool needsPassword = false;
      sf_pdf.PdfDocument? testDocument;
      try {
        testDocument = sf_pdf.PdfDocument(inputBytes: bytes);
      } catch (_) {
        needsPassword = true;
      } finally {
        testDocument?.dispose();
      }

      if (!needsPassword) {
        setState(() {
          _info = l10n.pdfNoPassword;
          _isProcessing = false;
        });
        return;
      }

      sf_pdf.PdfDocument document;
      try {
        document = sf_pdf.PdfDocument(
          inputBytes: bytes,
          password: _passwordController.text,
        );
      } catch (e) {
        setState(() {
          _error = l10n.invalidPassword;
          _isProcessing = false;
        });
        return;
      }

      final List<int> outBytes = await document.save();
      document.dispose();

      final originalName = _pickedFile!.name.replaceAll('.pdf', '');
      final outputName = '${originalName}_unlocked.pdf';

      if (kIsWeb) {
        setState(() {
          _unlockedBytes = Uint8List.fromList(outBytes);
          _unlockedFileName = outputName;
          _isProcessing = false;
        });
      } else {
        final directory = await FileUtils.getOutputDirectory(customDirectory);
        final outputFile = File('${directory.path}/$outputName');
        await FileUtils.writeAndScan(outputFile, outBytes);
        setState(() {
          _unlockedFile = outputFile;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = l10n.failedToUnlockPdf(e.toString());
        _isProcessing = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _pdfFile = null;
      _pickedFile = null;
      _unlockedFile = null;
      _unlockedBytes = null;
      _unlockedFileName = null;
      _error = null;
      _info = null;
      _passwordController.clear();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Column(
      children: [
        Expanded(
          child: _buildContent(appState),
        ),
      ],
    );
  }

  Widget _buildContent(AppState appState) {
    final l10n = AppLocalizations.of(context)!;
    if (_isProcessing) {
      return LoadingSpinner(text: _statusText);
    }

    if (_unlockedFile != null || _unlockedBytes != null) {
      return OperationSuccessScreen(
        file: _unlockedFile,
        bytes: _unlockedBytes,
        fileName: _unlockedFileName,
        onGoHome: () {
          _reset();
          appState.goHome();
        },
        successMessage: l10n.pdfUnlockedSuccessfully,
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ToolPageBadge(tool: ToolType.unlocker),
              const SizedBox(height: 16),
              Text(
                l10n.unlockPdf,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.unlock,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha((0.1 * 255).round()),
                    border: Border.all(
                        color: Colors.red.withAlpha((0.5 * 255).round())),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_info != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha((0.1 * 255).round()),
                    border: Border.all(
                        color: Colors.blue.withAlpha((0.5 * 255).round())),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _info!,
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_pickedFile == null) ...[
                FileDropzone(onFileSelect: _handleFileSelect),
              ] else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.picture_as_pdf,
                                color: Colors.red, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _pickedFile!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() {
                                _pickedFile = null;
                                _pdfFile = null;
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.enterPdfPassword,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: l10n.password,
                            prefixIcon: const Icon(Icons.vpn_key),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _unlockPdf,
                            icon: const Icon(Icons.lock_open),
                            label: Text(l10n.unlockPdf),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
