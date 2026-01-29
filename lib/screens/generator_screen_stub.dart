// Stub for non-web platforms
Future<void> downloadQrWeb(List<int> bytes, String filename) async {
  throw UnsupportedError('Web download not supported on this platform');
}
