# PDF Toolkit Web - Hızlı Başlangıç

## 🚀 5 Dakikada Web'e Deploy

### Adım 1: Build Oluştur

```bash
# Windows
build_web.bat

# Linux/Mac
chmod +x build_web.sh
./build_web.sh
```

### Adım 2: Yerel Test

```bash
# Windows
serve_web.bat

# Linux/Mac
chmod +x serve_web.sh
./serve_web.sh
```

Tarayıcıda http://localhost:8000 açın.

### Adım 3: Deploy

#### Seçenek A: Firebase Hosting (En Kolay)

```bash
# Firebase CLI yükle
npm install -g firebase-tools

# Login
firebase login

# Proje başlat
firebase init hosting

# Deploy
firebase deploy --only hosting
```

#### Seçenek B: Kendi Sunucunuz

```bash
# Build dosyalarını kopyala
scp -r build/web/* user@server:/var/www/pdftoolkit.41software.com/
```

### Adım 4: DNS Ayarları

Domain sağlayıcınızda A kaydı ekleyin:
```
Type: A
Name: pdftoolkit
Value: [SUNUCU_IP]
```

### Adım 5: SSL (Let's Encrypt)

```bash
sudo certbot --nginx -d pdftoolkit.41software.com
```

## ✅ Tamamlandı!

Siteniz https://pdftoolkit.41software.com adresinde yayında!

## 🔧 Sorun Giderme

### Build Hatası
```bash
flutter clean
flutter pub get
flutter build web --release
```

### Port Zaten Kullanımda
```bash
# Farklı port kullan
python3 -m http.server 8080
```

### CORS Hatası
Nginx config'e ekleyin:
```nginx
add_header Access-Control-Allow-Origin *;
```

## 📚 Daha Fazla Bilgi

- Detaylı deployment: [WEB_DEPLOYMENT.md](WEB_DEPLOYMENT.md)
- Web özellikleri: [README_WEB.md](README_WEB.md)
