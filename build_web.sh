#!/bin/bash

# PDF Toolkit Web Build Script
# Bu script web versiyonunu build eder

echo "🚀 PDF Toolkit Web Build Başlatılıyor..."

# Temizlik
echo "🧹 Önceki build dosyaları temizleniyor..."
flutter clean

# Bağımlılıkları güncelle
echo "📦 Bağımlılıklar güncelleniyor..."
flutter pub get

# Web build (HTML renderer - daha hızlı yükleme)
echo "🔨 Web build oluşturuluyor (HTML renderer)..."
flutter build web --release --web-renderer html

# Build başarılı mı kontrol et
if [ $? -eq 0 ]; then
    echo "✅ Build başarıyla tamamlandı!"
    echo "📁 Build dosyaları: build/web/"
    echo ""
    echo "📋 Sonraki adımlar:"
    echo "1. build/web/ klasörünü sunucunuza yükleyin"
    echo "2. Nginx/Apache konfigürasyonunu yapın"
    echo "3. SSL sertifikası ekleyin"
    echo ""
    echo "Detaylı bilgi için WEB_DEPLOYMENT.md dosyasına bakın"
else
    echo "❌ Build başarısız oldu!"
    exit 1
fi
