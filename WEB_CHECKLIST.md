# PDF Toolkit Web Deployment Checklist

## ✅ Geliştirme Aşaması

- [x] Web desteği için pubspec.yaml güncellendi
- [x] Platform-specific kod ayrımı yapıldı (kIsWeb)
- [x] AdMob web için devre dışı bırakıldı
- [x] Web banner widget'ı oluşturuldu
- [x] FileUtils web uyumlu hale getirildi
- [x] Splash screen web için atlandı
- [x] ReceiveSharingIntent web stub'ı oluşturuldu
- [x] web/index.html oluşturuldu
- [x] web/manifest.json oluşturuldu
- [x] Build scriptleri hazırlandı

## 📋 Build Öncesi

- [ ] Flutter SDK güncel mi? (`flutter --version`)
- [ ] Bağımlılıklar yüklü mü? (`flutter pub get`)
- [ ] Yerel test yapıldı mı? (`flutter run -d chrome`)
- [ ] Tüm özellikler çalışıyor mu?
- [ ] Responsive tasarım kontrol edildi mi?
- [ ] Farklı tarayıcılarda test edildi mi?

## 🔨 Build Aşaması

- [ ] Production build oluşturuldu (`flutter build web --release`)
- [ ] Build başarılı oldu mu?
- [ ] Build boyutu kabul edilebilir mi? (<10MB ideal)
- [ ] İkonlar doğru mu?
- [ ] Manifest.json doğru mu?

## 🌐 Sunucu Hazırlığı

- [ ] Domain satın alındı (pdftoolkit.41software.com)
- [ ] DNS kayıtları eklendi
- [ ] Sunucu hazır (Nginx/Apache)
- [ ] SSL sertifikası alındı (Let's Encrypt)
- [ ] Sunucu konfigürasyonu yapıldı

## 📤 Deployment

- [ ] Build dosyaları sunucuya yüklendi
- [ ] Dosya izinleri doğru (755 klasörler, 644 dosyalar)
- [ ] Nginx/Apache yeniden başlatıldı
- [ ] HTTPS çalışıyor mu?
- [ ] Routing çalışıyor mu? (tüm URL'ler index.html'e yönleniyor)

## 🧪 Production Test

- [ ] Ana sayfa açılıyor mu?
- [ ] Tüm PDF araçları çalışıyor mu?
- [ ] Dosya yükleme çalışıyor mu?
- [ ] Dosya indirme çalışıyor mu?
- [ ] PWA yükleme çalışıyor mu?
- [ ] Mobil tarayıcılarda test edildi mi?
- [ ] Farklı tarayıcılarda test edildi mi?
  - [ ] Chrome
  - [ ] Firefox
  - [ ] Safari
  - [ ] Edge

## 🔒 Güvenlik

- [ ] HTTPS zorunlu mu?
- [ ] Security headers eklendi mi?
- [ ] CORS ayarları doğru mu?
- [ ] Rate limiting var mı?
- [ ] Firewall kuralları ayarlandı mı?

## 📊 Analytics & Monitoring

- [ ] Google Analytics eklendi mi?
- [ ] Error tracking (Sentry) kuruldu mu?
- [ ] Uptime monitoring ayarlandı mı?
- [ ] Performance monitoring aktif mi?

## 🎨 SEO & Marketing

- [ ] Meta tags doğru mu?
- [ ] Open Graph tags eklendi mi?
- [ ] Sitemap oluşturuldu mu?
- [ ] robots.txt eklendi mi?
- [ ] Google Search Console'a eklendi mi?

## 📱 PWA Özellikleri

- [ ] Service worker çalışıyor mu?
- [ ] Offline mode çalışıyor mu?
- [ ] "Ana ekrana ekle" çalışıyor mu?
- [ ] Push notifications (opsiyonel)

## 🔄 Güncelleme Süreci

- [ ] Versiyon numarası güncellendi mi?
- [ ] CHANGELOG.md güncellendi mi?
- [ ] Yeni build oluşturuldu mu?
- [ ] Sunucuya yüklendi mi?
- [ ] Cache temizlendi mi?
- [ ] Kullanıcılara duyuru yapıldı mı?

## 📞 Destek

- [ ] Destek email adresi aktif mi?
- [ ] İletişim formu çalışıyor mu?
- [ ] FAQ sayfası hazır mı?
- [ ] Kullanım kılavuzu hazır mı?

## 🎉 Launch Sonrası

- [ ] Sosyal medyada duyuru yapıldı mı?
- [ ] Blog yazısı yayınlandı mı?
- [ ] Email listesine bildirim gönderildi mi?
- [ ] İlk gün metrikleri izlendi mi?
- [ ] Kullanıcı geri bildirimleri toplandı mı?

## 🐛 Bilinen Sorunlar

- [ ] Bilinen sorunlar dokümante edildi mi?
- [ ] Workaround'lar belirtildi mi?
- [ ] Fix planı var mı?

---

## Notlar

- Build tarihi: ___________
- Deploy tarihi: ___________
- İlk versiyon: ___________
- Sorumlu: ___________

## Acil Durum İletişim

- Sunucu sağlayıcı: ___________
- Domain sağlayıcı: ___________
- SSL sağlayıcı: Let's Encrypt
- Teknik destek: support@41software.com
