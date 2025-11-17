import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../models/photo_item.dart';
import 'mock_auth_service.dart';

class LocalStorageService {
  final MockAuthService authService;

  LocalStorageService({required this.authService});

  String get _userId => authService.currentUser ?? 'anonymous';

  // UPLOAD ẢNH - lưu local
  Future<PhotoItem> uploadImageBytes(Uint8List bytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final userDir = Directory('${directory.path}/users/$_userId');
      if (!await userDir.exists()) await userDir.create(recursive: true);

      // Lưu ảnh gốc
      final photoFile = File('${userDir.path}/$fileName');
      await photoFile.writeAsBytes(bytes);

      // Tạo và lưu thumbnail
      final thumbnailBytes = await _generateThumbnailBytes(bytes);
      final thumbFile = File('${userDir.path}/thumb_$fileName');
      await thumbFile.writeAsBytes(thumbnailBytes);

      final decoded = img.decodeImage(bytes);

      return PhotoItem(
        name: fileName,
        url: photoFile.path, // Dùng local path
        thumbnailUrl: thumbFile.path,
        uploadTime: DateTime.now(),
        size: bytes.length,
        format: fileName.split('.').last,
        width: decoded?.width,
        height: decoded?.height,
      );
    } catch (e) {
      throw Exception("Upload failed: $e");
    }
  }

  // TẠO THUMBNAIL
  Future<Uint8List> _generateThumbnailBytes(Uint8List originalBytes) async {
    try {
      final image = img.decodeImage(originalBytes);
      if (image == null) return originalBytes;

      final thumbnail = img.copyResize(image, width: 200);
      final jpg = img.encodeJpg(thumbnail, quality: 80);
      return Uint8List.fromList(jpg);
    } catch (e) {
      return originalBytes;
    }
  }

  // LẤY DANH SÁCH ẢNH
  Future<List<PhotoItem>> getUserPhotos() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final userDir = Directory('${directory.path}/users/$_userId');

      if (!await userDir.exists()) return [];

      final files = await userDir.list().toList();
      final photoFiles = files
          .where((file) => file is File && !file.path.contains('thumb_'))
          .toList();

      List<PhotoItem> photos = [];

      for (var file in photoFiles) {
        final fileStat = await (file as File).stat();
        final fileName = file.path.split('/').last;

        photos.add(PhotoItem(
          name: fileName,
          url: file.path,
          thumbnailUrl: '${userDir.path}/thumb_$fileName',
          uploadTime: fileStat.modified,
          size: fileStat.size,
        ));
      }

      return photos;
    } catch (e) {
      return [];
    }
  }

  // XÓA ẢNH
  Future<void> deletePhoto(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final photoFile = File('${directory.path}/users/$_userId/$fileName');
      final thumbFile =
          File('${directory.path}/users/$_userId/thumb_$fileName');

      if (await photoFile.exists()) await photoFile.delete();
      if (await thumbFile.exists()) await thumbFile.delete();
    } catch (e) {
      throw Exception("Delete failed: $e");
    }
  }
}
