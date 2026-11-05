import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('tr')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'PDF Toolkit'**
  String get appTitle;

  /// Title on home screen
  ///
  /// In en, this message translates to:
  /// **'PDF Toolkit'**
  String get homeTitle;

  /// Subtitle on home screen
  ///
  /// In en, this message translates to:
  /// **'All-in-One PDF Solution'**
  String get homeSubtitle;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Read PDF tool
  ///
  /// In en, this message translates to:
  /// **'Read PDF'**
  String get readPdf;

  /// Open Folder button text
  ///
  /// In en, this message translates to:
  /// **'Open Folder'**
  String get openFolder;

  /// Merge PDF tool
  ///
  /// In en, this message translates to:
  /// **'Merge PDFs'**
  String get mergePdf;

  /// Split PDF tool
  ///
  /// In en, this message translates to:
  /// **'Split PDF'**
  String get splitPdf;

  /// Title for compress PDF screen
  ///
  /// In en, this message translates to:
  /// **'Compress PDF'**
  String get compressPdf;

  /// Title for encrypt PDF screen
  ///
  /// In en, this message translates to:
  /// **'Encrypt PDF'**
  String get encryptPdf;

  /// Title for PDF to Image tool
  ///
  /// In en, this message translates to:
  /// **'PDF to Image'**
  String get pdfToImage;

  /// PDF to Text tool
  ///
  /// In en, this message translates to:
  /// **'Extract Text'**
  String get pdfToText;

  /// Rotate pages tool
  ///
  /// In en, this message translates to:
  /// **'Rotate Pages'**
  String get rotatePdf;

  /// Remove pages tool
  ///
  /// In en, this message translates to:
  /// **'Remove Pages'**
  String get removePdf;

  /// Reorder pages tool
  ///
  /// In en, this message translates to:
  /// **'Reorder Pages'**
  String get reorderPdf;

  /// Add watermark tool
  ///
  /// In en, this message translates to:
  /// **'Add Watermark'**
  String get watermarkPdf;

  /// Image to PDF tool
  ///
  /// In en, this message translates to:
  /// **'Image to PDF'**
  String get imageToPdf;

  /// Image to PDF description
  ///
  /// In en, this message translates to:
  /// **'Convert images (JPG, PNG, BMP, GIF) to a single PDF file.'**
  String get imageToPdfDesc;

  /// Title for Word to PDF tool
  ///
  /// In en, this message translates to:
  /// **'Word to PDF'**
  String get wordToPdf;

  /// Settings menu
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Appearance section
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Dark mode toggle
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Color scheme option
  ///
  /// In en, this message translates to:
  /// **'Color Scheme'**
  String get colorScheme;

  /// Storage section
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// Save directory setting
  ///
  /// In en, this message translates to:
  /// **'Save Directory'**
  String get saveDirectory;

  /// Message when sharing the app
  ///
  /// In en, this message translates to:
  /// **'Use 15 powerful PDF features completely free with PDF Toolkit! (Read, Merge, Split, Compress, Rotate, Remove Pages, Reorder, Watermark, Encrypt, Unlock, PDF to Image, PDF to Text, Image to PDF, Text to PDF, Rich-Text Notepad)'**
  String get shareAppMessage;

  /// Message when file is downloaded
  ///
  /// In en, this message translates to:
  /// **'File downloaded successfully.'**
  String get fileDownloaded;

  /// Subject when sharing a file
  ///
  /// In en, this message translates to:
  /// **'Share PDF File'**
  String get shareFile;

  /// Current directory label
  ///
  /// In en, this message translates to:
  /// **'Current: {path}'**
  String currentDirectory(String path);

  /// Change directory button
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeDirectory;

  /// About menu item
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Privacy policy menu item
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Social media section
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// Donation section
  ///
  /// In en, this message translates to:
  /// **'Support Us'**
  String get supportUs;

  /// Buy me a coffee link
  ///
  /// In en, this message translates to:
  /// **'Buy Me a Coffee'**
  String get buyMeACoffee;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Default save directory label
  ///
  /// In en, this message translates to:
  /// **'Default (App Documents)'**
  String get defaultAppDocuments;

  /// Save directory updated message
  ///
  /// In en, this message translates to:
  /// **'Save directory updated to: {path}'**
  String saveDirectoryUpdated(String path);

  /// Error message for directory selection
  ///
  /// In en, this message translates to:
  /// **'Error selecting directory: {error}'**
  String errorSelectingDirectory(String error);

  /// App description in about dialog
  ///
  /// In en, this message translates to:
  /// **'Professional PDF Tools for Android.'**
  String get pdfToolkitDescription;

  /// Website label
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Social media section
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get socialMedia;

  /// Donation section
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// Feedback menu item
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Detailed description in about dialog
  ///
  /// In en, this message translates to:
  /// **'A comprehensive PDF management tool with 14 powerful features:'**
  String get aboutDescription;

  /// Reset to default button
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// Information section
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// Select language dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Select theme mode dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Theme Mode'**
  String get selectThemeMode;

  /// Error message when URL cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open URL'**
  String get couldNotOpenUrl;

  /// Permission required message
  ///
  /// In en, this message translates to:
  /// **'Storage permission is required. Please grant permission in app settings to select a save folder.'**
  String get storagePermissionRequired;

  /// Success message for directory update
  ///
  /// In en, this message translates to:
  /// **'Save directory updated successfully! All files will be saved here.'**
  String get saveDirectoryUpdatedSuccess;

  /// Page size label
  ///
  /// In en, this message translates to:
  /// **'Page Size'**
  String get pageSize;

  /// Portrait orientation
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get portrait;

  /// Landscape orientation
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get landscape;

  /// Images per page label
  ///
  /// In en, this message translates to:
  /// **'Images per Page'**
  String get imagesPerPage;

  /// Margin label
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get marginLabel;

  /// Auto enhance colors toggle
  ///
  /// In en, this message translates to:
  /// **'Auto Enhance Colors'**
  String get autoEnhanceColors;

  /// Add more images button
  ///
  /// In en, this message translates to:
  /// **'Add More Images'**
  String get addMoreImages;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Loading info message
  ///
  /// In en, this message translates to:
  /// **'Loading info...'**
  String get loadingInfo;

  /// Share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Images saved title
  ///
  /// In en, this message translates to:
  /// **'Images Saved'**
  String get imagesSaved;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Preview button
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// View location button
  ///
  /// In en, this message translates to:
  /// **'View Location'**
  String get viewLocation;

  /// Share all button
  ///
  /// In en, this message translates to:
  /// **'Share All'**
  String get shareAll;

  /// Go to home button
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goHome;

  /// Full page layout
  ///
  /// In en, this message translates to:
  /// **'Full Page'**
  String get fullPage;

  /// Side by side layout
  ///
  /// In en, this message translates to:
  /// **'Side by Side'**
  String get sideBySide;

  /// 2x2 grid layout
  ///
  /// In en, this message translates to:
  /// **'Grid 2x2'**
  String get grid2x2;

  /// 3x2 grid layout
  ///
  /// In en, this message translates to:
  /// **'Grid 3x2'**
  String get grid3x2;

  /// 3x3 grid layout
  ///
  /// In en, this message translates to:
  /// **'Grid 3x3'**
  String get grid3x3;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Read & View PDFs'**
  String get featureReadView;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Merge Multiple PDFs'**
  String get featureMerge;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Split PDFs'**
  String get featureSplit;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Compress File Size'**
  String get featureCompress;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Convert to Images'**
  String get featureToImage;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Encrypt & Secure'**
  String get featureEncrypt;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Unlock & Remove Passwords'**
  String get featureUnlock;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'PDF to Word (RTF/TXT)'**
  String get featureToWord;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Rotate Pages'**
  String get featureRotate;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Add Watermarks'**
  String get featureWatermark;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Remove Pages'**
  String get featureRemove;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Reorder Pages'**
  String get featureReorder;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Image to PDF'**
  String get featureImageToPdf;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Word to PDF'**
  String get featureWordToPdf;

  /// English language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Turkish language
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// German language
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// Select file button
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// No file selected message
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// Processing message
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Select multiple files
  ///
  /// In en, this message translates to:
  /// **'Select Files'**
  String get selectFiles;

  /// PDF files label
  ///
  /// In en, this message translates to:
  /// **'PDF Files'**
  String get pdfFiles;

  /// Image files label
  ///
  /// In en, this message translates to:
  /// **'Image Files'**
  String get imageFiles;

  /// Word files label
  ///
  /// In en, this message translates to:
  /// **'Word Files'**
  String get wordFiles;

  /// Status message when reordering
  ///
  /// In en, this message translates to:
  /// **'Reordering pages...'**
  String get reorderingPages;

  /// Status message for page processing
  ///
  /// In en, this message translates to:
  /// **'Processing page {page} of {total}...'**
  String processingPage(int page, int total);

  /// Error message for reordering
  ///
  /// In en, this message translates to:
  /// **'Error reordering pages: {error}'**
  String errorReorderingPages(String error);

  /// Success message for reordering
  ///
  /// In en, this message translates to:
  /// **'Pages Reordered Successfully'**
  String get pagesReorderedSuccessfully;

  /// Tooltip for reset order
  ///
  /// In en, this message translates to:
  /// **'Reset Order'**
  String get resetOrder;

  /// Tooltip for reverse order
  ///
  /// In en, this message translates to:
  /// **'Reverse Order'**
  String get reverseOrder;

  /// Label for selected file
  ///
  /// In en, this message translates to:
  /// **'Selected File:'**
  String get selectedFile;

  /// Label for total pages
  ///
  /// In en, this message translates to:
  /// **'Total Pages: {count}'**
  String totalPages(int count);

  /// Instructions for reordering
  ///
  /// In en, this message translates to:
  /// **'Drag pages to reorder or use the arrow buttons'**
  String get reorderInstructions;

  /// Label for page number
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String pageNumber(int number);

  /// Label for original page position
  ///
  /// In en, this message translates to:
  /// **'Original position: {number}'**
  String originalPosition(int number);

  /// Tooltip for move to top
  ///
  /// In en, this message translates to:
  /// **'Move to Top'**
  String get moveToTop;

  /// Tooltip for move up
  ///
  /// In en, this message translates to:
  /// **'Move Up'**
  String get moveUp;

  /// Tooltip for move down
  ///
  /// In en, this message translates to:
  /// **'Move Down'**
  String get moveDown;

  /// Tooltip for move to bottom
  ///
  /// In en, this message translates to:
  /// **'Move to Bottom'**
  String get moveToBottom;

  /// Button text to start reordering
  ///
  /// In en, this message translates to:
  /// **'REORDER PAGES'**
  String get reorderPagesButton;

  /// Button text to save reordered PDF
  ///
  /// In en, this message translates to:
  /// **'Save Reordered PDF'**
  String get saveReorderedPdf;

  /// Button text to select a different file
  ///
  /// In en, this message translates to:
  /// **'Select Different File'**
  String get selectDifferentFile;

  /// Status message when rotating
  ///
  /// In en, this message translates to:
  /// **'Rotating PDF...'**
  String get rotatingPdf;

  /// Status message for page rotation
  ///
  /// In en, this message translates to:
  /// **'Rotating page {current} of {total}...'**
  String rotatingPage(int current, int total);

  /// Error message for rotation
  ///
  /// In en, this message translates to:
  /// **'Error rotating PDF: {error}'**
  String errorRotatingPdf(String error);

  /// Success message for rotation
  ///
  /// In en, this message translates to:
  /// **'PDF rotated successfully!'**
  String get pdfRotatedSuccessfully;

  /// Instructions for rotation
  ///
  /// In en, this message translates to:
  /// **'Rotate pages in your PDF document.'**
  String get rotateInstructions;

  /// Label for page count
  ///
  /// In en, this message translates to:
  /// **'{count} Pages'**
  String pagesCount(int count);

  /// Label for rotation angle
  ///
  /// In en, this message translates to:
  /// **'Rotation Angle'**
  String get rotationAngle;

  /// Label for page selection
  ///
  /// In en, this message translates to:
  /// **'Select Pages'**
  String get selectPages;

  /// Button text to start rotation
  ///
  /// In en, this message translates to:
  /// **'Rotate PDF'**
  String get rotatePdfButton;

  /// Link to go back to home screen
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// Error message when trying to remove all pages
  ///
  /// In en, this message translates to:
  /// **'Cannot remove all pages. At least one page must remain.'**
  String get cannotRemoveAllPages;

  /// Status message when removing pages
  ///
  /// In en, this message translates to:
  /// **'Removing pages...'**
  String get removingPages;

  /// Error message for page removal
  ///
  /// In en, this message translates to:
  /// **'Error removing pages: {error}'**
  String errorRemovingPages(String error);

  /// Success message for page removal
  ///
  /// In en, this message translates to:
  /// **'Pages Removed Successfully'**
  String get pagesRemovedSuccessfully;

  /// Instructions for page removal
  ///
  /// In en, this message translates to:
  /// **'Select pages to remove from your PDF document'**
  String get removeInstructions;

  /// Label for number of pages to remove
  ///
  /// In en, this message translates to:
  /// **'Pages to Remove: {count}'**
  String pagesToRemove(int count);

  /// Label for number of remaining pages
  ///
  /// In en, this message translates to:
  /// **'Remaining Pages: {count}'**
  String remainingPages(int count);

  /// Label for page removal selection
  ///
  /// In en, this message translates to:
  /// **'Select Pages to Remove:'**
  String get selectPagesToRemove;

  /// Button text to select all items
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// Button text to deselect all items
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// Button text to clear selection
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Button text to start page removal
  ///
  /// In en, this message translates to:
  /// **'REMOVE SELECTED PAGES'**
  String get removeSelectedPagesButton;

  /// Label for pages marked for removal
  ///
  /// In en, this message translates to:
  /// **'To Remove'**
  String get toRemove;

  /// Button text when no pages are selected for removal
  ///
  /// In en, this message translates to:
  /// **'Select Pages to Remove'**
  String get selectPagesToRemoveButton;

  /// Button text with count of pages to remove
  ///
  /// In en, this message translates to:
  /// **'Remove {count} Page(s)'**
  String removePagesCountButton(int count);

  /// Status message when adding watermark
  ///
  /// In en, this message translates to:
  /// **'Adding watermark...'**
  String get addingWatermark;

  /// Status message for page watermark
  ///
  /// In en, this message translates to:
  /// **'Adding watermark to page {current} of {total}...'**
  String addingWatermarkToPage(int current, int total);

  /// Error message for watermark
  ///
  /// In en, this message translates to:
  /// **'Error adding watermark: {error}'**
  String errorAddingWatermark(String error);

  /// Success message for watermark
  ///
  /// In en, this message translates to:
  /// **'Watermark Added Successfully'**
  String get watermarkAddedSuccessfully;

  /// Label for live preview section
  ///
  /// In en, this message translates to:
  /// **'Live Preview'**
  String get livePreview;

  /// Label for watermark text input
  ///
  /// In en, this message translates to:
  /// **'Watermark Text'**
  String get watermarkText;

  /// Label for opacity setting
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get opacity;

  /// Label for font size setting
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// Label for rotation setting
  ///
  /// In en, this message translates to:
  /// **'Rotation'**
  String get rotation;

  /// Label for position setting
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// Top left position
  ///
  /// In en, this message translates to:
  /// **'Top Left'**
  String get topLeft;

  /// Top right position
  ///
  /// In en, this message translates to:
  /// **'Top Right'**
  String get topRight;

  /// Bottom left position
  ///
  /// In en, this message translates to:
  /// **'Bottom Left'**
  String get bottomLeft;

  /// Bottom right position
  ///
  /// In en, this message translates to:
  /// **'Bottom Right'**
  String get bottomRight;

  /// Center position
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get center;

  /// Label for color setting
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// Button text to start adding watermark
  ///
  /// In en, this message translates to:
  /// **'ADD WATERMARK'**
  String get addWatermarkButton;

  /// Instructions for live preview
  ///
  /// In en, this message translates to:
  /// **'Preview updates as you change settings'**
  String get previewInstructions;

  /// Label for watermark settings section
  ///
  /// In en, this message translates to:
  /// **'Watermark Settings:'**
  String get watermarkSettings;

  /// Hint text for watermark input
  ///
  /// In en, this message translates to:
  /// **'Enter watermark text'**
  String get enterWatermarkText;

  /// Grey color
  ///
  /// In en, this message translates to:
  /// **'Grey'**
  String get grey;

  /// Red color
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// Blue color
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// Green color
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// Black color
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// Description for encrypt PDF screen
  ///
  /// In en, this message translates to:
  /// **'Add a password to your PDF file to protect it from unauthorized access.'**
  String get encryptPdfDescription;

  /// Instruction to set password
  ///
  /// In en, this message translates to:
  /// **'Set a password for your document.'**
  String get setPasswordDescription;

  /// Password label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Hint for password field
  ///
  /// In en, this message translates to:
  /// **'Enter a strong password'**
  String get enterStrongPassword;

  /// Hint for confirm password field
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reEnterPassword;

  /// Note about encryption compatibility
  ///
  /// In en, this message translates to:
  /// **'Note: Uses standard, widely-compatible encryption. The file will require a password in standard PDF readers.'**
  String get encryptionNote;

  /// Status message when encrypting
  ///
  /// In en, this message translates to:
  /// **'Encrypting PDF...'**
  String get encryptingPdf;

  /// Success message for encryption
  ///
  /// In en, this message translates to:
  /// **'PDF encrypted successfully!'**
  String get pdfEncryptedSuccessfully;

  /// Error message when no file selected
  ///
  /// In en, this message translates to:
  /// **'Please select a PDF file first.'**
  String get pleaseSelectPdfFirst;

  /// Error message when password is empty
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty.'**
  String get passwordCannotBeEmpty;

  /// Error message when passwords don't match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// Error message for encryption failure
  ///
  /// In en, this message translates to:
  /// **'Failed to encrypt PDF: {error}'**
  String failedToEncryptPdf(String error);

  /// Title for unlock PDF screen
  ///
  /// In en, this message translates to:
  /// **'Unlock PDF'**
  String get unlockPdf;

  /// Description for unlock PDF screen
  ///
  /// In en, this message translates to:
  /// **'Remove password protection from your PDF file.'**
  String get unlockPdfDescription;

  /// Status message when unlocking
  ///
  /// In en, this message translates to:
  /// **'Unlocking PDF...'**
  String get unlockingPdf;

  /// Error message for invalid password
  ///
  /// In en, this message translates to:
  /// **'Invalid password. Please try again.'**
  String get invalidPassword;

  /// Info message when the selected PDF has no password
  ///
  /// In en, this message translates to:
  /// **'This PDF has no password.'**
  String get pdfNoPassword;

  /// Success message for unlocking
  ///
  /// In en, this message translates to:
  /// **'PDF unlocked successfully! The password has been removed.'**
  String get pdfUnlockedSuccessfully;

  /// Error message for unlocking failure
  ///
  /// In en, this message translates to:
  /// **'Failed to unlock PDF: {error}'**
  String failedToUnlockPdf(String error);

  /// Label for password field
  ///
  /// In en, this message translates to:
  /// **'Enter PDF Password'**
  String get enterPdfPassword;

  /// Description for compress PDF screen
  ///
  /// In en, this message translates to:
  /// **'Reduce the file size of your PDF by compressing its content.'**
  String get compressPdfDescription;

  /// Instruction for compression
  ///
  /// In en, this message translates to:
  /// **'Adjust the compression level, then click Compress.'**
  String get compressInstructions;

  /// Status message when compressing
  ///
  /// In en, this message translates to:
  /// **'Compressing PDF...'**
  String get compressingPdf;

  /// Status message when applying compression
  ///
  /// In en, this message translates to:
  /// **'Applying compression...'**
  String get applyingCompression;

  /// Status message when saving
  ///
  /// In en, this message translates to:
  /// **'Saving compressed PDF...'**
  String get savingCompressedPdf;

  /// Success message for compression
  ///
  /// In en, this message translates to:
  /// **'PDF compressed successfully!'**
  String get pdfCompressedSuccessfully;

  /// Error message when compression doesn't help
  ///
  /// In en, this message translates to:
  /// **'Unable to compress further. Original: {original}, Result: {result}. This PDF is likely already optimized or contains compressed content.'**
  String unableToCompressFurther(String original, String result);

  /// Error message for compression failure
  ///
  /// In en, this message translates to:
  /// **'Failed to compress PDF: {error}. This method works best for image-heavy PDFs.'**
  String failedToCompressPdf(String error);

  /// Status message showing size reduction
  ///
  /// In en, this message translates to:
  /// **'Reduced from {original} to {result}'**
  String reducedFromTo(String original, String result);

  /// Label for compression level
  ///
  /// In en, this message translates to:
  /// **'Compression Level'**
  String get compressionLevel;

  /// Option for best compression
  ///
  /// In en, this message translates to:
  /// **'Best (Smallest file size)'**
  String get bestCompression;

  /// Option for normal compression
  ///
  /// In en, this message translates to:
  /// **'Normal (Balanced)'**
  String get normalCompression;

  /// Option for no compression
  ///
  /// In en, this message translates to:
  /// **'None (No compression)'**
  String get noCompression;

  /// Status message when loading PDF
  ///
  /// In en, this message translates to:
  /// **'Loading PDF...'**
  String get loadingPdf;

  /// Error message for loading PDF
  ///
  /// In en, this message translates to:
  /// **'Error loading PDF: {error}'**
  String errorLoadingPdf(String error);

  /// Error message when no valid file selected
  ///
  /// In en, this message translates to:
  /// **'Please select a valid PDF file first.'**
  String get pleaseSelectValidPdfFirst;

  /// Title for compression settings
  ///
  /// In en, this message translates to:
  /// **'Compression Settings'**
  String get compressionSettings;

  /// Option for maximum compression
  ///
  /// In en, this message translates to:
  /// **'Maximum Compression'**
  String get maximumCompression;

  /// Description for maximum compression
  ///
  /// In en, this message translates to:
  /// **'Best file size reduction'**
  String get bestFileSizeReduction;

  /// Option for balanced compression
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// Description for balanced compression
  ///
  /// In en, this message translates to:
  /// **'Good compression with quality'**
  String get goodCompressionWithQuality;

  /// Option for no compression
  ///
  /// In en, this message translates to:
  /// **'No Compression'**
  String get noCompressionTitle;

  /// Description for no compression
  ///
  /// In en, this message translates to:
  /// **'Preserve original quality'**
  String get preserveOriginalQuality;

  /// Title for optimization tips
  ///
  /// In en, this message translates to:
  /// **'Optimization Tips'**
  String get optimizationTips;

  /// Optimization tip 1
  ///
  /// In en, this message translates to:
  /// **'PDFs with many images compress better'**
  String get tip1;

  /// Optimization tip 2
  ///
  /// In en, this message translates to:
  /// **'Text-only PDFs may not reduce much'**
  String get tip2;

  /// Optimization tip 3
  ///
  /// In en, this message translates to:
  /// **'Already optimized PDFs won\'t compress'**
  String get tip3;

  /// Status message when starting conversion
  ///
  /// In en, this message translates to:
  /// **'Preparing conversion...'**
  String get preparingConversion;

  /// Status message for page conversion
  ///
  /// In en, this message translates to:
  /// **'Converting page {page} of {total}...'**
  String convertingPage(int page, int total);

  /// Success message for PDF to Image conversion
  ///
  /// In en, this message translates to:
  /// **'PDF converted to images successfully!'**
  String get pdfConvertedToImagesSuccess;

  /// Title when file is selected
  ///
  /// In en, this message translates to:
  /// **'Ready to Convert'**
  String get readyToConvert;

  /// Description for PDF to Image tool
  ///
  /// In en, this message translates to:
  /// **'Each PDF page will be converted to a separate image file with Preview, Save, and Share options.'**
  String get pdfToImageDescription;

  /// Button text to start conversion
  ///
  /// In en, this message translates to:
  /// **'Convert to Images'**
  String get convertToImages;

  /// Long description for PDF to Image tool
  ///
  /// In en, this message translates to:
  /// **'Convert every page of a PDF into a high-quality PNG or JPEG image.'**
  String get pdfToImageLongDescription;

  /// Label for output format selection
  ///
  /// In en, this message translates to:
  /// **'Output Format'**
  String get outputFormat;

  /// Description for PNG format
  ///
  /// In en, this message translates to:
  /// **'Lossless, best quality'**
  String get losslessBestQuality;

  /// Description for JPEG format
  ///
  /// In en, this message translates to:
  /// **'Smaller file size'**
  String get smallerFileSize;

  /// Label for JPEG quality slider
  ///
  /// In en, this message translates to:
  /// **'JPEG Quality'**
  String get jpegQuality;

  /// Label for low quality
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// Label for high quality
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// Error message for conversion
  ///
  /// In en, this message translates to:
  /// **'Error converting PDF to images: {error}'**
  String errorConvertingPdfToImages(String error);

  /// Error message when no images were generated
  ///
  /// In en, this message translates to:
  /// **'No images were created'**
  String get noImagesCreated;

  /// Title for PDF to Word tool
  ///
  /// In en, this message translates to:
  /// **'PDF to Word/Text'**
  String get pdfToWord;

  /// Status message when extracting text
  ///
  /// In en, this message translates to:
  /// **'Extracting text...'**
  String get extractingText;

  /// Error message when no text is found
  ///
  /// In en, this message translates to:
  /// **'No text could be extracted from this PDF. The file may contain only images or have text in a non-standard format.'**
  String get noTextExtractedError;

  /// Error message for text extraction
  ///
  /// In en, this message translates to:
  /// **'Failed to extract text: {error}'**
  String failedToExtractText(String error);

  /// Success message for RTF export
  ///
  /// In en, this message translates to:
  /// **'Document exported successfully as RTF! You can open it with Microsoft Word.'**
  String get rtfExportSuccess;

  /// Success message for text extraction
  ///
  /// In en, this message translates to:
  /// **'Text extracted successfully!'**
  String get textExtractSuccess;

  /// Description for PDF to Word tool
  ///
  /// In en, this message translates to:
  /// **'Convert your PDF to Word-compatible RTF or plain text.'**
  String get pdfToWordDescription;

  /// Label for format selection
  ///
  /// In en, this message translates to:
  /// **'Choose Output Format'**
  String get chooseOutputFormat;

  /// Option for RTF format
  ///
  /// In en, this message translates to:
  /// **'Word (RTF)'**
  String get wordRtf;

  /// Description for RTF format
  ///
  /// In en, this message translates to:
  /// **'Best for editing'**
  String get bestForEditing;

  /// Option for TXT format
  ///
  /// In en, this message translates to:
  /// **'Text (TXT)'**
  String get textTxt;

  /// Description for TXT format
  ///
  /// In en, this message translates to:
  /// **'Plain text only'**
  String get plainTextOnly;

  /// Button text to start conversion
  ///
  /// In en, this message translates to:
  /// **'Convert Now'**
  String get convertNow;

  /// Label showing selected output format
  ///
  /// In en, this message translates to:
  /// **'Output: {format}'**
  String outputFormatLabel(String format);

  /// Error message for unsupported Word format
  ///
  /// In en, this message translates to:
  /// **'Please select a Word document (.docx). Note: .doc is not supported yet.'**
  String get selectWordDocError;

  /// Status message when converting Word to PDF
  ///
  /// In en, this message translates to:
  /// **'Converting Word to PDF...'**
  String get convertingWordToPdf;

  /// Error message when Word doc is empty
  ///
  /// In en, this message translates to:
  /// **'The Word document is empty or could not be read.'**
  String get wordDocEmptyError;

  /// Success message for Word to PDF conversion
  ///
  /// In en, this message translates to:
  /// **'Word document converted to PDF successfully!'**
  String get wordToPdfConvertSuccess;

  /// Description for Word to PDF tool
  ///
  /// In en, this message translates to:
  /// **'Convert your Word documents (.docx, .doc) to high-quality PDF.'**
  String get wordToPdfDescription;

  /// Error message for Word to PDF conversion
  ///
  /// In en, this message translates to:
  /// **'Failed to convert Word to PDF: {error}\n\nNote: Only text content is supported in this version.'**
  String failedToConvertWordToPdf(String error);

  /// Label for Word file dropzone
  ///
  /// In en, this message translates to:
  /// **'Drop Word file here or click to browse'**
  String get dropWordFileHere;

  /// No description provided for @pdfTools.
  ///
  /// In en, this message translates to:
  /// **'PDF Tools'**
  String get pdfTools;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @converting.
  ///
  /// In en, this message translates to:
  /// **'Converting...'**
  String get converting;

  /// No description provided for @orientation.
  ///
  /// In en, this message translates to:
  /// **'Orientation'**
  String get orientation;

  /// No description provided for @convert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convert;

  /// No description provided for @merging.
  ///
  /// In en, this message translates to:
  /// **'Merging...'**
  String get merging;

  /// No description provided for @splitting.
  ///
  /// In en, this message translates to:
  /// **'Splitting...'**
  String get splitting;

  /// No description provided for @convertToPdf.
  ///
  /// In en, this message translates to:
  /// **'Convert to PDF'**
  String get convertToPdf;

  /// No description provided for @viewSearchAnnotate.
  ///
  /// In en, this message translates to:
  /// **'View, Search & Annotate'**
  String get viewSearchAnnotate;

  /// No description provided for @combineFiles.
  ///
  /// In en, this message translates to:
  /// **'Combine Files'**
  String get combineFiles;

  /// No description provided for @extractPages.
  ///
  /// In en, this message translates to:
  /// **'Extract Pages'**
  String get extractPages;

  /// No description provided for @reduceSize.
  ///
  /// In en, this message translates to:
  /// **'Reduce Size'**
  String get reduceSize;

  /// No description provided for @addPassword.
  ///
  /// In en, this message translates to:
  /// **'Add Password'**
  String get addPassword;

  /// No description provided for @removePass.
  ///
  /// In en, this message translates to:
  /// **'Remove Pass'**
  String get removePass;

  /// No description provided for @turnPages.
  ///
  /// In en, this message translates to:
  /// **'Turn Pages'**
  String get turnPages;

  /// No description provided for @deletePages.
  ///
  /// In en, this message translates to:
  /// **'Delete Pages'**
  String get deletePages;

  /// No description provided for @arrangePages.
  ///
  /// In en, this message translates to:
  /// **'Arrange Pages'**
  String get arrangePages;

  /// No description provided for @addTextImage.
  ///
  /// In en, this message translates to:
  /// **'Add Text/Image'**
  String get addTextImage;

  /// No description provided for @pngJpeg.
  ///
  /// In en, this message translates to:
  /// **'PNG/JPEG'**
  String get pngJpeg;

  /// No description provided for @toRtfTxt.
  ///
  /// In en, this message translates to:
  /// **'To RTF/TXT'**
  String get toRtfTxt;

  /// No description provided for @convertImages.
  ///
  /// In en, this message translates to:
  /// **'Convert Images'**
  String get convertImages;

  /// No description provided for @textToPdf.
  ///
  /// In en, this message translates to:
  /// **'Text to PDF'**
  String get textToPdf;

  /// No description provided for @convertTxt.
  ///
  /// In en, this message translates to:
  /// **'Convert TXT/RTF'**
  String get convertTxt;

  /// No description provided for @textToPdfDescription.
  ///
  /// In en, this message translates to:
  /// **'Convert plain text (.txt) or Rich Text (.rtf) files to PDF format.'**
  String get textToPdfDescription;

  /// File selection prompt
  ///
  /// In en, this message translates to:
  /// **'Click to select {fileType} file{plural}'**
  String clickToSelectFile(String fileType, String plural);

  /// Multiple file selection hint
  ///
  /// In en, this message translates to:
  /// **'You can select multiple {fileType} files'**
  String youCanSelectMultiple(String fileType);

  /// Supported file formats
  ///
  /// In en, this message translates to:
  /// **'Supported: {formats}'**
  String supportedFormats(String formats);

  /// Title for Notepad tool
  ///
  /// In en, this message translates to:
  /// **'Notepad to PDF'**
  String get notepad;

  /// Description for Notepad tool
  ///
  /// In en, this message translates to:
  /// **'Create rich text notes with images and styles, then save as PDF'**
  String get notepadDescription;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'Create Rich PDF Notes'**
  String get featureNotepad;

  /// Button to save as PDF
  ///
  /// In en, this message translates to:
  /// **'Save as PDF'**
  String get saveAsPdf;

  /// Tooltip for insert image
  ///
  /// In en, this message translates to:
  /// **'Insert Image'**
  String get insertImage;

  /// Error message when text is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter some text first'**
  String get pleaseEnterSomeText;

  /// Loading message when creating PDF
  ///
  /// In en, this message translates to:
  /// **'Creating PDF...'**
  String get creatingPdf;

  /// Success message after PDF creation
  ///
  /// In en, this message translates to:
  /// **'PDF created successfully!'**
  String get pdfCreatedSuccessfully;

  /// Title for color picker dialog
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// Title for font size picker dialog
  ///
  /// In en, this message translates to:
  /// **'Select Font Size'**
  String get selectFontSize;

  /// Title for font picker dialog
  ///
  /// In en, this message translates to:
  /// **'Select Font'**
  String get selectFont;

  /// Tooltip for bold button
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// Tooltip for italic button
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italic;

  /// Tooltip for underline button
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get underline;

  /// Tooltip for color button
  ///
  /// In en, this message translates to:
  /// **'Text Color'**
  String get textColor;

  /// Select button text
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// My files folder browser title
  ///
  /// In en, this message translates to:
  /// **'My Files'**
  String get myFiles;

  /// Sort by name option
  ///
  /// In en, this message translates to:
  /// **'Sort by Name'**
  String get sortByName;

  /// Sort by date option
  ///
  /// In en, this message translates to:
  /// **'Sort by Date'**
  String get sortByDate;

  /// Sort by size option
  ///
  /// In en, this message translates to:
  /// **'Sort by Size'**
  String get sortBySize;

  /// Message when folder is empty
  ///
  /// In en, this message translates to:
  /// **'No files found in this folder.'**
  String get noFilesFound;

  /// Error message when folder cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open the folder.'**
  String get errorOpeningFolder;

  /// Error message when a file cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open the file.'**
  String get errorOpeningFile;

  /// Error message when a file cannot be deleted
  ///
  /// In en, this message translates to:
  /// **'Could not delete the file.'**
  String get errorDeletingFile;

  /// Open file button
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openFile;

  /// Delete file button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteFile;

  /// Delete confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete File?'**
  String get confirmDelete;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String confirmDeleteMessage(String name);

  /// File deleted success message
  ///
  /// In en, this message translates to:
  /// **'File deleted.'**
  String get fileDeletedSuccess;

  /// iOS: open the share sheet so the user can save a copy anywhere
  ///
  /// In en, this message translates to:
  /// **'Save to Files'**
  String get saveToFiles;

  /// iOS: where app documents are visible
  ///
  /// In en, this message translates to:
  /// **'Files app › On My iPhone › PDF Toolkit'**
  String get iosFilesHint;

  /// iOS: hint shown after opening the share sheet
  ///
  /// In en, this message translates to:
  /// **'Choose “Save to Files” to keep a copy on your iPhone.'**
  String get chooseSaveLocationHint;

  /// iOS: settings row title for the Files app location
  ///
  /// In en, this message translates to:
  /// **'Saved files location'**
  String get savedFilesLocation;

  /// iOS: button that opens the Files app
  ///
  /// In en, this message translates to:
  /// **'Open in Files'**
  String get openInFiles;

  /// iOS: sheet title when picking images
  ///
  /// In en, this message translates to:
  /// **'Add images from'**
  String get chooseImageSource;

  /// iOS: pick images from Photos
  ///
  /// In en, this message translates to:
  /// **'Photo Library'**
  String get photoLibrary;

  /// iOS: pick images from the Files app
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get browseFiles;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
