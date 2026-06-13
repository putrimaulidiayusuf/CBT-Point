import 'package:flutter/material.dart';
import '../models/jenis_catatan_model.dart';
import '../repositories/jenis_catatan_repository.dart';

class JenisCatatanViewModel extends ChangeNotifier {
  List<JenisCatatan> _listData = [];
  bool _isLoading = false;
  final JenisCatatanRepository _repo = JenisCatatanRepository();

  List<JenisCatatan> get listData => _listData;
  bool get isLoading => _isLoading;

  Future<void> fetchJenisCatatan(String tipe) async {
    _isLoading = true;
    notifyListeners();
    try {
      _listData = await _repo.getJenisCatatan(tipe);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addData(JenisCatatan item) async {
    bool success = await _repo.addJenisCatatan(item);
    if (success) fetchJenisCatatan(item.tipe);
    return success;
  }

  Future<bool> updateData(int id, JenisCatatan item) async {
    bool success = await _repo.updateJenisCatatan(id, item);
    if (success) fetchJenisCatatan(item.tipe);
    return success;
  }

  Future<bool> deleteData(int id, String currentTipe) async {
    bool success = await _repo.deleteJenisCatatan(id);
    if (success) fetchJenisCatatan(currentTipe);
    return success;
  }
}