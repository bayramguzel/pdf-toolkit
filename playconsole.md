Bit eşlem alt örneklemesiyle uygulamanızın performansını artırın
Uygulamanız, aşağıdaki yerlerde BitmapFactory öğesini alt örnekleme yapmadan kullanıyor:

c0.d.b
Sorun türü: BitmapFactory.Options parametresi eksik
e4.i.c
Sorun türü: BitmapFactory.Options parametresi eksik
Bit eşlemleri tam çözünürlükte yüklemek, özellikle gelecekteki güncellemelerde resim çözünürlüğü artarsa aşırı bellek kullanımına yol açabilir.

Bellek yönetimini ve alt örnekleme işlemlerini sizin adınıza otomatik olarak yapması için bir resim yükleme kitaplığı kullanabilirsiniz. Doğrudan BitmapFactory öğesini kullanmanız gerekiyorsa resmi gerekli görüntü boyutuna küçültmek için BitmapFactory.Options.inSampleSize kullandığınızdan emin olun.

****
DK 35'i hedefleyen uygulamalar, Android 15'ten itibaren varsayılan olarak uçtan uca ekranda görüntülenecek. SDK 35'i hedefleyen uygulamalar, Android 15 ve sonraki sürümlerde düzgün görüntülenebilesi için ekleri kullanmalıdır. Bu sorunu inceleyip uçtan uca testi ve gerekli güncellemeleri yapmak için zaman ayırın. Alternatif olarak da geriye dönük uyumluluk açısından Kotlin için enableEdgeToEdge() veya Java için EdgeToEdge.enable() öğesini çağırın.

***
R8 yapılandırmanız bellek kullanımının artmasına ve performansın düşmesine yol açıyor olabilir. Uygulamanızın optimizasyonunu daha iyi hale getirmek için aşağıdaki sorunları giderin:

Optimize edilmiş, kullanılmayan kaynakları kaldırma etkin değil
Android Gradle eklentinizi 9.0 veya sonraki bir sürüme yükseltin. play console deki hatalari giderelim
