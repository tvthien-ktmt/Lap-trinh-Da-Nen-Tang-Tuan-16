// 📄 FILE: lib/pages/preview_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_gallery/services/local_storage_service.dart';
import '../models/photo_item.dart';

class PreviewPage extends StatefulWidget {
  final PhotoItem photo;
  final LocalStorageService storageService;
  final VoidCallback onUpdate;

  const PreviewPage(
      {Key? key,
      required this.photo,
      required this.storageService,
      required this.onUpdate})
      : super(key: key);

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  bool _isLoading = false;

  Future<void> _deletePhoto() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa ảnh?'),
        content: Text('Bạn có chắc muốn xóa "${widget.photo.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await widget.storageService.deletePhoto(widget.photo.name);
        widget.onUpdate();
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Đã xóa ảnh thành công')));
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Xóa thất bại: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _sharePhoto() async {
    try {
      await Share.share(
          'Xem ảnh của tôi: ${widget.photo.name}\n\nShared from Cloud Gallery App',
          subject: 'Chia sẻ ảnh từ Cloud Gallery');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Chia sẻ thất bại: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.photo.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'share') _sharePhoto();
              if (value == 'delete') _deletePhoto();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: 'share',
                  child: Row(children: [
                    Icon(Icons.share, size: 20),
                    SizedBox(width: 8),
                    Text('Chia sẻ')
                  ])),
              PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Xóa', style: TextStyle(color: Colors.red))
                  ])),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ SỬA: Dùng Expanded với flex cố định
          Expanded(
            flex: 3, // 3 phần cho ảnh
            child: InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              child: Center(
                child: Image.file(
                  File(widget.photo.url),
                  fit: BoxFit.contain,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) return child;
                    return AnimatedOpacity(
                      child: child,
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOut,
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 64, color: Colors.red),
                          SizedBox(height: 16),
                          Text('Lỗi tải ảnh')
                        ]);
                  },
                ),
              ),
            ),
          ),
          // ✅ SỬA: Container thông tin với height cố định
          Container(
            width: double.infinity,
            height: 150, // ✅ THÊM: Chiều cao cố định
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!))),
            child: SingleChildScrollView(
              // ✅ THÊM: Cho phép scroll nếu nội dung dài
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Thông tin ảnh',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(children: [
                    _buildInfoItem(Icons.title, 'Tên', widget.photo.name),
                    SizedBox(width: 16),
                    _buildInfoItem(Icons.format_size, 'Kích thước',
                        '${(widget.photo.size / 1024).toStringAsFixed(1)} KB'),
                  ]),
                  if (widget.photo.width != null &&
                      widget.photo.height != null) ...[
                    SizedBox(height: 8),
                    Row(children: [
                      _buildInfoItem(Icons.aspect_ratio, 'Độ phân giải',
                          '${widget.photo.width} x ${widget.photo.height}'),
                      SizedBox(width: 16),
                      _buildInfoItem(Icons.calendar_today, 'Upload',
                          '${widget.photo.uploadTime.day}/${widget.photo.uploadTime.month}/${widget.photo.uploadTime.year}'),
                    ]),
                  ],
                  SizedBox(height: 8),
                  _buildInfoItem(Icons.folder, 'Vị trí', widget.photo.url),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Flexible(
      // ✅ SỬA: Dùng Flexible thay vì Expanded
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold))
          ]),
          SizedBox(height: 2),
          Text(value,
              style: TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
