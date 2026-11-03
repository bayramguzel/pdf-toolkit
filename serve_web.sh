#!/bin/bash

# PDF Toolkit Web Local Server
# Build sonrası yerel test için

echo "🌐 PDF Toolkit Web Server Başlatılıyor..."

# Build klasörü var mı kontrol et
if [ ! -d "build/web" ]; then
    echo "❌ build/web klasörü bulunamadı!"
    echo "Önce 'flutter build web' komutunu çalıştırın."
    exit 1
fi

# Python versiyonunu kontrol et
if command -v python3 &> /dev/null; then
    echo "✅ Python3 bulundu"
    cd build/web
    echo "🚀 Server başlatıldı: http://localhost:8000"
    python3 -m http.server 8000
elif command -v python &> /dev/null; then
    echo "✅ Python bulundu"
    cd build/web
    echo "🚀 Server başlatıldı: http://localhost:8000"
    python -m http.server 8000
else
    echo "❌ Python bulunamadı!"
    echo "Python yükleyin veya başka bir web server kullanın."
    exit 1
fi
