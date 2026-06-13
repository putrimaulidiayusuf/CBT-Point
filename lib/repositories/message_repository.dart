import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';
import '../services/api_service.dart';

class MessageRepository {
  Future<List<Message>> loadMessagesBySiswa(String nis) async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/messages/$nis'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      }
    } catch (e) {
      print('loadMessagesBySiswa error: $e');
    }
    return [];
  }

  Future<bool> addMessage(Message message) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/messages'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(message.toJson()),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('addMessage error: $e');
      return false;
    }
  }

  Future<bool> deleteMessage(String id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiService.baseUrl}/messages/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('deleteMessage error: $e');
      return false;
    }
  }
}
