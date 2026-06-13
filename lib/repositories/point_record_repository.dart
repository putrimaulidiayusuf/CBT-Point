import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/point_record_model.dart';
import '../services/api_service.dart';

class PointRecordRepository {
  Future<List<PointRecord>> getPointRecordsBySiswa(String nis) async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/point_records/siswa/$nis'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((json) => PointRecord.fromJson(json)).toList();
      }
    } catch (e) {
      print('getPointRecordsBySiswa error: $e');
    }
    return [];
  }

  Future<List<PointRecord>> getPointRecordsByGuru(String namaGuru) async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/point_records/guru/$namaGuru'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((json) => PointRecord.fromJson(json)).toList();
      }
    } catch (e) {
      print('getPointRecordsByGuru error: $e');
    }
    return [];
  }

  Future<bool> addPointRecord(PointRecord record) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/point_records'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(record.toJson()),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('addPointRecord error: $e');
      return false;
    }
  }

  Future<bool> deletePointRecord(String id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiService.baseUrl}/point_records/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('deletePointRecord error: $e');
      return false;
    }
  }
}
