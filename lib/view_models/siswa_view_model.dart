import 'package:flutter/material.dart';
import '../models/jenis_catatan_model.dart';
import '../models/point_record_model.dart';
import '../models/message_model.dart';
import '../repositories/point_record_repository.dart';
import '../repositories/jenis_catatan_repository.dart';
import '../repositories/message_repository.dart';

/// ViewModel untuk halaman siswa
/// Mengelola data poin, riwayat, status disiplin, jenis poin, dan inbox

class SiswaViewModel extends ChangeNotifier {
  final PointRecordRepository _pointRepo = PointRecordRepository();
  final JenisCatatanRepository _jenisCatatanRepo = JenisCatatanRepository();
  final MessageRepository _messageRepo = MessageRepository();

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

  /// Status disiplin berdasarkan selisih apresiasi (+) dan pelanggaran (-) dengan basis 0
  int get statusDisiplin => _totalApresiasi - _totalPelanggaran;

  /// Pesan peringatan berdasarkan status disiplin
  String? get peringatanDisiplin {
    final score = statusDisiplin;
    if (score <= -100) {
      return '⚠️ Sanksi Berat: Indeks disiplin Anda telah mencapai batas kritis -100 atau kurang. Harap segera meminta keringanan/pembinaan ke Wali Kelas secara offline!';
    } else if (score <= -50) {
      return 'Peringatan Keras: Indeks disiplin Anda telah melewati batas -50. Segera perbaiki perilaku Anda.';
    } else if (score < 0) {
      return 'Peringatan: Indeks disiplin Anda bernilai negatif. Harap kurangi pelanggaran agar tidak mencapai batas sanksi.';
    }
    return null;
  }

  /// Label status disiplin
  String get labelDisiplin {
    final score = statusDisiplin;
    if (score >= 50) return 'Sangat Baik';
    if (score > 0) return 'Baik';
    if (score == 0) return 'Cukup / Netral';
    if (score > -50) return 'Kurang';
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
    final allRecords = await _pointRepo.getPointRecordsBySiswa(_nis);
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
    _daftarApresiasi = await _jenisCatatanRepo.getJenisCatatan('prestasi');
    _daftarPelanggaran = await _jenisCatatanRepo.getJenisCatatan('pelanggaran');
  }

  /// Load inbox pesan
  Future<void> _loadInbox() async {
    _inbox = await _messageRepo.loadMessagesBySiswa(_nis);
  }
}
