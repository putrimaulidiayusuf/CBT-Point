import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthRepository {
  /// Melakukan login ke API
  /// Mengembalikan Map dengan 'role' dan 'user', atau null jika gagal
  Future<Map<String, dynamic>?> login(String nama, String password) async {
    try {
      // Coba login sebagai guru
      final guruResponse = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login/guru'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"nama": nama, "nip": password}),
      );
      if (guruResponse.statusCode == 200) {
        final data = json.decode(guruResponse.body);
        return {'role': 'guru', 'user': Guru.fromJson(data['user'] ?? data)};
      }

      // Coba login sebagai siswa
      final siswaResponse = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login/siswa'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"nama": nama, "nis": password}),
      );
      if (siswaResponse.statusCode == 200) {
        final data = json.decode(siswaResponse.body);
        return {'role': 'siswa', 'user': Siswa.fromJson(data['user'] ?? data)};
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  /// Mengambil semua data siswa dari API
  Future<List<Siswa>> getAllSiswa() async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/siswa'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => Siswa.fromJson(e)).toList();
      }
    } catch (e) {
      print('getAllSiswa error: $e');
    }
    return [];
  }

  /// Melakukan pencarian data siswa ke API
  Future<List<Siswa>> searchSiswa(String query) async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/siswa/search?q=$query'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => Siswa.fromJson(e)).toList();
      }
    } catch (e) {
      print('searchSiswa error: $e');
    }
    return [];
  }
}
