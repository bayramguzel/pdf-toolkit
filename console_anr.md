Uçtan uca ekran tüm kullanıcılara gösterilmeyebilir
SDK 35'i hedefleyen uygulamalar, Android 15'ten itibaren varsayılan olarak uçtan uca ekranda görüntülenecek. SDK 35'i hedefleyen uygulamalar, Android 15 ve sonraki sürümlerde düzgün görüntülenebilesi için ekleri kullanmalıdır. Bu sorunu inceleyip uçtan uca testi ve gerekli güncellemeleri yapmak için zaman ayırın. Alternatif olarak da geriye dönük uyumluluk açısından Kotlin için enableEdgeToEdge() veya Java için EdgeToEdge.enable() öğesini çağırın.

***
Android, Android 16 sürümünden itibaren katlanabilir cihazlar ve tabletler gibi büyük ekranlı cihazlarda yeniden boyutlandırma ve yön kısıtlamalarını yoksayacak. Bu durum, kullanıcılarınız için düzen ve kullanılabilirlik sorunlarına yol açabilir.

Uygulamanızda aşağıdaki yeniden boyutlandırma ve yön kısıtlamaları tespit edildi:

com.ironsource.sdk.controller.ControllerActivity.a
com.ironsource.sdk.controller.ControllerActivity.j
com.ironsource.sdk.controller.ControllerActivity.k
Uygulamanız için kullanıcı deneyimini iyileştirmek için bu kısıtlamaları kaldırın ve uygulama düzenlerinizin farklı ekran boyutları ve yönlerinde düzgün çalıştığından emin olmak için Android 16 ve altındaki cihazlarda test edin.

****
Bit eşlem alt örneklemesiyle uygulamanızın performansını artırın
Uygulamanız, aşağıdaki yerlerde BitmapFactory öğesini alt örnekleme yapmadan kullanıyor:

c0.d.b
Sorun türü: BitmapFactory.Options parametresi eksik
q4.h.c
Sorun türü: BitmapFactory.Options parametresi eksik
Bit eşlemleri tam çözünürlükte yüklemek, özellikle gelecekteki güncellemelerde resim çözünürlüğü artarsa aşırı bellek kullanımına yol açabilir.

Bellek yönetimini ve alt örnekleme işlemlerini sizin adınıza otomatik olarak yapması için bir resim yükleme kitaplığı kullanabilirsiniz. Doğrudan BitmapFactory öğesini kullanmanız gerekiyorsa resmi gerekli görüntü boyutuna küçültmek için BitmapFactory.Options.inSampleSize kullandığınızdan emin olun.

****
R8 yapılandırmanız bellek kullanımının artmasına ve performansın düşmesine yol açıyor olabilir. Uygulamanızın optimizasyonunu daha iyi hale getirmek için aşağıdaki sorunları giderin:

Düşük optimizasyon oranı (%37)
Düşük kod karartma oranı (%38)
Düşük küçültme oranı (%38)
Optimize edilmiş, kullanılmayan kaynakları kaldırma etkin değil
Android Gradle eklentinizi 9.0 veya sonraki bir sürüme yükseltin.