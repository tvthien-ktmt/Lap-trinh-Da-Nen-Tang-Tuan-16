// 📄 FILE: lib/services/mock_auth_service.dart
class MockAuthService {
  String? _currentUser;

  String? get currentUser => _currentUser;

  Future<bool> login(String username, String password) async {
    await Future.delayed(Duration(seconds: 1));
    _currentUser = username;
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  bool get isLoggedIn => _currentUser != null;
}
