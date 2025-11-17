import 'dart:io'; // ✅ THÊM IMPORT NÀY
import 'package:flutter/material.dart';
import '../models/photo_item.dart';

class PhotoTile extends StatelessWidget {
  final PhotoItem photo;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const PhotoTile({
    Key? key,
    required this.photo,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: 2,
        child: Stack(
          fit: StackFit.expand, // ✅ THÊM DÒNG NÀY
          children: [
            // ✅ SỬA: Thay CachedNetworkImage bằng Image.file
            Image.file(
              File(photo.thumbnailUrl), // Dùng file path local
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.error, color: Colors.red),
                );
              },
            ),

            // Overlay thông tin (giữ nguyên)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                color: Colors.black54,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      photo.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${(photo.size / 1024).toStringAsFixed(1)} KB',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
