import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/jenis_catatan_model.dart';

class ApiService {
  final String baseUrl = "http://localhost:3000"; // Ganti 10.0.2.2 jika pake emulator

  // GET
  Future<List<JenisCatatan>> getJenisCatatan(String tipe) async {
    final response = await http.get(Uri.parse('$baseUrl/jenis_catatan/$tipe'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => JenisCatatan.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data');
    }
  }

  // POST (Tambah)
  Future<bool> addJenisCatatan(JenisCatatan item) async {
    final response = await http.post(
      Uri.parse('$baseUrl/jenis_catatan'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "nama": item.nama,
        "deskripsi": item.deskripsi,
        "tipe": item.tipe,
        "poin": item.poin,
      }),
    );
    return response.statusCode == 201;
  }

  // PUT (Update)
  Future<bool> updateJenisCatatan(int id, JenisCatatan item) async {
    final response = await http.put(
      Uri.parse('$baseUrl/jenis_catatan/$id'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "nama": item.nama,
        "deskripsi": item.deskripsi,
        "tipe": item.tipe,
        "poin": item.poin,
      }),
    );
    return response.statusCode == 200;
  }

  // DELETE
  Future<bool> deleteJenisCatatan(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/jenis_catatan/$id'));
    return response.statusCode == 200;
  }
}