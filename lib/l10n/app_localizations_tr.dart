// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'PDF Araç Seti';

  @override
  String get homeTitle => 'PDF Araç Seti';

  @override
  String get homeSubtitle => 'Hepsi Bir Arada PDF Çözümü';

  @override
  String get skip => 'Atla';

  @override
  String get readPdf => 'PDF Oku';

  @override
  String get openFolder => 'Klasörü Aç';

  @override
  String get mergePdf => 'PDF Birleştir';

  @override
  String get splitPdf => 'PDF Böl';

  @override
  String get compressPdf => 'PDF Sıkıştır';

  @override
  String get encryptPdf => 'PDF Şifrele';

  @override
  String get pdfToImage => 'PDF\'den Görüntüye';

  @override
  String get pdfToText => 'Metin Çıkar';

  @override
  String get rotatePdf => 'Sayfaları Döndür';

  @override
  String get removePdf => 'Sayfa Sil';

  @override
  String get reorderPdf => 'Sayfaları Yeniden Sırala';

  @override
  String get watermarkPdf => 'Filigran Ekle';

  @override
  String get imageToPdf => 'Resimden PDF\'e';

  @override
  String get imageToPdfDesc =>
      'Resimleri (JPG, PNG, BMP, GIF) tek bir PDF dosyasına dönüştürün.';

  @override
  String get wordToPdf => 'Word\'den PDF\'e';

  @override
  String get settings => 'Ayarlar';

  @override
  String get appearance => 'Görünüm';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get colorScheme => 'Renk Şeması';

  @override
  String get storage => 'Depolama';

  @override
  String get saveDirectory => 'Kayıt Klasörü';

  @override
  String get shareAppMessage =>
      'PDF Toolkit uygulaması ile 15 farklı güçlü PDF özelliğini tamamen ücretsiz kullanın! (Okuma, Birleştirme, Bölme, Sıkıştırma, Döndürme, Sayfa Silme, Sayfa Sıralama, Filigran, Şifreleme, Şifre Çözme, PDF\'den Resme, PDF\'den Metine, Resimden PDF\'e, Metinden PDF\'e, Zengin Not Defteri)';

  @override
  String get fileDownloaded => 'Dosya başarıyla indirildi.';

  @override
  String get shareFile => 'PDF Dosyasını Paylaş';

  @override
  String currentDirectory(String path) {
    return 'Mevcut: $path';
  }

  @override
  String get changeDirectory => 'Değiştir';

  @override
  String get about => 'Hakkında';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get connect => 'Bağlantı';

  @override
  String get supportUs => 'Bizi Destekle';

  @override
  String get buyMeACoffee => 'Bana Bir Kahve Alın';

  @override
  String get language => 'Dil';

  @override
  String get theme => 'Tema';

  @override
  String get light => 'Açık';

  @override
  String get dark => 'Koyu';

  @override
  String get defaultAppDocuments => 'Varsayılan (Uygulama Belgeleri)';

  @override
  String saveDirectoryUpdated(String path) {
    return 'Kayıt dizini şuna güncellendi: $path';
  }

  @override
  String errorSelectingDirectory(String error) {
    return 'Dizin seçilirken hata oluştu: $error';
  }

  @override
  String get pdfToolkitDescription => 'Android için Profesyonel PDF Araçları.';

  @override
  String get website => 'Web Sitesi';

  @override
  String get socialMedia => 'Sosyal Medya';

  @override
  String get donate => 'Bağış Yap';

  @override
  String get feedback => 'Geri Bildirim';

  @override
  String get version => 'Sürüm';

  @override
  String get aboutDescription =>
      '14 güçlü özelliğe sahip kapsamlı bir PDF yönetim aracı:';

  @override
  String get resetToDefault => 'Varsayılana Sıfırla';

  @override
  String get information => 'Bilgi';

  @override
  String get selectLanguage => 'Dil Seçin';

  @override
  String get selectThemeMode => 'Tema Modu Seçin';

  @override
  String get couldNotOpenUrl => 'URL açılamadı';

  @override
  String get storagePermissionRequired =>
      'Depolama izni gereklidir. Kayıt klasörü seçmek için lütfen uygulama ayarlarından izin verin.';

  @override
  String get saveDirectoryUpdatedSuccess =>
      'Kayıt dizini başarıyla güncellendi! Tüm dosyalar buraya kaydedilecek.';

  @override
  String get pageSize => 'Sayfa Boyutu';

  @override
  String get portrait => 'Dikey';

  @override
  String get landscape => 'Yatay';

  @override
  String get imagesPerPage => 'Sayfa Başına Resim';

  @override
  String get marginLabel => 'Kenar Boşluğu';

  @override
  String get autoEnhanceColors => 'Renkleri Otomatik İyileştir';

  @override
  String get addMoreImages => 'Daha Fazla Resim Ekle';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get loadingInfo => 'Bilgi yükleniyor...';

  @override
  String get share => 'Paylaş';

  @override
  String get imagesSaved => 'Resimler Kaydedildi';

  @override
  String get ok => 'Tamam';

  @override
  String get preview => 'Önizleme';

  @override
  String get viewLocation => 'Konumu Görüntüle';

  @override
  String get shareAll => 'Hepsini Paylaş';

  @override
  String get goHome => 'Ana Sayfaya Git';

  @override
  String get fullPage => 'Tam Sayfa';

  @override
  String get sideBySide => 'Yan Yana';

  @override
  String get grid2x2 => 'Izgara 2x2';

  @override
  String get grid3x2 => 'Izgara 3x2';

  @override
  String get grid3x3 => 'Izgara 3x3';

  @override
  String get featureReadView => 'PDF\'leri Oku ve Görüntüle';

  @override
  String get featureMerge => 'Birden Fazla PDF\'i Birleştir';

  @override
  String get featureSplit => 'PDF\'leri Böl';

  @override
  String get featureCompress => 'Dosya Boyutunu Sıkıştır';

  @override
  String get featureToImage => 'Görüntülere Dönüştür';

  @override
  String get featureEncrypt => 'Şifrele ve Güvenceye Al';

  @override
  String get featureUnlock => 'Kilidi Aç ve Şifreleri Kaldır';

  @override
  String get featureToWord => 'PDF\'den Word\'e (RTF/TXT)';

  @override
  String get featureRotate => 'Sayfaları Döndür';

  @override
  String get featureWatermark => 'Filigran Ekle';

  @override
  String get featureRemove => 'Sayfaları Kaldır';

  @override
  String get featureReorder => 'Sayfaları Yeniden Sırala';

  @override
  String get featureImageToPdf => 'Görüntüden PDF\'e';

  @override
  String get featureWordToPdf => 'Word\'den PDF\'e';

  @override
  String get english => 'İngilizce';

  @override
  String get turkish => 'Türkçe';

  @override
  String get german => 'Almanca';

  @override
  String get selectFile => 'Dosya Seç';

  @override
  String get noFileSelected => 'Dosya seçilmedi';

  @override
  String get processing => 'İşleniyor...';

  @override
  String get success => 'Başarılı!';

  @override
  String get error => 'Hata';

  @override
  String get cancel => 'İptal';

  @override
  String get close => 'Kapat';

  @override
  String get save => 'Kaydet';

  @override
  String get selectFiles => 'Dosyaları Seç';

  @override
  String get pdfFiles => 'PDF Dosyaları';

  @override
  String get imageFiles => 'Resim Dosyaları';

  @override
  String get wordFiles => 'Word Dosyaları';

  @override
  String get reorderingPages => 'Sayfalar yeniden sıralanıyor...';

  @override
  String processingPage(int page, int total) {
    return 'Sayfa $page / $total işleniyor...';
  }

  @override
  String errorReorderingPages(String error) {
    return 'Sayfaları sıralarken hata oluştu: $error';
  }

  @override
  String get pagesReorderedSuccessfully =>
      'Sayfalar Başarıyla Yeniden Sıralandı';

  @override
  String get resetOrder => 'Sıralamayı Sıfırla';

  @override
  String get reverseOrder => 'Sıralamayı Tersine Çevir';

  @override
  String get selectedFile => 'Seçilen Dosya:';

  @override
  String totalPages(int count) {
    return 'Toplam Sayfa: $count';
  }

  @override
  String get reorderInstructions =>
      'Sayfaları sürükleyerek sıralayın veya ok tuşlarını kullanın';

  @override
  String pageNumber(int number) {
    return 'Sayfa $number';
  }

  @override
  String originalPosition(int number) {
    return 'Orijinal konum: $number';
  }

  @override
  String get moveToTop => 'En Üste Taşı';

  @override
  String get moveUp => 'Yukarı Taşı';

  @override
  String get moveDown => 'Aşağı Taşı';

  @override
  String get moveToBottom => 'En Alta Taşı';

  @override
  String get reorderPagesButton => 'SAYFALARI YENİDEN SIRALA';

  @override
  String get saveReorderedPdf => 'Yeniden Sıralanan PDF\'i Kaydet';

  @override
  String get selectDifferentFile => 'Farklı Dosya Seç';

  @override
  String get rotatingPdf => 'PDF döndürülüyor...';

  @override
  String rotatingPage(int current, int total) {
    return 'Sayfa $current / $total döndürülüyor...';
  }

  @override
  String errorRotatingPdf(String error) {
    return 'PDF döndürülürken hata oluştu: $error';
  }

  @override
  String get pdfRotatedSuccessfully => 'PDF başarıyla döndürüldü!';

  @override
  String get rotateInstructions => 'PDF belgenizdeki sayfaları döndürün.';

  @override
  String pagesCount(int count) {
    return '$count Sayfa';
  }

  @override
  String get rotationAngle => 'Döndürme Açısı';

  @override
  String get selectPages => 'Sayfaları Seç';

  @override
  String get rotatePdfButton => 'PDF\'i Döndür';

  @override
  String get backToHome => 'Anasayfaya Dön';

  @override
  String get cannotRemoveAllPages =>
      'Tüm sayfalar silinemez. En az bir sayfa kalmalıdır.';

  @override
  String get removingPages => 'Sayfalar siliniyor...';

  @override
  String errorRemovingPages(String error) {
    return 'Sayfalar silinirken hata oluştu: $error';
  }

  @override
  String get pagesRemovedSuccessfully => 'Sayfalar Başarıyla Silindi';

  @override
  String get removeInstructions =>
      'PDF belgenizden silmek istediğiniz sayfaları seçin';

  @override
  String pagesToRemove(int count) {
    return 'Silinecek Sayfalar: $count';
  }

  @override
  String remainingPages(int count) {
    return 'Kalan Sayfalar: $count';
  }

  @override
  String get selectPagesToRemove => 'Silinecek Sayfaları Seçin:';

  @override
  String get selectAll => 'Hepsini Seç';

  @override
  String get deselectAll => 'Seçimi Kaldır';

  @override
  String get clear => 'Temizle';

  @override
  String get removeSelectedPagesButton => 'SEÇİLİ SAYFALARI SİL';

  @override
  String get toRemove => 'Silinecek';

  @override
  String get selectPagesToRemoveButton => 'Silinecek Sayfaları Seçin';

  @override
  String removePagesCountButton(int count) {
    return '$count Sayfayı Sil';
  }

  @override
  String get addingWatermark => 'Filigran ekleniyor...';

  @override
  String addingWatermarkToPage(int current, int total) {
    return 'Sayfa $current / $total filigran ekleniyor...';
  }

  @override
  String errorAddingWatermark(String error) {
    return 'Filigran eklenirken hata oluştu: $error';
  }

  @override
  String get watermarkAddedSuccessfully => 'Filigran Başarıyla Eklendi';

  @override
  String get livePreview => 'Canlı Önizleme';

  @override
  String get watermarkText => 'Filigran Metni';

  @override
  String get opacity => 'Opaklık';

  @override
  String get fontSize => 'Yazı Boyutu';

  @override
  String get rotation => 'Döndürme';

  @override
  String get position => 'Konum';

  @override
  String get topLeft => 'Sol Üst';

  @override
  String get topRight => 'Sağ Üst';

  @override
  String get bottomLeft => 'Sol Alt';

  @override
  String get bottomRight => 'Sağ Alt';

  @override
  String get center => 'Orta';

  @override
  String get color => 'Renk';

  @override
  String get addWatermarkButton => 'FİLİGRAN EKLE';

  @override
  String get previewInstructions =>
      'Ayarları değiştirdikçe önizleme güncellenir';

  @override
  String get watermarkSettings => 'Filigran Ayarları:';

  @override
  String get enterWatermarkText => 'Filigran metnini girin';

  @override
  String get grey => 'Gri';

  @override
  String get red => 'Kırmızı';

  @override
  String get blue => 'Mavi';

  @override
  String get green => 'Yeşil';

  @override
  String get black => 'Siyah';

  @override
  String get encryptPdfDescription =>
      'PDF dosyanıza yetkisiz erişimi engellemek için bir şifre ekleyin.';

  @override
  String get setPasswordDescription => 'Belgeniz için bir şifre belirleyin.';

  @override
  String get password => 'Şifre';

  @override
  String get confirmPassword => 'Şifreyi Onayla';

  @override
  String get enterStrongPassword => 'Güçlü bir şifre girin';

  @override
  String get reEnterPassword => 'Şifrenizi tekrar girin';

  @override
  String get encryptionNote =>
      'Not: Standart, yaygın olarak uyumlu şifreleme kullanır. Dosya, standart PDF okuyucularda bir şifre gerektirecektir.';

  @override
  String get encryptingPdf => 'PDF şifreleniyor...';

  @override
  String get pdfEncryptedSuccessfully => 'PDF başarıyla şifrelendi!';

  @override
  String get pleaseSelectPdfFirst => 'Lütfen önce bir PDF dosyası seçin.';

  @override
  String get passwordCannotBeEmpty => 'Şifre boş olamaz.';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor.';

  @override
  String failedToEncryptPdf(String error) {
    return 'PDF şifreleme başarısız oldu: $error';
  }

  @override
  String get unlockPdf => 'PDF Kilidini Aç';

  @override
  String get unlockPdfDescription =>
      'PDF dosyanızdan şifre korumasını kaldırın.';

  @override
  String get unlockingPdf => 'PDF kilidi açılıyor...';

  @override
  String get invalidPassword => 'Geçersiz şifre. Lütfen tekrar deneyin.';

  @override
  String get pdfNoPassword => 'Bu PDF dosyasında şifre yok.';

  @override
  String get pdfUnlockedSuccessfully =>
      'PDF kilidi başarıyla açıldı! Şifre kaldırıldı.';

  @override
  String failedToUnlockPdf(String error) {
    return 'PDF kilidi açılamadı: $error';
  }

  @override
  String get enterPdfPassword => 'PDF Şifresini Girin';

  @override
  String get compressPdfDescription =>
      'İçeriğini sıkıştırarak PDF\'nizin dosya boyutunu küçültün.';

  @override
  String get compressInstructions =>
      'Sıkıştırma seviyesini ayarlayın, ardından Sıkıştır\'a tıklayın.';

  @override
  String get compressingPdf => 'PDF sıkıştırılıyor...';

  @override
  String get applyingCompression => 'Sıkıştırma uygulanıyor...';

  @override
  String get savingCompressedPdf => 'Sıkıştırılmış PDF kaydediliyor...';

  @override
  String get pdfCompressedSuccessfully => 'PDF başarıyla sıkıştırıldı!';

  @override
  String unableToCompressFurther(String original, String result) {
    return 'Daha fazla sıkıştırılamıyor. Orijinal: $original, Sonuç: $result. Bu PDF muhtemelen zaten optimize edilmiş veya sıkıştırılmış içerik barındırıyor.';
  }

  @override
  String failedToCompressPdf(String error) {
    return 'PDF sıkıştırılamadı: $error. Bu yöntem en çok görsel ağırlıklı PDF\'lerde işe yarar.';
  }

  @override
  String reducedFromTo(String original, String result) {
    return '$original boyutundan $result boyutuna düşürüldü';
  }

  @override
  String get compressionLevel => 'Sıkıştırma Seviyesi';

  @override
  String get bestCompression => 'En İyi (En küçük dosya boyutu)';

  @override
  String get normalCompression => 'Normal (Dengeli)';

  @override
  String get noCompression => 'Yok (Sıkıştırma yok)';

  @override
  String get loadingPdf => 'PDF yükleniyor...';

  @override
  String errorLoadingPdf(String error) {
    return 'PDF yükleme hatası: $error';
  }

  @override
  String get pleaseSelectValidPdfFirst =>
      'Lütfen önce geçerli bir PDF dosyası seçin.';

  @override
  String get compressionSettings => 'Sıkıştırma Ayarları';

  @override
  String get maximumCompression => 'Maksimum Sıkıştırma';

  @override
  String get bestFileSizeReduction => 'En iyi dosya boyutu küçültme';

  @override
  String get balanced => 'Dengeli';

  @override
  String get goodCompressionWithQuality => 'Kalite ile iyi sıkıştırma';

  @override
  String get noCompressionTitle => 'Sıkıştırma Yok';

  @override
  String get preserveOriginalQuality => 'Orijinal kaliteyi koru';

  @override
  String get optimizationTips => 'Optimizasyon İpuçları';

  @override
  String get tip1 => 'Çok sayıda görsel içeren PDF\'ler daha iyi sıkışır';

  @override
  String get tip2 => 'Sadece metin içeren PDF\'ler çok fazla küçülmeyebilir';

  @override
  String get tip3 => 'Zaten optimize edilmiş PDF\'ler sıkışmaz';

  @override
  String get preparingConversion => 'Dönüştürme hazırlanıyor...';

  @override
  String convertingPage(int page, int total) {
    return 'Sayfa $page / $total dönüştürülüyor...';
  }

  @override
  String get pdfConvertedToImagesSuccess =>
      'PDF başarıyla görüntülere dönüştürüldü!';

  @override
  String get readyToConvert => 'Dönüştürmeye Hazır';

  @override
  String get pdfToImageDescription =>
      'Her PDF sayfası; Önizleme, Kaydetme ve Paylaşma seçenekleriyle ayrı bir görüntü dosyasına dönüştürülecektir.';

  @override
  String get convertToImages => 'Görüntülere Dönüştür';

  @override
  String get pdfToImageLongDescription =>
      'Bir PDF\'nin her sayfasını yüksek kaliteli PNG veya JPEG görüntüsüne dönüştürün.';

  @override
  String get outputFormat => 'Çıktı Formatı';

  @override
  String get losslessBestQuality => 'Kayıpsız, en iyi kalite';

  @override
  String get smallerFileSize => 'Daha küçük dosya boyutu';

  @override
  String get jpegQuality => 'JPEG Kalitesi';

  @override
  String get low => 'Düşük';

  @override
  String get high => 'Yüksek';

  @override
  String errorConvertingPdfToImages(String error) {
    return 'PDF görüntülere dönüştürülürken hata oluştu: $error';
  }

  @override
  String get noImagesCreated => 'Hiçbir görüntü oluşturulmadı';

  @override
  String get pdfToWord => 'PDF\'den Word/Metne';

  @override
  String get extractingText => 'Metin ayıklanıyor...';

  @override
  String get noTextExtractedError =>
      'Bu PDF\'den metin ayıklanamadı. Dosya sadece görüntülerden oluşuyor olabilir veya standart olmayan bir metin formatına sahip olabilir.';

  @override
  String failedToExtractText(String error) {
    return 'Metin ayıklama başarısız oldu: $error';
  }

  @override
  String get rtfExportSuccess =>
      'Belge başarıyla RTF olarak dışa aktarıldı! Microsoft Word ile açabilirsiniz.';

  @override
  String get textExtractSuccess => 'Metin başarıyla ayıklandı!';

  @override
  String get pdfToWordDescription =>
      'PDF\'nizi Word uyumlu RTF\'ye veya düz metne dönüştürün.';

  @override
  String get chooseOutputFormat => 'Çıktı Formatını Seçin';

  @override
  String get wordRtf => 'Word (RTF)';

  @override
  String get bestForEditing => 'Düzenleme için en iyisi';

  @override
  String get textTxt => 'Metin (TXT)';

  @override
  String get plainTextOnly => 'Sadece düz metin';

  @override
  String get convertNow => 'Şimdi Dönüştür';

  @override
  String outputFormatLabel(String format) {
    return 'Çıktı: $format';
  }

  @override
  String get selectWordDocError =>
      'Lütfen bir Word belgesi (.docx) seçin. Not: .doc henüz desteklenmemektedir.';

  @override
  String get convertingWordToPdf => 'Word PDF\'e dönüştürülüyor...';

  @override
  String get wordDocEmptyError => 'Word belgesi boş veya okunamadı.';

  @override
  String get wordToPdfConvertSuccess =>
      'Word belgesi başarıyla PDF\'e dönüştürüldü!';

  @override
  String get wordToPdfDescription =>
      'Word belgelerinizi (.docx, .doc) yüksek kaliteli PDF\'e dönüştürün.';

  @override
  String failedToConvertWordToPdf(String error) {
    return 'Word PDF\'e dönüştürülemedi: $error\n\nNot: Bu sürümde sadece metin içeriği desteklenmektedir.';
  }

  @override
  String get dropWordFileHere =>
      'Word dosyasını buraya bırakın veya göz atmak için tıklayın';

  @override
  String get pdfTools => 'PDF Araçları';

  @override
  String get unlock => 'Kilidi Aç';

  @override
  String get converting => 'Dönüştürülüyor...';

  @override
  String get orientation => 'Yönlendirme';

  @override
  String get convert => 'Dönüştür';

  @override
  String get merging => 'Birleştiriliyor...';

  @override
  String get splitting => 'Bölünüyor...';

  @override
  String get convertToPdf => 'PDF\'e Dönüştür';

  @override
  String get viewSearchAnnotate => 'Görüntüle, Ara ve Not Ekle';

  @override
  String get combineFiles => 'Dosyaları Birleştir';

  @override
  String get extractPages => 'Sayfa Ayıkla';

  @override
  String get reduceSize => 'Boyut Küçült';

  @override
  String get addPassword => 'Şifre Ekle';

  @override
  String get removePass => 'Şifre Kaldır';

  @override
  String get turnPages => 'Sayfaları Çevir';

  @override
  String get deletePages => 'Sayfa Sil';

  @override
  String get arrangePages => 'Sayfaları Düzenle';

  @override
  String get addTextImage => 'Metin/Resim Ekle';

  @override
  String get pngJpeg => 'PNG/JPEG';

  @override
  String get toRtfTxt => 'RTF/TXT\'ye';

  @override
  String get convertImages => 'Resimleri Dönüştür';

  @override
  String get textToPdf => 'Metinden PDF\'e';

  @override
  String get convertTxt => 'TXT/RTF Dönüştür';

  @override
  String get textToPdfDescription =>
      'Düz metin (.txt) veya Zengin Metin (.rtf) dosyalarını PDF formatına dönüştürün.';

  @override
  String clickToSelectFile(String fileType, String plural) {
    return '$fileType dosya$plural seçmek için tıklayın';
  }

  @override
  String youCanSelectMultiple(String fileType) {
    return 'Birden fazla $fileType dosyası seçebilirsiniz';
  }

  @override
  String supportedFormats(String formats) {
    return 'Desteklenen: $formats';
  }

  @override
  String get notepad => 'Not Defteri';

  @override
  String get notepadDescription =>
      'Gelişmiş metin, resim ve stillerle notlar oluşturun ve PDF olarak kaydedin';

  @override
  String get featureNotepad => 'Zengin PDF Notları Oluşturun';

  @override
  String get saveAsPdf => 'PDF Olarak Kaydet';

  @override
  String get insertImage => 'Resim Ekle';

  @override
  String get pleaseEnterSomeText => 'Lütfen önce bir metin girin';

  @override
  String get creatingPdf => 'PDF oluşturuluyor...';

  @override
  String get pdfCreatedSuccessfully => 'PDF başarıyla oluşturuldu!';

  @override
  String get selectColor => 'Renk Seç';

  @override
  String get selectFontSize => 'Yazı Boyutu Seç';

  @override
  String get selectFont => 'Yazı Tipi Seç';

  @override
  String get bold => 'Kalın';

  @override
  String get italic => 'İtalik';

  @override
  String get underline => 'Altı Çizili';

  @override
  String get textColor => 'Metin Rengi';

  @override
  String get select => 'Seç';

  @override
  String get myFiles => 'Dosyalarım';

  @override
  String get sortByName => 'Ada Göre Sırala';

  @override
  String get sortByDate => 'Tarihe Göre Sırala';

  @override
  String get sortBySize => 'Boyuta Göre Sırala';

  @override
  String get noFilesFound => 'Bu klasörde dosya bulunamadı.';

  @override
  String get errorOpeningFolder => 'Klasör açılamadı.';

  @override
  String get errorOpeningFile => 'Dosya açılamadı.';

  @override
  String get errorDeletingFile => 'Dosya silinemedi.';

  @override
  String get openFile => 'Aç';

  @override
  String get deleteFile => 'Sil';

  @override
  String get confirmDelete => 'Dosyayı Sil?';

  @override
  String confirmDeleteMessage(String name) {
    return '$name dosyasını silmek istediğinizden emin misiniz?';
  }

  @override
  String get fileDeletedSuccess => 'Dosya silindi.';
}
