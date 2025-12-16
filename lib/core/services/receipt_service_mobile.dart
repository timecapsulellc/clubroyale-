import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'receipt_service_interface.dart';

class ReceiptServiceImpl implements ReceiptService {
  @override
  Future<void> shareReceiptImage(Uint8List imageBytes, String fileName, String title) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(imageBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: title,
      subject: 'ClubRoyale Receipt',
    );
  }
}
