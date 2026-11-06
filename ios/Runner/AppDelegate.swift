import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
    if url.isFileURL && IncomingFileStore.shared.importDocument(at: url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }
}

/// Copies documents opened from other apps into the app sandbox and writes a
/// small JSON queue in Application Support that the Dart side drains.
final class IncomingFileStore {
  static let shared = IncomingFileStore()

  private let queueFileName = "incoming_documents.json"

  private var queueURL: URL? {
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
  func importDocument(at url: URL) -> Bool {
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

  private func uniqueDestination(for url: URL, in directory: URL) -> URL {
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

  private func enqueue(path: String) {
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
