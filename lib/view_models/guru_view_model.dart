import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/jenis_catatan_model.dart';
import '../models/point_record_model.dart';
import '../models/draft_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/jenis_catatan_repository.dart';
import '../repositories/point_record_repository.dart';
import '../repositories/draft_repository.dart';
import '../repositories/message_repository.dart';

/// ViewModel untuk halaman guru
/// Mengelola riwayat poin, draft, jenis poin, scan QR, dan kirim pesan

class GuruViewModel extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  final JenisCatatanRepository _jenisCatatanRepo = JenisCatatanRepository();
  final PointRecordRepository _pointRepo = PointRecordRepository();
  final DraftRepository _draftRepo = DraftRepository();
  final MessageRepository _messageRepo = MessageRepository();

  String _namaGuru = '';
  bool _isLoading = false;

  // Riwayat poin yang pernah diberikan
  List<PointRecord> _riwayatPoin = [];
  List<PointRecord> _filteredRiwayat = [];
  String _searchQuery = '';
  String _filterJenis = 'semua'; // 'semua', 'prestasi', 'pelanggaran'

  // Jenis poin dari JSON
  List<JenisCatatan> _daftarApresiasi = [];
  List<JenisCatatan> _daftarPelanggaran = [];

  // Draft
  List<Draft> _drafts = [];

  // Daftar siswa yang dipilih untuk menerima poin
  List<Siswa> _selectedSiswa = [];

  // Jenis poin yang sedang dipilih
  JenisCatatan? _selectedPoin;

  bool get isLoading => _isLoading;
  List<PointRecord> get riwayatPoin => _filteredRiwayat;
  List<JenisCatatan> get daftarApresiasi => _daftarApresiasi;
  List<JenisCatatan> get daftarPelanggaran => _daftarPelanggaran;
  List<Draft> get drafts => _drafts;
  List<Siswa> get selectedSiswa => _selectedSiswa;
  JenisCatatan? get selectedPoin => _selectedPoin;
  String get filterJenis => _filterJenis;
  String get searchQuery => _searchQuery;

  /// Inisialisasi data guru
  Future<void> initGuru(String namaGuru) async {
    _namaGuru = namaGuru;
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadSemuaSiswa(),
        _loadRiwayatPoin(),
        _loadJenisPoin(),
        _loadDrafts(),
      ]);
    } catch (e) {
      debugPrint('Error inisialisasi guru: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh seluruh data guru
  Future<void> refreshData() async {
    if (_namaGuru.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadSemuaSiswa(),
        _loadRiwayatPoin(),
        _loadDrafts(),
      ]);
    } catch (e) {
      debugPrint('Error refresh data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== RIWAYAT POIN =====

  Future<void> _loadRiwayatPoin() async {
    _riwayatPoin = await _pointRepo.getPointRecordsByGuru(_namaGuru);
    _applyFilter();
  }

  /// Set search query dan apply filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  /// Set filter jenis dan apply filter
  void setFilterJenis(String jenis) {
    _filterJenis = jenis;
    _applyFilter();
    notifyListeners();
  }

  /// Apply filter dan search ke riwayat
  void _applyFilter() {
    var filtered = List<PointRecord>.from(_riwayatPoin);

    // Filter berdasarkan jenis
    if (_filterJenis != 'semua') {
      filtered = filtered.where((r) => r.jenisPoin == _filterJenis).toList();
    }

    // Search multi-field
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((r) {
        return r.namaSiswa.toLowerCase().contains(q) ||
            r.kelasSiswa.toLowerCase().contains(q) ||
            r.namaPoin.toLowerCase().contains(q) ||
            r.detailPoin.toLowerCase().contains(q) ||
            r.poin.toString().contains(q) ||
            r.tanggal.contains(q) ||
            r.jam.contains(q);
      }).toList();
    }

    _filteredRiwayat = filtered;
  }

  /// Hapus riwayat poin berdasarkan ID
  Future<void> deleteRiwayat(String id) async {
    await _pointRepo.deletePointRecord(id);
    await _loadRiwayatPoin();
    notifyListeners();
  }

  // ===== JENIS POIN =====

  Future<void> _loadJenisPoin() async {
    _daftarApresiasi = await _jenisCatatanRepo.getJenisCatatan('prestasi');
    _daftarPelanggaran = await _jenisCatatanRepo.getJenisCatatan('pelanggaran');
  }

  /// Pilih jenis poin yang akan diberikan
  void selectPoin(JenisCatatan poin) {
    _selectedPoin = poin;
    notifyListeners();
  }

  /// Reset pilihan poin
  void resetSelectedPoin() {
    _selectedPoin = null;
    _selectedSiswa.clear();
    notifyListeners();
  }

  // ===== SISWA PENERIMA =====

  List<Siswa> _semuaSiswa = [];
  
  /// Mengambil daftar semua siswa melalui API (hanya dipanggil internal)
  Future<void> _loadSemuaSiswa() async {
    _semuaSiswa = await _authRepo.getAllSiswa();
  }

  /// Mendapatkan daftar semua siswa dari cache lokal view model
  List<Siswa> getAllSiswa() => _semuaSiswa;

  /// Mencari siswa dari cache lokal (atau bisa query ke API)
  List<Siswa> searchSiswa(String query) {
    if (query.isEmpty) return _semuaSiswa;
    final q = query.toLowerCase();
    return _semuaSiswa.where((s) => s.nama.toLowerCase().contains(q) || s.nis.contains(q) || s.kelas.toLowerCase().contains(q)).toList();
  }

  /// Mencari siswa berdasarkan NIS (untuk scan QR)
  Siswa? getSiswaByNis(String nis) {
    try {
      return _semuaSiswa.firstWhere((s) => s.nis == nis);
    } catch (_) {
      return null;
    }
  }

  /// Tambah siswa ke daftar penerima
  void addSiswaPenerima(Siswa siswa) {
    if (!_selectedSiswa.contains(siswa)) {
      _selectedSiswa.add(siswa);
      notifyListeners();
    }
  }

  /// Hapus siswa dari daftar penerima
  void removeSiswaPenerima(Siswa siswa) {
    _selectedSiswa.remove(siswa);
    notifyListeners();
  }

  /// Clear daftar penerima
  void clearSelectedSiswa() {
    _selectedSiswa.clear();
    notifyListeners();
  }

  // ===== BERIKAN POIN =====

  /// Berikan poin ke satu siswa
  Future<void> berikanPoinKeSiswa(
      JenisCatatan poin, Siswa siswa) async {
    final now = DateTime.now();
    final record = PointRecord(
      id: '${now.millisecondsSinceEpoch}_${siswa.nis}',
      namaPoin: poin.nama,
      detailPoin: poin.deskripsi,
      jenisPoin: poin.tipe,
      poin: poin.poin,
      namaGuru: _namaGuru,
      namaSiswa: siswa.nama,
      kelasSiswa: siswa.kelas,
      nisSiswa: siswa.nis,
      tanggal: DateFormat('dd/MM/yyyy').format(now),
      jam: DateFormat('HH:mm').format(now),
    );
    await _pointRepo.addPointRecord(record);
  }

  /// Berikan poin ke semua siswa yang dipilih
  Future<void> berikanPoinKeSemuaSiswa() async {
    if (_selectedPoin == null || _selectedSiswa.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      for (var siswa in _selectedSiswa) {
        await berikanPoinKeSiswa(_selectedPoin!, siswa);
      }
      _selectedSiswa.clear();
      _selectedPoin = null;
      await _loadRiwayatPoin();
    } catch (e) {
      debugPrint('Error berikan poin: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== DRAFT =====

  Future<void> _loadDrafts() async {
    _drafts = await _draftRepo.loadDrafts();
  }

  /// Simpan draft baru
  Future<void> simpanDraft() async {
    if (_selectedPoin == null || _selectedSiswa.isEmpty) return;

    final now = DateTime.now();
    final draft = Draft(
      id: now.millisecondsSinceEpoch.toString(),
      namaPoin: _selectedPoin!.nama,
      detailPoin: _selectedPoin!.deskripsi,
      jenisPoin: _selectedPoin!.tipe,
      poin: _selectedPoin!.poin,
      daftarSiswa: List.from(_selectedSiswa),
      createdAt: DateFormat('dd/MM/yyyy HH:mm').format(now),
    );

    await _draftRepo.addDraft(draft);
    _selectedSiswa.clear();
    _selectedPoin = null;
    await _loadDrafts();
    notifyListeners();
  }

  /// Hapus draft berdasarkan ID
  Future<void> hapusDraft(String id) async {
    await _draftRepo.deleteDraft(id);
    await _loadDrafts();
    notifyListeners();
  }

  /// Proses draft: berikan poin ke semua siswa dalam draft
  Future<void> prosesDraft(Draft draft) async {
    _isLoading = true;
    notifyListeners();

    try {
      final poin = JenisCatatan(
        idJenis: 0,
        nama: draft.namaPoin,
        deskripsi: draft.detailPoin,
        tipe: draft.jenisPoin,
        poin: draft.poin,
      );

      for (var siswa in draft.daftarSiswa) {
        await berikanPoinKeSiswa(poin, siswa);
      }

      await _draftRepo.deleteDraft(draft.id);
      await Future.wait([_loadRiwayatPoin(), _loadDrafts()]);
    } catch (e) {
      debugPrint('Error proses draft: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Proses draft untuk satu siswa saja
  Future<void> prosesDraftSatuSiswa(Draft draft, Siswa siswa) async {
    final poin = JenisCatatan(
      idJenis: 0,
      nama: draft.namaPoin,
      deskripsi: draft.detailPoin,
      tipe: draft.jenisPoin,
      poin: draft.poin,
    );

    await berikanPoinKeSiswa(poin, siswa);

    // Update draft — hapus siswa yang sudah diproses
    final updatedSiswa = List<Siswa>.from(draft.daftarSiswa)..remove(siswa);
    if (updatedSiswa.isEmpty) {
      await _draftRepo.deleteDraft(draft.id);
    } else {
      await _draftRepo.updateDraft(
        draft.copyWith(daftarSiswa: updatedSiswa),
      );
    }

    await Future.wait([_loadRiwayatPoin(), _loadDrafts()]);
    notifyListeners();
  }

  /// Update draft (edit daftar siswa)
  Future<void> updateDraft(Draft draft) async {
    await _draftRepo.updateDraft(draft);
    await _loadDrafts();
    notifyListeners();
  }

  // ===== PESAN / SURAT =====

  /// Kirim pesan ke siswa
  Future<void> kirimPesan({
    required String judul,
    required String isiPesan,
    required List<Siswa> tujuan,
    String? catatan,
    String? lampiran,
  }) async {
    final now = DateTime.now();
    for (var siswa in tujuan) {
      final message = Message(
        id: '${now.millisecondsSinceEpoch}_${siswa.nis}',
        judul: judul,
        isiPesan: isiPesan,
        pengirim: _namaGuru,
        nisTujuan: siswa.nis,
        tanggal: DateFormat('dd/MM/yyyy').format(now),
        jam: DateFormat('HH:mm').format(now),
        catatan: catatan,
        lampiran: lampiran,
      );
      await _messageRepo.addMessage(message);
    }
    notifyListeners();
  }
}
