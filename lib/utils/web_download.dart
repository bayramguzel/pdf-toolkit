// Web-only download helper using package:web
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

void downloadFileWeb(Uint8List bytes, String fileName) {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/octet-stream'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName
    ..click();
  anchor.remove();
  // Defer revoking the object URL so the download is not cancelled
  // before the browser has started it.
  web.window.setTimeout(
    (() {
      web.URL.revokeObjectURL(url);
    }).toJS,
    null,
    1000,
  );
}
