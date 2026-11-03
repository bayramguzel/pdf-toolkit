# PDF Toolkit Web Deployment Guide

Bu dokuman, PDF Toolkit uygulamasinin web versiyonunu pdftoolkit.41software.com adresinde yayinlamak icin gereken adimlari icerir.

## Gereksinimler

- Flutter SDK (3.2.0 veya uzeri)
- Web hosting (Nginx, Apache, veya Firebase Hosting)
- SSL sertifikasi (Let's Encrypt onerilir)

## Build Adimlari

### 1. Web Build Olusturma

```bash
# Production build
flutter build web --release --web-renderer canvaskit

# Veya HTML renderer ile (daha hizli yukleme)
flutter build web --release --web-renderer html
```

Build dosyalari `build/web` klasorunde olusturulacaktir.

### 2. Nginx Konfigurasyonu

`/etc/nginx/sites-available/pdftoolkit.41software.com` dosyasini olusturun:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name pdftoolkit.41software.com;
    
    # SSL icin Let's Encrypt yonlendirmesi
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name pdftoolkit.41software.com;

    # SSL sertifikalari
    ssl_certificate /etc/letsencrypt/live/pdftoolkit.41software.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/pdftoolkit.41software.com/privkey.pem;
    
    # SSL ayarlari
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    root /var/www/pdftoolkit.41software.com;
    index index.html;

    # Gzip sikistirma
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json;

    # Cache ayarlari
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Flutter routing icin
    location / {
        try_files $uri $uri/ /index.html;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
    }

    # Service worker
    location /flutter_service_worker.js {
        add_header Cache-Control "no-cache";
        expires 0;
    }
}
```

### 3. Deployment

```bash
# Build dosyalarini sunucuya kopyalama
scp -r build/web/* user@server:/var/www/pdftoolkit.41software.com/

# Nginx'i yeniden baslat
sudo systemctl restart nginx
```

### 4. SSL Sertifikasi (Let's Encrypt)

```bash
# Certbot kurulumu (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# SSL sertifikasi alma
sudo certbot --nginx -d pdftoolkit.41software.com

# Otomatik yenileme testi
sudo certbot renew --dry-run
```

## Firebase Hosting Alternatifi

Firebase Hosting kullanmak isterseniz:

### 1. Firebase CLI Kurulumu

```bash
npm install -g firebase-tools
firebase login
```

### 2. Firebase Projesi Baslat

```bash
firebase init hosting
```

Sorulara su sekilde cevap verin:
- Public directory: `build/web`
- Configure as single-page app: `Yes`
- Set up automatic builds: `No`

### 3. Deploy

```bash
flutter build web --release
firebase deploy --only hosting
```

### 4. Custom Domain Ekleme

Firebase Console'da:
1. Hosting > Add custom domain
2. `pdftoolkit.41software.com` ekleyin
3. DNS kayitlarini guncelleyin

## DNS Ayarlari

Domain saglacicinizda (GoDaddy, Namecheap, vb.) su kayitlari ekleyin:

### Kendi Sunucunuz icin:
```
Type: A
Name: pdftoolkit
Value: [SUNUCU_IP_ADRESI]
TTL: 3600
```

### Firebase Hosting icin:
Firebase Console'un verdigi A kayitlarini ekleyin.

## Performans Optimizasyonu

### 1. CanvasKit vs HTML Renderer

- **CanvasKit**: Daha iyi gorsel kalite, daha buyuk dosya boyutu
- **HTML**: Daha hizli yukleme, daha kucuk dosya boyutu

Web icin HTML renderer onerilir:
```bash
flutter build web --web-renderer html
```

### 2. Code Splitting

`web/index.html` dosyasinda deferred loading kullanin.

### 3. PWA Ozellikleri

Uygulama zaten PWA destekli. Kullanicilar "Ana ekrana ekle" ile yukleyebilir.

## Test

Build sonrasi yerel test:

```bash
cd build/web
python3 -m http.server 8000
```

Tarayicida `http://localhost:8000` adresini acin.

## Sorun Giderme

### CORS Hatalari
Eger API'lerle iletisim kuruyorsaniz, sunucu tarafinda CORS ayarlarini yapin.

### Routing Sorunlari
Nginx konfigurasyonunda `try_files` satirinin dogru oldugunu kontrol edin.

### Buyuk Dosya Yukleme
Nginx'te `client_max_body_size` ayarini artirin:
```nginx
client_max_body_size 100M;
```

## Guncelleme

Yeni versiyon yayinlamak icin:

```bash
# Versiyon numarasini guncelle
# pubspec.yaml: version: 1.5.4+24

# Build
flutter build web --release --web-renderer html

# Deploy
scp -r build/web/* user@server:/var/www/pdftoolkit.41software.com/
```

## Monitoring

- Google Analytics eklemek icin `web/index.html` dosyasina tracking kodu ekleyin
- Sentry veya Firebase Crashlytics ile hata takibi yapin

## Guvenlik

- HTTPS zorunlu kullanin
- Security headers ekleyin (yukaridaki Nginx orneginde mevcut)
- Regular olarak bagimliliklari guncelleyin: `flutter pub upgrade`

## Destek

Sorulariniz icin: support@41software.com
