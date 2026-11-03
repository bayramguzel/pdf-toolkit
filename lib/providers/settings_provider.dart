import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color, Locale, ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  Color _primaryColor = const Color(0xFF22D3EE); // Cyan
  String _saveDirectory = '';
  Locale _locale = const Locale('en');
  List<String> _recentFiles = [];
  bool _isLocaleManuallySet = false;
  String _lastSplashDate = '';

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  String get saveDirectory => _saveDirectory;
  Locale get locale => _locale;
  List<String> get recentFiles => _recentFiles;
  bool get isLocaleManuallySet => _isLocaleManuallySet;
  String get lastSplashDate => _lastSplashDate;

  // Available color themes
  static const Map<String, Color> colorThemes = {
    'Cyan': Color(0xFF22D3EE),
    'Blue': Color(0xFF3B82F6),
    'Purple': Color(0xFF8B5CF6),
    'Green': Color(0xFF10B981),
    'Orange': Color(0xFFF59E0B),
    'Pink': Color(0xFFEC4899),
    'Red': Color(0xFFEF4444),
  };

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    _primaryColor = Color(prefs.getInt('primaryColor') ?? 0xFF22D3EE);
    _saveDirectory = prefs.getString('saveDirectory') ??
        '/storage/emulated/0/Download/PDFToolkit';

    // Check if locale was manually set
    final savedLocale = prefs.getString('locale');
    if (savedLocale != null) {
      _isLocaleManuallySet = true;
      _locale = Locale(savedLocale);
    } else {
      _isLocaleManuallySet = false;
      // Try to get system locale, fallback to 'en'
      try {
        final systemLocale = PlatformDispatcher.instance.locale;
        final languageCode = systemLocale.languageCode;
        // Only use if it's one of our supported languages
        if (['en', 'tr', 'de'].contains(languageCode)) {
          _locale = Locale(languageCode);
        } else {
          _locale = const Locale('en');
        }
      } catch (e) {
        _locale = const Locale('en');
      }
    }

    _recentFiles = prefs.getStringList('recentFiles') ?? [];
    _lastSplashDate = prefs.getString('lastSplashDate') ?? '';
    notifyListeners();
  }

  Future<void> setLastSplashDate(String date) async {
    _lastSplashDate = date;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSplashDate', date);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.toARGB32());
    notifyListeners();
  }

  Future<void> setSaveDirectory(String directory) async {
    _saveDirectory = directory;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saveDirectory', directory);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    _isLocaleManuallySet = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    notifyListeners();
  }

  Future<void> addRecentFile(String filePath) async {
    _recentFiles.remove(filePath); // Remove if exists
    _recentFiles.insert(0, filePath); // Add to beginning
    if (_recentFiles.length > 10) {
      _recentFiles = _recentFiles.sublist(0, 10); // Keep max 10 files
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentFiles', _recentFiles);
    notifyListeners();
  }

  Future<void> clearRecentFiles() async {
    _recentFiles.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recentFiles');
    notifyListeners();
  }
}
