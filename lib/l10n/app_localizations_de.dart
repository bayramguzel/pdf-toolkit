// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'PDF Werkzeugkasten';

  @override
  String get homeTitle => 'PDF Werkzeugkasten';

  @override
  String get homeSubtitle => 'All-in-One PDF-Lösung';

  @override
  String get skip => 'Überspringen';

  @override
  String get readPdf => 'PDF Lesen';

  @override
  String get openFolder => 'Ordner öffnen';

  @override
  String get mergePdf => 'PDFs Zusammenführen';

  @override
  String get mergeInstructions =>
      'Ziehen Sie die Dateien zum Neuordnen und klicken Sie dann auf Zusammenführen.';

  @override
  String get splitPdf => 'PDF Teilen';

  @override
  String get splitInstructions =>
      'Wählen Sie die Seiten aus, die Sie in eine neue PDF-Datei extrahieren möchten.';

  @override
  String get compressPdf => 'PDF komprimieren';

  @override
  String get encryptPdf => 'PDF verschlüsseln';

  @override
  String get pdfToImage => 'PDF zu Bild';

  @override
  String get pdfToText => 'Text Extrahieren';

  @override
  String get rotatePdf => 'Seiten Drehen';

  @override
  String get removePdf => 'Seiten Entfernen';

  @override
  String get reorderPdf => 'Seiten Neu Ordnen';

  @override
  String get watermarkPdf => 'Wasserzeichen Hinzufügen';

  @override
  String get imageToPdf => 'Bild zu PDF';

  @override
  String get imageToPdfDesc =>
      'Konvertieren Sie Bilder (JPG, PNG, BMP, GIF) in eine einzige PDF-Datei.';

  @override
  String get wordToPdf => 'Word zu PDF';

  @override
  String get settings => 'Einstellungen';

  @override
  String get appearance => 'Aussehen';

  @override
  String get darkMode => 'Dunkler Modus';

  @override
  String get colorScheme => 'Farbschema';

  @override
  String get storage => 'Speicher';

  @override
  String get saveDirectory => 'Speicherordner';

  @override
  String get shareAppMessage =>
      'Führen Sie 15 leistungsstarke PDF-Operationen in einer App aus! (Lesen, Zusammenführen, Teilen, Komprimieren, Drehen, Seiten löschen, Neu anordnen, Wasserzeichen, Verschlüsseln, Entsperren, PDF zu Bild, PDF zu Text, Bild zu PDF, Text zu PDF, Rich-Text Notizblock)';

  @override
  String get fileDownloaded => 'Datei erfolgreich heruntergeladen.';

  @override
  String get shareFile => 'PDF-Datei teilen';

  @override
  String currentDirectory(String path) {
    return 'Aktuell: $path';
  }

  @override
  String get changeDirectory => 'Ändern';

  @override
  String get about => 'Über';

  @override
  String get privacyPolicy => 'Datenschutz';

  @override
  String get connect => 'Verbinden';

  @override
  String get supportUs => 'Unterstützen Sie uns';

  @override
  String get buyMeACoffee => 'Kauf mir einen Kaffee';

  @override
  String get language => 'Sprache';

  @override
  String get theme => 'Thema';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get defaultAppDocuments => 'Standard (App-Dokumente)';

  @override
  String saveDirectoryUpdated(String path) {
    return 'Speicherverzeichnis aktualisiert auf: $path';
  }

  @override
  String errorSelectingDirectory(String error) {
    return 'Fehler beim Auswählen des Verzeichnisses: $error';
  }

  @override
  String get pdfToolkitDescription => 'Professionelle PDF-Tools für Android.';

  @override
  String get website => 'Webseite';

  @override
  String get socialMedia => 'Soziale Medien';

  @override
  String get donate => 'Spenden';

  @override
  String get feedback => 'Feedback';

  @override
  String get version => 'Version';

  @override
  String get aboutDescription =>
      'Ein umfassendes PDF-Verwaltungstool mit 14 leistungsstarken Funktionen:';

  @override
  String get resetToDefault => 'Auf Standard zurücksetzen';

  @override
  String get information => 'Informationen';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get selectThemeMode => 'Themenmodus auswählen';

  @override
  String get couldNotOpenUrl => 'URL konnte nicht geöffnet werden';

  @override
  String get storagePermissionRequired =>
      'Speicherberechtigung ist erforderlich. Bitte erteilen Sie die Berechtigung in den App-Einstellungen, um einen Speicherordner auszuwählen.';

  @override
  String get saveDirectoryUpdatedSuccess =>
      'Speicherverzeichnis erfolgreich aktualisiert! Alle Dateien werden hier gespeichert.';

  @override
  String get pageSize => 'Seitengröße';

  @override
  String get portrait => 'Hochformat';

  @override
  String get landscape => 'Querformat';

  @override
  String get imagesPerPage => 'Bilder pro Seite';

  @override
  String get marginLabel => 'Rand';

  @override
  String get autoEnhanceColors => 'Farben automatisch verbessern';

  @override
  String get addMoreImages => 'Mehr Bilder hinzufügen';

  @override
  String get loading => 'Laden...';

  @override
  String get loadingInfo => 'Info wird geladen...';

  @override
  String get share => 'Teilen';

  @override
  String get imagesSaved => 'Bilder gespeichert';

  @override
  String get ok => 'OK';

  @override
  String get preview => 'Vorschau';

  @override
  String get viewLocation => 'Speicherort Anzeigen';

  @override
  String get shareAll => 'Alle Teilen';

  @override
  String get goHome => 'Zum Startbildschirm';

  @override
  String get fullPage => 'Ganze Seite';

  @override
  String get sideBySide => 'Nebeneinander';

  @override
  String get grid2x2 => 'Gitter 2x2';

  @override
  String get grid3x2 => 'Gitter 3x2';

  @override
  String get grid3x3 => 'Gitter 3x3';

  @override
  String get featureReadView => 'PDFs lesen und anzeigen';

  @override
  String get featureMerge => 'Mehrere PDFs zusammenführen';

  @override
  String get featureSplit => 'PDFs teilen';

  @override
  String get featureCompress => 'Dateigröße komprimieren';

  @override
  String get featureToImage => 'In Bilder konvertieren';

  @override
  String get featureEncrypt => 'Verschlüsseln und sichern';

  @override
  String get featureUnlock => 'Entsperren und Passwörter entfernen';

  @override
  String get featureToWord => 'PDF zu Word (RTF/TXT)';

  @override
  String get featureRotate => 'Seiten drehen';

  @override
  String get featureWatermark => 'Wasserzeichen hinzufügen';

  @override
  String get featureRemove => 'Seiten entfernen';

  @override
  String get featureReorder => 'Seiten neu ordnen';

  @override
  String get featureImageToPdf => 'Bild zu PDF';

  @override
  String get featureWordToPdf => 'Word zu PDF';

  @override
  String get english => 'Englisch';

  @override
  String get turkish => 'Türkisch';

  @override
  String get german => 'Deutsch';

  @override
  String get selectFile => 'Datei Auswählen';

  @override
  String get noFileSelected => 'Keine Datei ausgewählt';

  @override
  String get processing => 'Verarbeitung...';

  @override
  String get success => 'Erfolgreich!';

  @override
  String get error => 'Fehler';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get close => 'Schließen';

  @override
  String get save => 'Speichern';

  @override
  String get selectFiles => 'Dateien Auswählen';

  @override
  String get pdfFiles => 'PDF-Dateien';

  @override
  String get imageFiles => 'Bilddateien';

  @override
  String get wordFiles => 'Word-Dateien';

  @override
  String get reorderingPages => 'Seiten werden neu geordnet...';

  @override
  String processingPage(int page, int total) {
    return 'Seite $page von $total wird verarbeitet...';
  }

  @override
  String errorReorderingPages(String error) {
    return 'Fehler beim Neuordnen der Seiten: $error';
  }

  @override
  String get pagesReorderedSuccessfully => 'Seiten erfolgreich neu geordnet';

  @override
  String get resetOrder => 'Reihenfolge zurücksetzen';

  @override
  String get reverseOrder => 'Reihenfolge umkehren';

  @override
  String get selectedFile => 'Ausgewählte Datei:';

  @override
  String totalPages(int count) {
    return 'Gesamtseiten: $count';
  }

  @override
  String get reorderInstructions =>
      'Ziehen Sie die Seiten zum Neuordnen oder verwenden Sie die Pfeiltasten';

  @override
  String pageNumber(int number) {
    return 'Seite $number';
  }

  @override
  String originalPosition(int number) {
    return 'Ursprüngliche Position: $number';
  }

  @override
  String get moveToTop => 'Nach oben verschieben';

  @override
  String get moveUp => 'Nach oben';

  @override
  String get moveDown => 'Nach unten';

  @override
  String get moveToBottom => 'Nach unten verschieben';

  @override
  String get reorderPagesButton => 'SEITEN NEU ORDNEN';

  @override
  String get saveReorderedPdf => 'Neu geordnete PDF speichern';

  @override
  String get selectDifferentFile => 'Andere Datei auswählen';

  @override
  String get rotatingPdf => 'PDF wird gedreht...';

  @override
  String rotatingPage(int current, int total) {
    return 'Drehe Seite $current von $total...';
  }

  @override
  String errorRotatingPdf(String error) {
    return 'Fehler beim Drehen der PDF: $error';
  }

  @override
  String get pdfRotatedSuccessfully => 'PDF erfolgreich gedreht!';

  @override
  String get rotateInstructions => 'Drehen Sie Seiten in Ihrem PDF-Dokument.';

  @override
  String pagesCount(int count) {
    return '$count Seiten';
  }

  @override
  String get rotationAngle => 'Drehwinkel';

  @override
  String get selectPages => 'Seiten auswählen';

  @override
  String get rotatePdfButton => 'PDF drehen';

  @override
  String get backToHome => 'Zurück zur Startseite';

  @override
  String get cannotRemoveAllPages =>
      'Es können nicht alle Seiten entfernt werden. Mindestens eine Seite muss übrig bleiben.';

  @override
  String get removingPages => 'Seiten werden entfernt...';

  @override
  String errorRemovingPages(String error) {
    return 'Fehler beim Entfernen der Seiten: $error';
  }

  @override
  String get pagesRemovedSuccessfully => 'Seiten erfolgreich entfernt';

  @override
  String get removeInstructions =>
      'Wählen Sie die Seiten aus, die aus Ihrem PDF-Dokument entfernt werden sollen';

  @override
  String pagesToRemove(int count) {
    return 'Zu entfernende Seiten: $count';
  }

  @override
  String remainingPages(int count) {
    return 'Verbleibende Seiten: $count';
  }

  @override
  String get selectPagesToRemove => 'Zu entfernende Seiten auswählen:';

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get deselectAll => 'Alle abwählen';

  @override
  String get clear => 'Leeren';

  @override
  String get removeSelectedPagesButton => 'AUSGEWÄHLTE SEITEN ENTFERNEN';

  @override
  String get toRemove => 'Zu entfernen';

  @override
  String get selectPagesToRemoveButton => 'Zu entfernende Seiten auswählen';

  @override
  String removePagesCountButton(int count) {
    return '$count Seite(n) entfernen';
  }

  @override
  String get addingWatermark => 'Wasserzeichen wird hinzugefügt...';

  @override
  String addingWatermarkToPage(int current, int total) {
    return 'Füge Wasserzeichen zu Seite $current von $total hinzu...';
  }

  @override
  String errorAddingWatermark(String error) {
    return 'Fehler beim Hinzufügen des Wasserzeichens: $error';
  }

  @override
  String get watermarkAddedSuccessfully =>
      'Wasserzeichen erfolgreich hinzugefügt';

  @override
  String get livePreview => 'Live-Vorschau';

  @override
  String get watermarkText => 'Wasserzeichen-Text';

  @override
  String get opacity => 'Deckkraft';

  @override
  String get fontSize => 'Schriftgröße';

  @override
  String get rotation => 'Drehung';

  @override
  String get position => 'Position';

  @override
  String get topLeft => 'Oben links';

  @override
  String get topRight => 'Oben rechts';

  @override
  String get bottomLeft => 'Unten links';

  @override
  String get bottomRight => 'Unten rechts';

  @override
  String get center => 'Mitte';

  @override
  String get color => 'Farbe';

  @override
  String get addWatermarkButton => 'WASSERZEICHEN HINZUFÜGEN';

  @override
  String get previewInstructions =>
      'Die Vorschau wird aktualisiert, wenn Sie die Einstellungen ändern';

  @override
  String get watermarkSettings => 'Wasserzeichen-Einstellungen:';

  @override
  String get enterWatermarkText => 'Wasserzeichen-Text eingeben';

  @override
  String get grey => 'Grau';

  @override
  String get red => 'Rot';

  @override
  String get blue => 'Blau';

  @override
  String get green => 'Grün';

  @override
  String get black => 'Schwarz';

  @override
  String get encryptPdfDescription =>
      'Fügen Sie Ihrer PDF-Datei ein Passwort hinzu, um sie vor unbefugtem Zugriff zu schützen.';

  @override
  String get setPasswordDescription =>
      'Legen Sie ein Passwort für Ihr Dokument fest.';

  @override
  String get password => 'Passwort';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get enterStrongPassword => 'Geben Sie ein starkes Passwort ein';

  @override
  String get reEnterPassword => 'Geben Sie Ihr Passwort erneut ein';

  @override
  String get encryptionNote =>
      'Hinweis: Verwendet eine standardmäßige, weitgehend kompatible Verschlüsselung. Die Datei erfordert ein Passwort in Standard-PDF-Readern.';

  @override
  String get encryptingPdf => 'PDF wird verschlüsselt...';

  @override
  String get pdfEncryptedSuccessfully => 'PDF erfolgreich verschlüsselt!';

  @override
  String get pleaseSelectPdfFirst =>
      'Bitte wählen Sie zuerst eine PDF-Datei aus.';

  @override
  String get passwordCannotBeEmpty => 'Das Passwort darf nicht leer sein.';

  @override
  String get passwordsDoNotMatch => 'Die Passwörter stimmen nicht überein.';

  @override
  String failedToEncryptPdf(String error) {
    return 'PDF konnte nicht verschlüsselt werden: $error';
  }

  @override
  String get unlockPdf => 'PDF entsperren';

  @override
  String get unlockPdfDescription =>
      'Entfernen Sie den Passwortschutz aus Ihrer PDF-Datei.';

  @override
  String get unlockingPdf => 'PDF wird entsperrt...';

  @override
  String get invalidPassword =>
      'Ungültiges Passwort. Bitte versuchen Sie es erneut.';

  @override
  String get pdfNoPassword => 'Diese PDF-Datei hat kein Passwort.';

  @override
  String get pdfUnlockedSuccessfully =>
      'PDF erfolgreich entsperrt! Das Passwort wurde entfernt.';

  @override
  String failedToUnlockPdf(String error) {
    return 'PDF konnte nicht entsperrt werden: $error';
  }

  @override
  String get enterPdfPassword => 'PDF-Passwort eingeben';

  @override
  String get compressPdfDescription =>
      'Reduzieren Sie die Dateigröße Ihrer PDF-Datei, indem Sie deren Inhalt komprimieren.';

  @override
  String get compressInstructions =>
      'Passen Sie die Komprimierungsstufe an und klicken Sie dann auf Komprimieren.';

  @override
  String get compressingPdf => 'PDF wird komprimiert...';

  @override
  String get applyingCompression => 'Komprimierung wird angewendet...';

  @override
  String get savingCompressedPdf => 'Komprimierte PDF wird gespeichert...';

  @override
  String get pdfCompressedSuccessfully => 'PDF erfolgreich komprimiert!';

  @override
  String unableToCompressFurther(String original, String result) {
    return 'Weitere Komprimierung nicht möglich. Original: $original, Ergebnis: $result. Diese PDF ist wahrscheinlich bereits optimiert oder enthält komprimierte Inhalte.';
  }

  @override
  String failedToCompressPdf(String error) {
    return 'PDF konnte nicht komprimiert werden: $error. Diese Methode funktioniert am besten bei bildlastigen PDFs.';
  }

  @override
  String reducedFromTo(String original, String result) {
    return 'Reduziert von $original auf $result';
  }

  @override
  String get compressionLevel => 'Komprimierungsstufe';

  @override
  String get bestCompression => 'Beste (Kleinste Dateigröße)';

  @override
  String get normalCompression => 'Normal (Ausgewogen)';

  @override
  String get noCompression => 'Keine (Keine Komprimierung)';

  @override
  String get loadingPdf => 'PDF wird geladen...';

  @override
  String errorLoadingPdf(String error) {
    return 'Fehler beim Laden der PDF: $error';
  }

  @override
  String get pleaseSelectValidPdfFirst =>
      'Bitte wählen Sie zuerst eine gültige PDF-Datei aus.';

  @override
  String get compressionSettings => 'Komprimierungseinstellungen';

  @override
  String get maximumCompression => 'Maximale Komprimierung';

  @override
  String get bestFileSizeReduction => 'Beste Reduzierung der Dateigröße';

  @override
  String get balanced => 'Ausgewogen';

  @override
  String get goodCompressionWithQuality => 'Gute Komprimierung mit Qualität';

  @override
  String get noCompressionTitle => 'Keine Komprimierung';

  @override
  String get preserveOriginalQuality => 'Originalqualität beibehalten';

  @override
  String get optimizationTips => 'Optimierungstipps';

  @override
  String get tip1 => 'PDFs mit vielen Bildern lassen sich besser komprimieren';

  @override
  String get tip2 =>
      'Nur-Text-PDFs lassen sich möglicherweise nicht stark reduzieren';

  @override
  String get tip3 => 'Bereits optimierte PDFs lassen sich nicht komprimieren';

  @override
  String get preparingConversion => 'Konvertierung wird vorbereitet...';

  @override
  String convertingPage(int page, int total) {
    return 'Seite $page von $total wird konvertiert...';
  }

  @override
  String get pdfConvertedToImagesSuccess =>
      'PDF erfolgreich in Bilder konvertiert!';

  @override
  String get readyToConvert => 'Bereit zur Konvertierung';

  @override
  String get pdfToImageDescription =>
      'Jede PDF-Seite wird in eine separate Bilddatei mit Vorschau-, Speicher- und Freigabeoptionen konvertiert.';

  @override
  String get convertToImages => 'In Bilder konvertieren';

  @override
  String get pdfToImageLongDescription =>
      'Konvertieren Sie jede Seite einer PDF-Datei in ein hochwertiges PNG- oder JPEG-Bild.';

  @override
  String get outputFormat => 'Ausgabeformat';

  @override
  String get losslessBestQuality => 'Verlustfrei, beste Qualität';

  @override
  String get smallerFileSize => 'Kleinere Dateigröße';

  @override
  String get jpegQuality => 'JPEG-Qualität';

  @override
  String get low => 'Niedrig';

  @override
  String get high => 'Hoch';

  @override
  String errorConvertingPdfToImages(String error) {
    return 'Fehler beim Konvertieren von PDF in Bilder: $error';
  }

  @override
  String get noImagesCreated => 'Es wurden keine Bilder erstellt';

  @override
  String get pdfToWord => 'PDF zu Word/Text';

  @override
  String get extractingText => 'Text wird extrahiert...';

  @override
  String get noTextExtractedError =>
      'Aus dieser PDF-Datei konnte kein Text extrahiert werden. Die Datei enthält möglicherweise nur Bilder oder hat Text in einem nicht standardmäßigen Format.';

  @override
  String failedToExtractText(String error) {
    return 'Textextraktion fehlgeschlagen: $error';
  }

  @override
  String get rtfExportSuccess =>
      'Dokument erfolgreich als RTF exportiert! Sie können es mit Microsoft Word öffnen.';

  @override
  String get textExtractSuccess => 'Text erfolgreich extrahiert!';

  @override
  String get pdfToWordDescription =>
      'Konvertieren Sie Ihre PDF-Datei in Word-kompatibles RTF oder einfachen Text.';

  @override
  String get chooseOutputFormat => 'Ausgabeformat wählen';

  @override
  String get wordRtf => 'Word (RTF)';

  @override
  String get bestForEditing => 'Am besten zum Bearbeiten';

  @override
  String get textTxt => 'Text (TXT)';

  @override
  String get plainTextOnly => 'Nur einfacher Text';

  @override
  String get convertNow => 'Jetzt konvertieren';

  @override
  String outputFormatLabel(String format) {
    return 'Ausgabe: $format';
  }

  @override
  String get selectWordDocError =>
      'Bitte wählen Sie ein Word-Dokument (.docx) aus. Hinweis: .doc wird noch nicht unterstützt.';

  @override
  String get convertingWordToPdf => 'Word wird in PDF konvertiert...';

  @override
  String get wordDocEmptyError =>
      'Das Word-Dokument ist leer oder konnte nicht gelesen werden.';

  @override
  String get wordToPdfConvertSuccess =>
      'Word-Dokument erfolgreich in PDF konvertiert!';

  @override
  String get wordToPdfDescription =>
      'Konvertieren Sie Ihre Word-Dokumente (.docx, .doc) in hochwertige PDF-Dateien.';

  @override
  String failedToConvertWordToPdf(String error) {
    return 'Fehler beim Konvertieren von Word in PDF: $error\n\nHinweis: In dieser Version wird nur Textinhalt unterstützt.';
  }

  @override
  String get dropWordFileHere =>
      'Word-Datei hier ablegen oder zum Durchsuchen klicken';

  @override
  String get pdfTools => 'PDF-Tools';

  @override
  String get unlock => 'Entsperren';

  @override
  String get converting => 'Konvertierung...';

  @override
  String get orientation => 'Ausrichtung';

  @override
  String get convert => 'Konvertieren';

  @override
  String get merging => 'Zusammenführen...';

  @override
  String get splitting => 'Aufteilen...';

  @override
  String get convertToPdf => 'In PDF konvertieren';

  @override
  String get viewSearchAnnotate => 'Ansehen, Suchen & Annotieren';

  @override
  String get combineFiles => 'Dateien Zusammenführen';

  @override
  String get extractPages => 'Seiten Extrahieren';

  @override
  String get reduceSize => 'Größe Reduzieren';

  @override
  String get addPassword => 'Passwort Hinzufügen';

  @override
  String get removePass => 'Passwort Entfernen';

  @override
  String get turnPages => 'Seiten Drehen';

  @override
  String get deletePages => 'Seiten Löschen';

  @override
  String get arrangePages => 'Seiten Anordnen';

  @override
  String get addTextImage => 'Text/Bild Hinzufügen';

  @override
  String get pngJpeg => 'PNG/JPEG';

  @override
  String get toRtfTxt => 'Zu RTF/TXT';

  @override
  String get convertImages => 'Bilder Konvertieren';

  @override
  String get textToPdf => 'Text zu PDF';

  @override
  String get convertTxt => 'TXT/RTF konvertieren';

  @override
  String get textToPdfDescription =>
      'Konvertieren Sie einfache Text- (.txt) oder Rich-Text-Dateien (.rtf) in das PDF-Format.';

  @override
  String clickToSelectFile(String fileType, String plural) {
    return 'Klicken Sie, um $fileType-Datei$plural auszuwählen';
  }

  @override
  String youCanSelectMultiple(String fileType) {
    return 'Sie können mehrere $fileType-Dateien auswählen';
  }

  @override
  String supportedFormats(String formats) {
    return 'Unterstützt: $formats';
  }

  @override
  String get notepad => 'Notizblock';

  @override
  String get notepadDescription =>
      'Erstellen Sie Notizen mit Bildern und Stilen und speichern Sie diese als PDF';

  @override
  String get featureNotepad => 'Reiche PDF-Notizen erstellen';

  @override
  String get saveAsPdf => 'Als PDF speichern';

  @override
  String get insertImage => 'Bild einfügen';

  @override
  String get pleaseEnterSomeText => 'Bitte geben Sie zuerst etwas Text ein';

  @override
  String get creatingPdf => 'PDF wird erstellt...';

  @override
  String get pdfCreatedSuccessfully => 'PDF erfolgreich erstellt!';

  @override
  String get selectColor => 'Farbe auswählen';

  @override
  String get selectFontSize => 'Schriftgröße auswählen';

  @override
  String get selectFont => 'Schriftart auswählen';

  @override
  String get bold => 'Fett';

  @override
  String get italic => 'Kursiv';

  @override
  String get underline => 'Unterstrichen';

  @override
  String get textColor => 'Textfarbe';

  @override
  String get select => 'Wählen';

  @override
  String get myFiles => 'Meine Dateien';

  @override
  String get sortByName => 'Nach Name sortieren';

  @override
  String get sortByDate => 'Nach Datum sortieren';

  @override
  String get sortBySize => 'Nach Größe sortieren';

  @override
  String get noFilesFound => 'Keine Dateien in diesem Ordner gefunden.';

  @override
  String get errorOpeningFolder => 'Ordner konnte nicht geöffnet werden.';

  @override
  String get errorOpeningFile => 'Datei konnte nicht geöffnet werden.';

  @override
  String get errorDeletingFile => 'Datei konnte nicht gelöscht werden.';

  @override
  String get openFile => 'Öffnen';

  @override
  String get deleteFile => 'Löschen';

  @override
  String get confirmDelete => 'Datei löschen?';

  @override
  String confirmDeleteMessage(String name) {
    return 'Möchten Sie $name wirklich löschen?';
  }

  @override
  String get fileDeletedSuccess => 'Datei gelöscht.';

  @override
  String get saveToFiles => 'In Dateien sichern';

  @override
  String get savedToFiles => 'In Dateien gesichert';

  @override
  String get iosSaveImagesHint =>
      'Tipp: Wählen Sie „In Dateien sichern“, um alle Bilder auf dem iPhone zu behalten.';

  @override
  String get iosFilesHint => 'Dateien › Auf meinem iPhone › PDF Toolkit';

  @override
  String get chooseSaveLocationHint =>
      'Wählen Sie „In Dateien sichern“, um eine Kopie auf dem iPhone zu behalten.';

  @override
  String get savedFilesLocation => 'Speicherort der Dateien';

  @override
  String get openInFiles => 'In Dateien öffnen';

  @override
  String get chooseImageSource => 'Bilder hinzufügen aus';

  @override
  String get photoLibrary => 'Fotomediathek';

  @override
  String get browseFiles => 'Dateien';

  @override
  String get gridView => 'Rasteransicht';

  @override
  String get listView => 'Listenansicht';
}
