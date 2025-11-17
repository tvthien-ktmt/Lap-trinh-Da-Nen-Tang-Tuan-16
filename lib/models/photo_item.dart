class PhotoItem {
  final String name;
  final String url;
  final String thumbnailUrl;
  final DateTime uploadTime;
  final int size;
  final String? format;
  final int? width;
  final int? height;

  PhotoItem({
    required this.name,
    required this.url,
    required this.thumbnailUrl,
    required this.uploadTime,
    required this.size,
    this.format,
    this.width,
    this.height,
  });

  factory PhotoItem.fromMap(Map<String, dynamic> map) {
    return PhotoItem(
      name: map['name'],
      url: map['url'],
      thumbnailUrl: map['thumbnailUrl'],
      uploadTime: DateTime.parse(map['uploadTime']),
      size: map['size'],
      format: map['format'],
      width: map['width'],
      height: map['height'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'uploadTime': uploadTime.toIso8601String(),
      'size': size,
      'format': format,
      'width': width,
      'height': height,
    };
  }
}
