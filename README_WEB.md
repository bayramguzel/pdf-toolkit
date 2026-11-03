# PDF Toolkit - Web Version

PDF Toolkit'in web tabanlı versiyonuna hoş geldiniz! Bu versiyon, Android uygulamasının tüm özelliklerini tarayıcınızda kullanmanıza olanak tanır.

## 🌐 Canlı Demo

**URL:** https://pdftoolkit.41software.com

## ✨ Özellikler

### PDF İşlemleri
- 📄 **PDF Okuyucu** - PDF dosyalarını görüntüleyin
- 🔗 **PDF Birleştir** - Birden fazla PDF'i tek dosyada birleştirin
- ✂️ **PDF Böl** - PDF'leri sayfalara göre bölün
- 🗜️ **PDF Sıkıştır** - Dosya boyutunu küçültün
- 🖼️ **PDF'den Resim** - PDF sayfalarını resme dönüştürün
- 🔒 **PDF Şifrele** - PDF'lerinizi koruyun
- 🔓 **PDF Kilit Aç** - Şifreli PDF'leri açın
- 📝 **PDF'den Word** - PDF'i Word belgesine dönüştürün
- 🔄 **PDF Döndür** - Sayfaları döndürün
- 💧 **Filigran Ekle** - PDF'lere filigran ekleyin
- 🗑️ **Sayfa Sil** - İstenmeyen sayfaları kaldırın
- 🔀 **Sayfa Sırala** - Sayfaları yeniden düzenleyin

### Dönüştürme
- 🖼️ **Resimden PDF** - Resimleri PDF'e dönüştürün
- 📄 **Word'den PDF** - Word belgelerini PDF'e dönüştürün

### Not Defteri
- ✍️ **Gelişmiş Not Defteri** - Zengin metin editörü ile notlar alın ve PDF'e dönüştürün

## 🚀 Hızlı Başlangıç

### Kullanıcılar İçin

1. Tarayıcınızda https://pdftoolkit.41software.com adresini açın
2. İstediğiniz PDF aracını seçin
3. Dosyalarınızı yükleyin
4. İşlemi gerçekleştirin
5. Sonucu indirin

### PWA Olarak Yükleme

PDF Toolkit'i masaüstü uygulaması gibi kullanabilirsiniz:

**Chrome/Edge:**
1. Siteyi ziyaret edin
2. Adres çubuğundaki "Yükle" ikonuna tıklayın
3. "Yükle" butonuna basın

**Safari (iOS):**
1. Siteyi ziyaret edin
2. Paylaş butonuna dokunun
3. "Ana Ekrana Ekle" seçeneğini seçin

## 🛠️ Geliştiriciler İçin

### Gereksinimler

- Flutter SDK 3.2.0 veya üzeri
- Dart SDK
- Web tarayıcı (Chrome önerilir)

### Yerel Geliştirme

```bash
# Bağımlılıkları yükle
flutter pub get

# Geliştirme sunucusunu başlat
flutter run -d chrome

# Veya Edge ile
flutter run -d edge
```

### Production Build

```bash
# Windows için
build_web.bat

# Linux/Mac için
chmod +x build_web.sh
./build_web.sh
```

Build dosyaları `build/web/` klasöründe oluşturulacaktır.

### Deployment

Detaylı deployment talimatları için [WEB_DEPLOYMENT.md](WEB_DEPLOYMENT.md) dosyasına bakın.

## 🔧 Teknik Detaylar

### Kullanılan Teknolojiler

- **Flutter Web** - UI framework
- **Syncfusion PDF** - PDF işleme
- **Flutter Quill** - Zengin metin editörü
- **Material Design 3** - Modern UI

### Tarayıcı Desteği

- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Edge 90+

### Performans

- HTML renderer kullanılarak optimize edilmiştir
- Lazy loading ile hızlı yükleme
- Service Worker ile offline destek
- PWA özellikleri

## 🔒 Gizlilik ve Güvenlik

- Tüm işlemler tarayıcınızda gerçekleşir
- Dosyalarınız sunucuya yüklenmez
- HTTPS ile güvenli bağlantı
- Veri toplama yok

## 📱 Mobil vs Web

| Özellik | Android | Web |
|---------|---------|-----|
| PDF İşlemleri | ✅ | ✅ |
| Offline Çalışma | ✅ | ⚠️ (PWA ile sınırlı) |
| Dosya Sistemi | ✅ | ⚠️ (İndirme klasörü) |
| Reklamlar | AdMob | Banner |
| Paylaşım | ✅ | ✅ (Web Share API) |
| Splash Video | ✅ | ❌ |

## 🐛 Bilinen Sorunlar

- Çok büyük PDF dosyaları (>50MB) tarayıcıda yavaş işlenebilir
- Safari'de bazı font rendering sorunları olabilir
- iOS Safari'de dosya indirme sınırlamaları var

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen:

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📄 Lisans

Bu proje özel lisans altındadır. Detaylar için LICENSE dosyasına bakın.

## 📞 İletişim

- **Website:** https://41software.com
- **Email:** support@41software.com
- **Web App:** https://pdftoolkit.41software.com

## 🙏 Teşekkürler

- Flutter ekibine harika framework için
- Syncfusion'a PDF kütüphaneleri için
- Tüm açık kaynak katkıda bulunanlara

---

Made with ❤️ by 41 Software
