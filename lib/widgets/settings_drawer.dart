import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pdf_toolkit/l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../utils/platform_helper.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        // e.g. "1.5.3 (32)"
        _version = '${info.version} (${info.buildNumber})';
      });
    }
  }

  Future<void> _selectSaveDirectory(
      BuildContext context, SettingsProvider settings) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Pick directory first as requested by user
      String? selectedDirectory = await FilePicker.getDirectoryPath();

      if (selectedDirectory != null) {
        await settings.setSaveDirectory(selectedDirectory);
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.saveDirectoryUpdatedSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSelectingDirectory(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.couldNotOpenUrl)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(': $e')),
        );
      }
    }
  }

  Future<void> _sendEmail(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'info@41software.com',
      query: 'subject=PDF Toolkit Feedback',
    );
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.couldNotOpenUrl)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(': $e')),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: _version,
      applicationIcon: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/logo.png',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
      ),
      children: [
        Text(l10n.pdfToolkitDescription),
        const SizedBox(height: 8),
        Text(l10n.aboutDescription),
        const SizedBox(height: 8),
        Text('â€¢ '),
        Text('â€¢ '),
        Text('â€¢ '),
        Text('â€¢ '),
        Text('â€¢ '),
        Text('â€¢ '),
        Text('â€¢ '),
        Text('â€¢ '),
        Text('â€¢ '),
        Text('â€¢ '),
        Text('â€¢ '),
        Text('â€¢ '),
        Text('â€¢ '),
        Text('â€¢ '),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _launchUrl(context, 'https://www.41software.com'),
          child: Row(
            children: [
              const Icon(Icons.language, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'www.41software.com',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          final l10n = AppLocalizations.of(context)!;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: settings.primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.settings,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.settings,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Language Section
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                trailing: DropdownButton<Locale>(
                  value: settings.locale,
                  underline: const SizedBox(),
                  onChanged: (Locale? newValue) {
                    if (newValue != null) {
                      settings.setLocale(newValue);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                        value: Locale('en'), child: Text(l10n.english)),
                    DropdownMenuItem(
                        value: Locale('tr'), child: Text(l10n.turkish)),
                    DropdownMenuItem(
                        value: Locale('de'), child: Text(l10n.german)),
                  ],
                ),
              ),

              const Divider(),

              // Theme Mode Section
              ListTile(
                leading: Icon(
                  settings.themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                title: Text(l10n.theme),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  underline: const SizedBox(),
                  onChanged: (ThemeMode? newValue) {
                    if (newValue != null) {
                      settings.setThemeMode(newValue);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                        value: ThemeMode.system, child: Text(l10n.appearance)),
                    DropdownMenuItem(
                        value: ThemeMode.light, child: Text(l10n.light)),
                    DropdownMenuItem(
                        value: ThemeMode.dark, child: Text(l10n.dark)),
                  ],
                ),
              ),

              const Divider(),

              // Color Theme Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.colorScheme,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: settings.primaryColor,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SettingsProvider.colorThemes.entries.map((entry) {
                    final isSelected = settings.primaryColor == entry.value;
                    return InkWell(
                      onTap: () => settings.setPrimaryColor(entry.value),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: entry.value,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: entry.value.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const Divider(height: 32),

              // Save Directory Section (Android only — iOS has no directory
              // picker; the app Documents folder is exposed through Files).
              if (!kIsWeb && !PlatformHelper.isIOS) ...[
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(l10n.saveDirectory),
                  subtitle: Text(
                    settings.saveDirectory.isEmpty
                        ? l10n.defaultAppDocuments
                        : settings.saveDirectory,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _selectSaveDirectory(context, settings),
                  ),
                ),
                const Divider(),
              ],

              // iOS: explain where saved files live and how to reach them.
              if (PlatformHelper.isIOS) ...[
                ListTile(
                  leading: const Icon(Icons.folder_copy_outlined),
                  title: Text(l10n.savedFilesLocation),
                  subtitle: Text(l10n.iosFilesHint),
                  onTap: () => _launchUrl(context, 'shareddocuments://'),
                ),
                const Divider(),
              ],

              // Information Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.information,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: settings.primaryColor,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.about),
                onTap: () => _showAboutDialog(context),
              ),

              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.privacyPolicy),
                onTap: () => _launchUrl(context,
                    'https://www.41software.com/privacy/privacy_pdftoolkit.php'),
              ),

              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(l10n.feedback),
                onTap: () => _sendEmail(context),
              ),

              const Divider(),

              // Social Media Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.socialMedia,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: settings.primaryColor,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: const Text('Youtube'),
                onTap: () =>
                    _launchUrl(context, 'https://youtube.com/@41softwarecom'),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Instagram'),
                onTap: () =>
                    _launchUrl(context, 'https://instagram.com/41software'),
              ),
              ListTile(
                leading: const Icon(Icons
                    .alternate_email), // Using alternative icon for Twitter/X
                title: const Text('Twitter'),
                onTap: () => _launchUrl(context, 'https://x.com/41software'),
              ),
              ListTile(
                leading:
                    const Icon(Icons.music_note), // Using music note for TikTok
                title: const Text('Tiktok'),
                onTap: () =>
                    _launchUrl(context, 'https://tiktok.com/@41software'),
              ),
              if (!PlatformHelper.isIOS)
                ListTile(
                  leading: const Icon(Icons.android),
                  title: const Text('Google Play'),
                  subtitle: const Text('Download Android App'),
                  onTap: () => _launchUrl(context,
                      'https://play.google.com/store/apps/details?id=com.software41.pdftoolkit'),
                ),

              // Donation Section (not shown on iOS: external payment links are
              // not allowed inside App Store apps).
              if (!PlatformHelper.isIOS) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.donate,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: settings.primaryColor,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.coffee_outlined),
                  title: Text(l10n.buyMeACoffee),
                  onTap: () => _launchUrl(
                      context, 'https://buymeacoffee.com/41software'),
                ),
                ListTile(
                  leading: const Icon(Icons.paypal_outlined),
                  title: const Text('PayPal'),
                  onTap: () => _launchUrl(context, 'https://paypal.me/asbaypc'),
                ),
              ],

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}
