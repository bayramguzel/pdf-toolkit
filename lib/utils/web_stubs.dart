// Web platform stub for receive_sharing_intent
// This file is used when compiling for web to avoid platform-specific dependencies

class ReceiveSharingIntent {
  static ReceiveSharingIntent get instance => ReceiveSharingIntent();

  Stream<List<SharedMediaFile>> getMediaStream() {
    return Stream.value([]);
  }

  Future<List<SharedMediaFile>> getInitialMedia() async {
    return [];
  }
}

class SharedMediaFile {
  final String path;
  SharedMediaFile(this.path);
}
