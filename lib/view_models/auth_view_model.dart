import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

/// ViewModel untuk autentikasi login
/// Mengelola state login, logout, dan session pengguna

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  String? _userRole; // 'guru' atau 'siswa'
  Guru? _currentGuru;
  Siswa? _currentSiswa;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userRole => _userRole;
  Guru? get currentGuru => _currentGuru;
  Siswa? get currentSiswa => _currentSiswa;
  bool get isLoggedIn => _userRole != null;

  /// Login dengan nama dan password (NIP/NIS)
  Future<bool> login(String nama, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulasi delay network
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final result = await _authRepo.login(nama, password);

      if (result != null) {
        _userRole = result['role'];
        if (_userRole == 'guru') {
          _currentGuru = result['user'] as Guru;
          _currentSiswa = null;
        } else {
          _currentSiswa = result['user'] as Siswa;
          _currentGuru = null;
        }
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Nama atau password salah. Periksa kembali!';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout — reset semua state
  void logout() {
    _userRole = null;
    _currentGuru = null;
    _currentSiswa = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Bersihkan error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
