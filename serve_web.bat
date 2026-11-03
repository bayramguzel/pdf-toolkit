@echo off
REM PDF Toolkit Web Local Server for Windows
REM Build sonrası yerel test için

echo 🌐 PDF Toolkit Web Server Başlatılıyor...

REM Build klasörü var mı kontrol et
if not exist "build\web" (
    echo ❌ build\web klasörü bulunamadı!
    echo Önce 'flutter build web' komutunu çalıştırın.
    exit /b 1
)

REM Python versiyonunu kontrol et
where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo ✅ Python bulundu
    cd build\web
    echo 🚀 Server başlatıldı: http://localhost:8000
    python -m http.server 8000
) else (
    echo ❌ Python bulunamadı!
    echo Python yükleyin veya başka bir web server kullanın.
    exit /b 1
)
