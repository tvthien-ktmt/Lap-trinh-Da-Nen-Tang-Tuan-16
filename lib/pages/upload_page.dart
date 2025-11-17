// 📄 FILE: lib/pages/upload_page.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_gallery/services/local_storage_service.dart';

class UploadPage extends StatefulWidget {
  final LocalStorageService storageService;

  const UploadPage({Key? key, required this.storageService}) : super(key: key);

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
          maxWidth: 1920, maxHeight: 1080, imageQuality: 85);
      if (images != null && images.isNotEmpty) {
        setState(() => _selectedImages.addAll(images));
      }
    } catch (e) {
      _showError('Lỗi khi chọn ảnh: $e');
    }
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    int successCount = 0;
    int totalCount = _selectedImages.length;

    for (int i = 0; i < _selectedImages.length; i++) {
      final image = _selectedImages[i];
      try {
        setState(() =>
            _uploadStatus = 'Đang upload ${i + 1}/$totalCount: ${image.name}');

        final File imageFile = File(image.path);
        final bytes = await imageFile.readAsBytes();

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = image.name.split('.').last;
        final fileName = 'image_$timestamp.$extension';

        await widget.storageService.uploadImageBytes(bytes, fileName);
        successCount++;
        setState(() => _uploadProgress = ((i + 1) / totalCount) * 100);
      } catch (e) {
        _showError('Upload thất bại ${image.name}: $e');
      }
    }

    setState(() {
      _isUploading = false;
      _uploadStatus = '';
    });

    if (successCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload thành công $successCount/$totalCount ảnh'),
          backgroundColor: Colors.green));
      Navigator.pop(context, true);
    }
  }

  void _removeImage(int index) =>
      setState(() => _selectedImages.removeAt(index));
  void _clearAll() => setState(() => _selectedImages.clear());

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Ảnh'),
        actions: [
          if (_selectedImages.isNotEmpty && !_isUploading) ...[
            IconButton(
              icon: Icon(Icons.upload),
              onPressed: _uploadImages,
              tooltip: 'Upload tất cả ảnh',
            ),
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: _clearAll,
              tooltip: 'Xóa tất cả ảnh đã chọn',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          if (_isUploading) ...[
            LinearProgressIndicator(
                value: _uploadProgress / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
            Padding(
                padding: EdgeInsets.all(16),
                child: Text(_uploadStatus,
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center)),
          ],
          Expanded(
            child: _selectedImages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Chưa có ảnh nào được chọn',
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('Nhấn nút + để chọn ảnh từ thư viện',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      final image = _selectedImages[index];
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(image.path),
                            fit: BoxFit.cover,
                          ),
                          if (!_isUploading)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle),
                                  child: Icon(Icons.close,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              color: Colors.black54,
                              child: Text(
                                  image.name.length > 15
                                      ? '${image.name.substring(0, 15)}...'
                                      : image.name,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          if (_selectedImages.isNotEmpty && !_isUploading)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8)),
              margin: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tổng số: ${_selectedImages.length} ảnh',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: _uploadImages,
                    icon: Icon(Icons.cloud_upload),
                    label: Text('UPLOAD'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      // ✅ SỬA QUAN TRỌNG: ĐẢM BẢO FAB LUÔN ĐƯỢC RENDER
      floatingActionButton: _isUploading
          ? FloatingActionButton(
              onPressed: null, // Disabled khi uploading
              child: Icon(Icons.add_photo_alternate),
              tooltip: 'Đang upload...',
              backgroundColor: Colors.grey,
            )
          : FloatingActionButton(
              onPressed: _pickImages,
              child: Icon(Icons.add_photo_alternate),
              tooltip: 'Chọn ảnh từ thư viện',
            ),
    );
  }
}
