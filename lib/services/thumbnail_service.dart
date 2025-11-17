import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ThumbnailService {
  // Tạo thumbnail từ file ảnh (dùng cho preview nhanh)
  static Future<File> createThumbnail(File imageFile, {int width = 200}) async {
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final thumbnailFile = File(
        '${tempDir.path}/thumbnail_${DateTime.now().millisecondsSinceEpoch}.png');
    await thumbnailFile.writeAsBytes(pngBytes);

    return thumbnailFile;
  }
}
