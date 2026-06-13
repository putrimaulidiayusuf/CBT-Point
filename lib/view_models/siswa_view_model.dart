import 'package:flutter/material.dart';
import '../models/jenis_catatan_model.dart';
import '../models/point_record_model.dart';
import '../models/message_model.dart';
import '../services/local_data_service.dart';

/// ViewModel untuk halaman siswa
/// Mengelola data poin, riwayat, status disiplin, jenis poin, dan inbox

class SiswaViewModel extends ChangeNotifier {
  final LocalDataService _localDataService = LocalDataService();

  String _nis = '';
  bool _isLoading = false;
  int _totalApresiasi = 0;
  int _totalPelanggaran = 0;
  List<PointRecord> _riwayatApresiasi = [];
  List<PointRecord> _riwayatPelanggaran = [];
  List<JenisCatatan> _daftarApresiasi = [];
  List<JenisCatatan> _daftarPelanggaran = [];
  List<Message> _inbox = [];

  bool get isLoading => _isLoading;
  int get totalApresiasi => _totalApresiasi;
  int get totalPelanggaran => _totalPelanggaran;
  List<PointRecord> get riwayatApresiasi => _riwayatApresiasi;
  List<PointRecord> get riwayatPelanggaran => _riwayatPelanggaran;
  List<JenisCatatan> get daftarApresiasi => _daftarApresiasi;
  List<JenisCatatan> get daftarPelanggaran => _daftarPelanggaran;
  List<Message> get inbox => _inbox;

  /// Status disiplin berdasarkan gabungan apresiasi (+) dan pelanggaran (-)
  int get statusDisiplin => 100 - _totalPelanggaran + _totalApresiasi;

  /// Pesan peringatan berdasarkan status disiplin
  String? get peringatanDisiplin {
    final score = statusDisiplin;
    if (score <= -100) {
      return '⚠️ Sanksi Berat: Indeks disiplin Anda telah mencapai batas kritis -100 atau kurang. Harap segera meminta keringanan/pembinaan ke Wali Kelas secara offline!';
    } else if (score <= 0) {
      return 'Peringatan Keras: Indeks disiplin Anda berada di bawah nol. Harap segera memperbaiki perilaku dan mengumpulkan poin apresiasi.';
    } else if (score <= 50) {
      return 'Peringatan: Indeks disiplin Anda kurang dari 50%. Harap kurangi pelanggaran agar tidak mencapai batas sanksi.';
    }
    return null;
  }

  /// Label status disiplin
  String get labelDisiplin {
    final score = statusDisiplin;
    if (score >= 90) return 'Sangat Baik';
    if (score >= 75) return 'Baik';
    if (score >= 50) return 'Cukup';
    if (score >= 0) return 'Kurang';
    if (score > -100) return 'Peringatan Keras';
    return 'Batas Kritis / Sanksi';
  }

  /// Inisialisasi data siswa berdasarkan NIS
  Future<void> initSiswa(String nis) async {
    _nis = nis;
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadRiwayatPoin(),
        _loadJenisPoin(),
        _loadInbox(),
      ]);
    } catch (e) {
      debugPrint('Error inisialisasi siswa: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh seluruh data siswa
  Future<void> refreshData() async {
    if (_nis.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadRiwayatPoin(),
        _loadInbox(),
      ]);
    } catch (e) {
      debugPrint('Error refresh data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load riwayat poin siswa dan hitung total
  Future<void> _loadRiwayatPoin() async {
    final allRecords = await _localDataService.getPointRecordsBySiswa(_nis);
    _riwayatApresiasi =
        allRecords.where((r) => r.jenisPoin == 'prestasi').toList();
    _riwayatPelanggaran =
        allRecords.where((r) => r.jenisPoin == 'pelanggaran').toList();

    _totalApresiasi = 0;
    for (var r in _riwayatApresiasi) {
      _totalApresiasi += r.poin;
    }

    _totalPelanggaran = 0;
    for (var r in _riwayatPelanggaran) {
      _totalPelanggaran += r.poin;
    }
  }

  /// Load daftar jenis poin dari JSON
  Future<void> _loadJenisPoin() async {
    _daftarApresiasi = await _localDataService.loadJenisPoin('prestasi');
    _daftarPelanggaran = await _localDataService.loadJenisPoin('pelanggaran');
  }

  /// Load inbox pesan
  Future<void> _loadInbox() async {
    _inbox = await _localDataService.getMessagesBySiswa(_nis);
  }
}
