@echo off
echo PDF Toolkit Web Build...

call flutter build web --release --no-wasm-dry-run
if %ERRORLEVEL% NEQ 0 (
    echo Build basarisiz!
    exit /b 1
)

echo Gereksiz dosyalar temizleniyor...
del /f /q "build\web\assets\assets\fonts\NotoColorEmoji.ttf" 2>nul
del /f /q "build\web\assets\assets\splash.mp4" 2>nul

echo .htaccess kopyalaniyor...
copy /y "build\web\.htaccess" "build\web\.htaccess" >nul 2>&1

echo ZIP olusturuluyor...
powershell -Command "Compress-Archive -Path 'build\web\*' -DestinationPath 'pdftoolkit_web.zip' -Force"

for %%I in (pdftoolkit_web.zip) do echo ZIP: %%~zI bytes

echo.
echo Tamamlandi! pdftoolkit_web.zip FTP ile yukleyebilirsiniz.
echo Tum dosyalari alt domain root klasorune yukleyin.
