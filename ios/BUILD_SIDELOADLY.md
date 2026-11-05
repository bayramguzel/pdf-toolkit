# PDF Toolkit — İmzasız IPA Üretimi ve Sideloadly ile Ücretsiz Yükleme

Bu doküman, Windows üzerinde iOS cihaza uygulamayı **ücretsiz bir Apple ID** ile
yüklemek için izlenecek yolu anlatır.

> **Neden doğrudan IPA üretemiyoruz?**
> iOS uygulamaları yalnızca macOS + Xcode ile derlenebilir. Windows'ta
> `flutter build ios` / `flutter build ipa` çalışmaz. Bu nedenle IPA, ücretsiz
> bir macOS makinesi olan **GitHub Actions** üzerinde üretilir; imzalama işini
> ise Windows'ta çalışan **Sideloadly** kendi Apple ID'nizle yapar.

## Windows'ta iOS Derleme Seçenekleri

| Yöntem | Ücret | Açıklama |
| --- | --- | --- |
| **GitHub Actions** (bu depo) | Ücretsiz | macOS runner'da imzasız IPA üretir; Sideloadly ile yüklenir. Önerilen yol. |
| **Codemagic** | Ücretsiz kota | GitHub reposunu bağlayıp iOS build alabilirsiniz; ücretsiz planda aylık dakika sınırı vardır. |
| **MacinCloud / kiralık Mac** | Ücretli | Uzak macOS masaüstünde Xcode ile doğrudan derleme. |
| **Fiziksel Mac** | — | Xcode + `flutter build ipa` ile en sağlıklı yol. |

---

## 1. İş Akışını Çalıştırma

1. GitHub'da depoyu açın → **Actions** sekmesi.
2. Sol listede **Build unsigned iOS IPA** iş akışını seçin.
3. **Run workflow** → **Run workflow** düğmesine basın.
4. Derleme genellikle 10–20 dakika sürer.
5. Tamamlandığında IPA'yı iki yerden indirebilirsiniz:
   - **Actions → çalıştırma → Artifacts → `PdfToolkit-unsigned-ipa`**
   - **Releases** sekmesindeki `ios-unsigned-<numara>` sürümü
     (`PdfToolkit-unsigned.ipa` doğrudan indirilebilir).

İş akışı dosyası: `.github/workflows/ios-unsigned-ipa.yml`

Komut satırı tercih edenler için (GitHub CLI kuruluysa):

```powershell
gh workflow run ios-unsigned-ipa.yml
gh run watch
gh run download --name PdfToolkit-unsigned-ipa
```

---

## 2. Sideloadly Kurulumu (Windows)

1. <https://sideloadly.io> adresinden Windows sürümünü indirip kurun.
2. iPhone'u USB ile bilgisayara bağlayın.
3. Telefonda **Bu Bilgisayara Güven** uyarısını onaylayın.
4. iPhone'da **Ayarlar → Gizlilik ve Güvenlik → Geliştirici Modu**'nu açın
   (iOS 16 ve üzeri). Açtıktan sonra cihaz yeniden başlar; yeniden başlatınca
   kilidi açıp onaylayın.

---

## 3. IPA'yı Yükleme

1. Sideloadly'yi açın.
2. **IPA** alanına indirdiğiniz `PdfToolkit-unsigned.ipa` dosyasını sürükleyin.
3. **Apple ID** alanına App Store hesabınızın e-posta adresini girin.
4. **Start** düğmesine basın.
5. Apple ID şifrenizi ve iki adımlı doğrulama kodunu girin.
6. İşlem bitince uygulama ana ekranda görünür.

### İlk açılışta güvenme

Ücretsiz hesapla imzalanan uygulamalar için profil güvenilir değildir:

1. **Ayarlar → Genel → VPN ve Cihaz Yönetimi**
2. **Geliştirici Uygulaması** altında Apple ID'nizle eşleşen profile dokunun.
3. **"<Apple ID>" uygulamasına güven** → **Güven**.

Sonrasında PDF Toolkit'i açabilirsiniz.

---

## 4. Ücretsiz Apple ID'nin Sınırları

