import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_gallery/services/storage_service.dart';
import 'package:cloud_gallery/models/photo_item.dart';
import 'package:cloud_gallery/widgets/photo_tile.dart';
import 'package:cloud_gallery/pages/upload_page.dart';
import 'package:cloud_gallery/pages/preview_page.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late StorageService _storageService;
  List<PhotoItem> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    try {
      _photos = await _storageService.getUserPhotos();
    } catch (e) {
      _showErrorSnackbar('Lỗi tải ảnh: $e');
    }
    setState(() => _isLoading = false);
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UploadPage()),
    ).then((_) => _loadPhotos());
  }

  void _navigateToPreview(PhotoItem photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewPage(
          photo: photo,
          storageService: _storageService,
        ),
      ),
    ).then((_) => _loadPhotos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Gallery'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Chưa có ảnh nào',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Text(
                        'Nhấn nút + để upload ảnh',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _photos.length,
                  itemBuilder: (context, index) {
                    return PhotoTile(
                      photo: _photos[index],
                      onTap: () => _navigateToPreview(_photos[index]),
                      storageService: _storageService,
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToUpload,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
