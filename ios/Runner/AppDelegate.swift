import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// Keeps the image conversion channel alive for the app's lifetime.
  private var imageConverterChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    registerImageConverterChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Converts any image iOS can decode (HEIC/HEIF, JPEG, PNG, …) into a
  /// baseline JPEG in the temporary directory. The Dart `image` package cannot
  /// decode HEIC, which is the default photo format on iPhone, so image-to-PDF
  /// and the notepad use this before embedding a picture.
  private func registerImageConverterChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "com.software41.pdftoolkit/image_converter",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "convertToJpeg" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard
        let arguments = call.arguments as? [String: Any],
        let sourcePath = arguments["path"] as? String
      else {
        result(FlutterError(code: "bad_arguments", message: "Missing path", details: nil))
        return
      }

      DispatchQueue.global(qos: .userInitiated).async {
        guard let image = UIImage(contentsOfFile: sourcePath) else {
          DispatchQueue.main.async {
            result(FlutterError(code: "decode_failed", message: "Unsupported image", details: nil))
          }
          return
        }

        // Bake EXIF orientation into the pixels so the JPEG opens upright
        // everywhere (the Dart image decoder ignores orientation metadata).
        let normalized: UIImage
        if image.imageOrientation == .up {
          normalized = image
        } else {
          UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
          image.draw(in: CGRect(origin: .zero, size: image.size))
          normalized = UIGraphicsGetImageFromCurrentImageContext() ?? image
          UIGraphicsEndImageContext()
        }

        guard let data = normalized.jpegData(compressionQuality: 0.92) else {
          DispatchQueue.main.async {
            result(FlutterError(code: "encode_failed", message: "Could not encode JPEG", details: nil))
          }
          return
        }

        let destination = FileManager.default.temporaryDirectory
          .appendingPathComponent("pdf_toolkit_\(UUID().uuidString).jpg")
        do {
          try data.write(to: destination, options: .atomic)
          DispatchQueue.main.async {
            result(destination.path)
          }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(code: "write_failed", message: error.localizedDescription, details: nil))
          }
        }
      }
    }
    imageConverterChannel = channel
  }

  /// Handles "Open in PDF Toolkit" / "Copy to PDF Toolkit" from Files, Mail,
  /// Safari and other apps. The document is copied into the app's Documents
  /// folder (visible in Files > On My iPhone > PDF Toolkit) and queued so the
  /// Flutter side can open it in the reader right after launch/resume.
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if url.isFileURL && IncomingFileStore.importDocument(at: url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }
}

/// Copies documents opened from other apps into the app sandbox and writes a
/// small JSON queue in Application Support that the Dart side drains.
enum IncomingFileStore {
  private static let queueFileName = "incoming_documents.json"

  private static var queueURL: URL? {
    let manager = FileManager.default
    guard
      let support = manager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    else { return nil }
    if !manager.fileExists(atPath: support.path) {
      try? manager.createDirectory(at: support, withIntermediateDirectories: true)
    }
    return support.appendingPathComponent(queueFileName)
  }

  @discardableResult
  static func importDocument(at url: URL) -> Bool {
    let manager = FileManager.default
    guard
      let documents = manager.urls(for: .documentDirectory, in: .userDomainMask).first
    else { return false }

    // Documents opened "in place" live outside the sandbox and need a
    // security-scoped access window while we copy them.
    let scoped = url.startAccessingSecurityScopedResource()
    defer {
      if scoped { url.stopAccessingSecurityScopedResource() }
    }

    let destination = uniqueDestination(for: url, in: documents)
    do {
      try manager.copyItem(at: url, to: destination)
    } catch {
      NSLog("PDF Toolkit: could not import \(url.lastPathComponent): \(error)")
      return false
    }

    enqueue(path: destination.path)
    return true
  }

  private static func uniqueDestination(for url: URL, in directory: URL) -> URL {
    let manager = FileManager.default
    let name = url.deletingPathExtension().lastPathComponent
    let ext = url.pathExtension
    var candidate = directory.appendingPathComponent(url.lastPathComponent)
    var index = 1
    while manager.fileExists(atPath: candidate.path) {
      let suffix = ext.isEmpty ? "_\(index)" : "_\(index).\(ext)"
      candidate = directory.appendingPathComponent(name + suffix)
      index += 1
    }
    return candidate
  }

  private static func enqueue(path: String) {
    guard let queueURL = queueURL else { return }
    var entries: [[String: Any]] = []
    if let data = try? Data(contentsOf: queueURL),
      let decoded = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
    {
      entries = decoded
    }
    entries.append([
      "path": path,
      "openedAt": Date().timeIntervalSince1970,
    ])
    guard let data = try? JSONSerialization.data(withJSONObject: entries) else { return }
    try? data.write(to: queueURL, options: .atomic)
  }
}
