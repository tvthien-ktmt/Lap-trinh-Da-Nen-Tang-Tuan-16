import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_gallery/models/photo_item.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userUid => _auth.currentUser!.uid;
  
  String get _userPhotosPath => 'users/$_userUid/photos';
  String get _userThumbnailsPath => 'users/$_userUid/thumbnails';

  // Upload ảnh
  Future<PhotoItem> uploadImage(File imageFile, String fileName) async {
    try {
      final String fileExtension = fileName.split('.').last;
      final String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      final String storageFileName = '$uniqueId.$fileExtension';
      
      // Upload ảnh gốc
      final Reference photoRef = _storage.ref('$_userPhotosPath/$storageFileName');
      final UploadTask uploadTask = photoRef.putFile(imageFile);
      
      // Theo dõi progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      await uploadTask;
      
      // Lấy metadata
      final FullMetadata metadata = await photoRef.getMetadata();
      final String downloadUrl = await photoRef.getDownloadURL();
      
      // Tạo thumbnail path
      final String thumbnailFileName = '$uniqueId-thumb.$fileExtension';
      final String thumbnailPath = '$_userThumbnailsPath/$thumbnailFileName';

      return PhotoItem(
        id: uniqueId,
        name: fileName,
        fullPath: '$_userPhotosPath/$storageFileName',
        thumbnailPath: thumbnailPath,
        uploadTime: DateTime.now(),
        size: metadata.size ?? await imageFile.length(),
        width: metadata.customMetadata?['width'] != null 
            ? int.parse(metadata.customMetadata!['width']!) 
            : null,
        height: metadata.customMetadata?['height'] != null 
            ? int.parse(metadata.customMetadata!['height']!) 
            : null,
        format: fileExtension,
      );
    } catch (e) {
      throw Exception('Lỗi upload ảnh: $e');
    }
  }

  // Xóa ảnh
  Future<void> deleteImage(PhotoItem photo) async {
    try {
      await _storage.ref(photo.fullPath).delete();
      await _storage.ref(photo.thumbnailPath).delete();
    } catch (e) {
      throw Exception('Lỗi xóa ảnh: $e');
    }
  }

  // Đổi tên ảnh
  Future<void> renameImage(PhotoItem photo, String newName) async {
    try {
      final String newFileName = '${photo.id}.${photo.format}';
      final String newThumbnailName = '${photo.id}-thumb.${photo.format}';
      
      // Copy file sang tên mới
      await _storage.ref(photo.fullPath)
          .copyTo('$_userPhotosPath/$newFileName');
      await _storage.ref(photo.thumbnailPath)
          .copyTo('$_userThumbnailsPath/$newThumbnailName');
      
      // Xóa file cũ
      await _storage.ref(photo.fullPath).delete();
      await _storage.ref(photo.thumbnailPath).delete();
    } catch (e) {
      throw Exception('Lỗi đổi tên ảnh: $e');
    }
  }

  // Lấy download URL
  Future<String> getDownloadUrl(String path) async {
    return await _storage.ref(path).getDownloadURL();
  }

  // Lấy danh sách ảnh
  Future<List<PhotoItem>> getUserPhotos() async {
    try {
      final ListResult result = await _storage.ref(_userPhotosPath).listAll();
      final List<PhotoItem> photos = [];

      for (var item in result.items) {
        final FullMetadata metadata = await item.getMetadata();
        final String fileName = item.name;
        final String id = fileName.split('.').first;
        final String format = fileName.split('.').last;
        final String thumbnailPath = '$_userThumbnailsPath/$id-thumb.$format';

        photos.add(PhotoItem(
          id: id,
          name: metadata.name ?? fileName,
          fullPath: item.fullPath,
          thumbnailPath: thumbnailPath,
          uploadTime: metadata.updated ?? DateTime.now(),
          size: metadata.size ?? 0,
          format: format,
        ));
      }

      return photos;
    } catch (e) {
      throw Exception('Lỗi lấy danh sách ảnh: $e');
    }
  }
}