| Konu | Sınır |
| --- | --- |
| İmza geçerliliği | **7 gün** (sonra uygulama açılmaz) |
| Aynı anda imzalı uygulama | 3 |
| 7 günde kaydedilebilen App ID | 10 |
| Cihaz başına geliştirici hesabı | 1 |

- 7 gün dolduğunda aynı IPA'yı Sideloadly ile **yeniden imzalayın**; verileriniz
  (ayarlar, kayıtlılar) silinmez.
- Uygulamanın bundle kimliği `com.software41.pdftoolkit`. Ücretsiz hesabınızda
  bu kimlik başka bir geliştirici tarafından kullanılıyorsa Sideloadly'de
  **Bundle ID** alanını kendinize özgü bir değere (ör.
  `com.<ad><soyad>.pdftoolkit`) değiştirin. Bu durumda uygulama yeni bir
  uygulama olarak kurulur; eski veriler taşınmaz.
- Developer Mode'u kapatırsanız uygulama açılmaz.
- Ücretsiz hesapla yüklenen uygulamalar App Store'a gönderilemez; yalnızca
  kişisel test içindir.

---

## 5. Sorun Giderme

| Belirti | Çözüm |
| --- | --- |
| `Unable to install` | Cihazın kilidini açın, "Bu Bilgisayara Güven"i tekrar onaylayın, farklı bir USB portu/kablo deneyin. |
| `The maximum number of apps for free development profiles has been reached` | 7 gün içinde 3 uygulama sınırı doldu; eski uygulamalardan birini silin veya sürenin dolmasını bekleyin. |
| Uygulama açılıp hemen kapanıyor | Profil süresi dolmuş olabilir; yeniden imzalayın. |
| `Bundle identifier is not available` | Sideloadly'de Bundle ID'yi değiştirin (bkz. bölüm 4). |
| 2FA kodu kabul edilmiyor | Sideloadly'nin güncel sürümünü kullanın; Apple ID'de uygulamaya özel şifre gerekiyorsa oluşturup girin. |

---

## 6. iOS'ta Dosyalara Erişim ve Kaydetme

iOS uygulamaları sandbox içinde çalışır; Android'deki gibi ortak bir
"Downloads" klasörüne doğrudan yazamaz. PDF Toolkit bunu şöyle çözer:

| İşlem | iOS'ta nasıl çalışır |
| --- | --- |
| Cihazdaki bir PDF'i açma | **Dosyalar** seçicisi açılır (iCloud Drive, iPhone'um, Google Drive vb.). |
| Dönüştürülen dosyaları görme | **Dosyalar → iPhone'um → PDF Toolkit** klasörü. (Info.plist'te `UIFileSharingEnabled` açıktır.) |
| Dosyayı cihaza kaydetme | Sonuç ekranında **Dosyalar'a Kaydet** → paylaşım sayfasından hedef klasörü seçin. |
| Görsel ekleme (PDF'e) | **Fotoğraf Kitaplığı** veya **Dosyalar** seçilebilir. |
| Oluşturulan görselleri görme | Yine **Dosyalar → iPhone'um → PDF Toolkit**. |

> Telefonda dosyaları görmek için Dosyalar uygulamasında **Gözat → iPhone'um**
> altına bakın. Uygulama adı "PDF Toolkit" olarak listelenir.

---

## 7. Alternatif: Mac ile Derleme

Bir Mac'e erişiminiz varsa:

```bash
flutter build ios --release --no-codesign
mkdir -p Payload
cp -R build/ios/iphoneos/Runner.app Payload/Runner.app
zip -qry PdfToolkit-unsigned.ipa Payload
```

---

## 8. Kontrol Listesi

- [ ] Proje GitHub'a yüklendi (`github.com/bayramguzel/pdf-toolkit`).
- [ ] Actions üzerinde **Build unsigned iOS IPA** çalıştırıldı.
- [ ] `PdfToolkit-unsigned.ipa` indirildi.
- [ ] Sideloadly ile Apple ID kullanılarak imzalandı.
- [ ] Cihazda geliştirici profili güvenildi.
- [ ] Uygulama açıldı ve temel akışlar test edildi.
- [ ] 7 gün sonra yeniden imzalama hatırlatıcısı kuruldu.
