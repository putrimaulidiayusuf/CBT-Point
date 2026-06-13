import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/jenis_catatan_model.dart';
import '../services/api_service.dart';

class JenisCatatanRepository {
  Future<List<JenisCatatan>> getJenisCatatan(String tipe) async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/jenis_catatan/$tipe'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((json) => JenisCatatan.fromJson(json)).toList();
      }
    } catch (e) {
      print('getJenisCatatan error: $e');
    }
    return [];
  }

  Future<bool> addJenisCatatan(JenisCatatan item) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/jenis_catatan'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "nama": item.nama,
          "deskripsi": item.deskripsi,
          "tipe": item.tipe,
          "poin": item.poin,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('addJenisCatatan error: $e');
      return false;
    }
  }

  Future<bool> updateJenisCatatan(int id, JenisCatatan item) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/jenis_catatan/$id'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "nama": item.nama,
          "deskripsi": item.deskripsi,
          "tipe": item.tipe,
          "poin": item.poin,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('updateJenisCatatan error: $e');
      return false;
    }
  }

  Future<bool> deleteJenisCatatan(int id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiService.baseUrl}/jenis_catatan/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('deleteJenisCatatan error: $e');
      return false;
    }
  }
}
