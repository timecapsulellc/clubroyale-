import 'dart:typed_data';
import 'receipt_service_interface.dart';
// import 'dart:html' as html; // Avoid direct dart:html if strictly using wasm, but for now okay.
// Or just ignore for now as share_plus might handle web sharing of XFiles created from bytes?
// Share.shareXFiles supports web with XFile.fromData since v7.

import 'package:share_plus/share_plus.dart';

class ReceiptServiceImpl implements ReceiptService {
  @override
  Future<void> shareReceiptImage(
    Uint8List imageBytes,
    String fileName,
    String title,
  ) async {
    // On web, we can share directly from bytes using XFile.fromData
    await Share.shareXFiles(
      [XFile.fromData(imageBytes, name: fileName, mimeType: 'image/png')],
      text: title,
      subject: 'ClubRoyale Receipt',
    );
  }
}
