import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/draft_model.dart';
import '../services/api_service.dart';

class DraftRepository {
  Future<List<Draft>> loadDrafts() async {
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/drafts'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((json) => Draft.fromJson(json)).toList();
      }
    } catch (e) {
      print('loadDrafts error: $e');
    }
    return [];
  }

  Future<bool> addDraft(Draft draft) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/drafts'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(draft.toJson()),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('addDraft error: $e');
      return false;
    }
  }

  Future<bool> updateDraft(Draft draft) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/drafts/${draft.id}'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(draft.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('updateDraft error: $e');
      return false;
    }
  }

  Future<bool> deleteDraft(String id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiService.baseUrl}/drafts/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('deleteDraft error: $e');
      return false;
    }
  }
}
