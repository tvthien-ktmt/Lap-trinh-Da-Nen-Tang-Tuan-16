import 'package:flutter/material.dart';
import 'package:cloud_gallery/pages/login_page.dart';
import 'package:cloud_gallery/services/mock_auth_service.dart';
import 'package:cloud_gallery/services/local_storage_service.dart'; // 👈 THAY ĐỔI

void main() {
  final authService = MockAuthService();
  final storageService =
      LocalStorageService(authService: authService); // 👈 THAY ĐỔI

  runApp(MyApp(authService: authService, storageService: storageService));
}

class MyApp extends StatelessWidget {
  final MockAuthService authService;
  final LocalStorageService storageService; // 👈 THAY ĐỔI

  const MyApp(
      {Key? key, required this.authService, required this.storageService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Gallery',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: LoginPage(authService: authService, storageService: storageService),
      debugShowCheckedModeBanner: false,
    );
  }
}
