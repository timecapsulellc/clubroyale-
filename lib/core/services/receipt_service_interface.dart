import 'dart:typed_data';

abstract class ReceiptService {
  Future<void> shareReceiptImage(
    Uint8List imageBytes,
    String fileName,
    String title,
  );
}
