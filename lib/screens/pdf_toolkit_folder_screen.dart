import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import '../providers/app_state.dart';
import '../providers/settings_provider.dart';
import '../utils/file_utils.dart';
import '../utils/platform_helper.dart';
import '../widgets/auto_fit_text.dart';

enum _SortOrder { name, dateDesc, sizeDesc }

class PdfToolkitFolderScreen extends StatefulWidget {
  const PdfToolkitFolderScreen({super.key});

  @override
  State<PdfToolkitFolderScreen> createState() => _PdfToolkitFolderScreenState();
}

class _PdfToolkitFolderScreenState extends State<PdfToolkitFolderScreen> {
  List<FileSystemEntity> _files = [];
  bool _loading = true;
  _SortOrder _sortOrder = _SortOrder.dateDesc;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final dir = await FileUtils.getOutputDirectory(settings.saveDirectory);
      final entities = dir.existsSync()
          ? dir.listSync().whereType<File>().toList()
          : <File>[];
      _sort(entities, _sortOrder);
      if (!mounted) return;
      setState(() {
        _files = entities;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _files = [];
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorOpeningFolder)),
      );
    }
  }

  void _sort(List<FileSystemEntity> files, _SortOrder order) {
    files.sort((a, b) {
      final fa = File(a.path);
      final fb = File(b.path);
      switch (order) {
        case _SortOrder.name:
          return a.path
              .split('/')
              .last
              .toLowerCase()
              .compareTo(b.path.split('/').last.toLowerCase());
        case _SortOrder.dateDesc:
          return fb.lastModifiedSync().compareTo(fa.lastModifiedSync());
        case _SortOrder.sizeDesc:
          return fb.lengthSync().compareTo(fa.lengthSync());
      }
    });
  }

  void _changeSortOrder(_SortOrder order) {
    setState(() {
      _sortOrder = order;
      _sort(_files.cast<File>(), order);
    });
  }

  Future<void> _deleteFile(File file) async {
    final l10n = AppLocalizations.of(context)!;
    final name = file.path.split('/').last;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.deleteFile,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await file.delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fileDeletedSuccess)),
        );
        _loadFiles();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorDeletingFile)),
        );
      }
    }
  }

  Future<void> _openFile(File file) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (file.path.toLowerCase().endsWith('.pdf')) {
        if (!mounted) return;
        Provider.of<AppState>(context, listen: false)
            .selectTool(ToolType.reader, file: file);
        return;
      }
      if (PlatformHelper.isIOS) {
        // iOS cannot hand arbitrary sandbox files to other apps via file://.
        await _shareFile(file);
        return;
      }
      final uri = Uri.file(file.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorOpeningFile)),
      );
    }
  }

  Future<void> _shareFile(File file) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        sharePositionOrigin: FileUtils.shareAnchorRect(context),
      ),
    );
  }

  /// iOS: keeps a copy outside the app sandbox using the native
  /// "Save to Files" panel (On My iPhone / iCloud Drive / …).
  Future<void> _saveFileToDevice(File file) async {
    final l10n = AppLocalizations.of(context)!;
    String? savedPath;
    try {
      savedPath = await FileUtils.saveFileWithPanel(file);
    } catch (_) {
      savedPath = null;
      // Panel not available — the share sheet still offers "Save to Files".
      await _shareFile(file);
      return;
    }
    if (!mounted || savedPath == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.savedToFiles}\n${FileUtils.baseName(savedPath)}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  IconData _fileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'bmp':
      case 'gif':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      case 'rtf':
        return Icons.article;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _fileIconColor(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return const Color(0xFFEF4444);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'bmp':
      case 'gif':
        return const Color(0xFF3B82F6);
      case 'txt':
      case 'rtf':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isGrid = Provider.of<SettingsProvider>(context).isGridView;

    return Column(
      children: [
        // Page header. The title gets its own row so long translations
        // (e.g. "Meine Dateien") never get squeezed beside the sort chips.
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 12, 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.myFiles,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (PlatformHelper.isIOS)
                IconButton(
                  tooltip: l10n.openInFiles,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.folder_copy_outlined, size: 20),
                  onPressed: () {
                    final settings =
                        Provider.of<SettingsProvider>(context, listen: false);
                    FileUtils.openOutputDirectory(settings.saveDirectory);
                  },
                ),
            ],
          ),
        ),
        // Sort chips scroll horizontally on narrow screens instead of
        // overflowing.
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            children: [
              _SortChip(
                label: l10n.sortByDate,
                selected: _sortOrder == _SortOrder.dateDesc,
                onTap: () => _changeSortOrder(_SortOrder.dateDesc),
              ),
              const SizedBox(width: 6),
              _SortChip(
                label: l10n.sortByName,
                selected: _sortOrder == _SortOrder.name,
                onTap: () => _changeSortOrder(_SortOrder.name),
              ),
              const SizedBox(width: 6),
              _SortChip(
                label: l10n.sortBySize,
                selected: _sortOrder == _SortOrder.sizeDesc,
                onTap: () => _changeSortOrder(_SortOrder.sizeDesc),
              ),
            ],
          ),
        ),
        // File list
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _files.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 64,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noFilesFound,
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          if (PlatformHelper.isIOS) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                l10n.iosFilesHint,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[500],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFiles,
                      child: isGrid
                          ? GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.05,
                              ),
                              itemCount: _files.length,
                              itemBuilder: (context, index) {
                                final file = File(_files[index].path);
                                final name = FileUtils.baseName(file.path);
                                final modified = file.lastModifiedSync();
                                final dateStr =
                                    '${modified.day.toString().padLeft(2, '0')}.${modified.month.toString().padLeft(2, '0')}.${modified.year}';
                                return _FileGridTile(
                                  name: name,
                                  size: FileUtils.formatFileSize(
                                      file.lengthSync()),
                                  date: dateStr,
                                  icon: _fileIcon(name),
                                  color: _fileIconColor(name),
                                  onTap: () => _openFile(file),
                                  menuBuilder: (_) => _buildFileMenu(l10n),
                                  onMenuSelected: (value) =>
                                      _handleFileAction(value, file),
                                );
                              },
                            )
                          : ListView.builder(
                              itemCount: _files.length,
                              itemBuilder: (context, index) {
                                final file = File(_files[index].path);
                                final name = file.path.split('/').last;
                                final size =
                                    FileUtils.formatFileSize(file.lengthSync());
                                final modified = file.lastModifiedSync();
                                final dateStr =
                                    '${modified.day.toString().padLeft(2, '0')}.${modified.month.toString().padLeft(2, '0')}.${modified.year}  ${modified.hour.toString().padLeft(2, '0')}:${modified.minute.toString().padLeft(2, '0')}';

                                return ListTile(
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _fileIconColor(name)
                                          .withAlpha((0.15 * 255).round()),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _fileIcon(name),
                                      color: _fileIconColor(name),
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '$dateStr  •  $size',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) =>
                                        _handleFileAction(value, file),
                                    itemBuilder: (ctx) => _buildFileMenu(l10n),
                                  ),
                                  onTap: () => _openFile(file),
                                );
                              },
                            ),
                    ),
        ),
      ],
    );
  }

  void _handleFileAction(String value, File file) {
    if (value == 'open') _openFile(file);
    if (value == 'share') _shareFile(file);
    if (value == 'save') _saveFileToDevice(file);
    if (value == 'delete') _deleteFile(file);
  }

  List<PopupMenuEntry<String>> _buildFileMenu(AppLocalizations l10n) {
    return [
      PopupMenuItem(
        value: 'open',
        child: Row(
          children: [
            const Icon(Icons.open_in_new, size: 18),
            const SizedBox(width: 8),
            Text(l10n.openFile),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'share',
        child: Row(
          children: [
            const Icon(Icons.share, size: 18),
            const SizedBox(width: 8),
            Text(l10n.share),
          ],
        ),
      ),
      if (PlatformHelper.isIOS)
        PopupMenuItem(
          value: 'save',
          child: Row(
            children: [
              const Icon(Icons.save_alt, size: 18),
              const SizedBox(width: 8),
              Text(l10n.saveToFiles),
            ],
          ),
        ),
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            const Icon(Icons.delete, size: 18, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              l10n.deleteFile,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    ];
  }
}

class _FileGridTile extends StatelessWidget {
  final String name;
  final String size;
  final String date;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final PopupMenuItemBuilder<String> menuBuilder;
  final ValueChanged<String> onMenuSelected;

  const _FileGridTile({
    required this.name,
    required this.size,
    required this.date,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.menuBuilder,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? const Color(0xFF111318) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 6, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? color.withValues(alpha: 0.75)
                  : const Color(0xFFE5E7EB),
              width: isDark ? 1.3 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.16 : 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: onMenuSelected,
                    itemBuilder: menuBuilder,
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    splashRadius: 18,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.more_horiz,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              AutoFitText(
                name,
                maxLines: 2,
                minFontSize: 9.5,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 3),
              AutoFitText(
                '$date • $size',
                maxLines: 1,
                minFontSize: 9,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3B82F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF3B82F6)
                : Colors.grey.withAlpha((0.5 * 255).round()),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: selected ? Colors.white : Colors.grey[600],
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
