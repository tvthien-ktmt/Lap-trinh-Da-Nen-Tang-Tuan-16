// 📄 FILE: lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_gallery/services/mock_auth_service.dart';
import 'package:cloud_gallery/services/local_storage_service.dart'; // ✅ THAY ĐỔI
import 'gallery_page.dart';

class LoginPage extends StatefulWidget {
  final MockAuthService authService;
  final LocalStorageService storageService; // ✅ THAY ĐỔI

  const LoginPage(
      {Key? key, required this.authService, required this.storageService})
      : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_usernameController.text.isEmpty) {
      _showError('Vui lòng nhập tên người dùng');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await widget.authService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryPage(
              authService: widget.authService,
              storageService: widget.storageService,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Lỗi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud, size: 80, color: Colors.blue),
            SizedBox(height: 16),
            Text('Cloud Gallery',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
            SizedBox(height: 8),
            Text('Đăng nhập để xem ảnh của bạn',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 40),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                  labelText: 'Tên người dùng',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder()),
              obscureText: true,
            ),
            SizedBox(height: 24),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  child: Text('ĐĂNG NHẬP'),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[100]!)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thư viện ảnh của tôi',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
