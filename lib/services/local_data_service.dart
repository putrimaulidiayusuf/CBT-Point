import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/jenis_catatan_model.dart';
import '../models/point_record_model.dart';
import '../models/draft_model.dart';
import '../models/message_model.dart';

/// Service untuk mengelola data lokal
/// Menggunakan assets JSON untuk jenis poin
/// Menggunakan SharedPreferences untuk data persist (riwayat, draft, pesan)

class LocalDataService {
  static const String _pointRecordsKey = 'point_records';
  static const String _draftsKey = 'drafts';
  static const String _messagesKey = 'messages';

  // ===== LOAD JENIS POIN DARI JSON =====

  /// Membaca file point_siswa.json dari assets
  /// Mengembalikan list JenisCatatan berdasarkan tipe ('pelanggaran' atau 'prestasi')
  Future<List<JenisCatatan>> loadJenisPoin(String tipe) async {
    final String jsonString =
        await rootBundle.loadString('assets/point_siswa.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final List<dynamic> items = jsonData[tipe] ?? [];
    int idCounter = 1;
    return items.map((item) {
      return JenisCatatan(
        idJenis: idCounter++,
        nama: item['nama'] ?? '',
        deskripsi: item['deskripsi'] ?? '',
        tipe: tipe,
        poin: item['poin'] ?? 0,
      );
    }).toList();
  }

  /// Membaca semua jenis poin (pelanggaran + prestasi)
  Future<List<JenisCatatan>> loadAllJenisPoin() async {
    final pelanggaran = await loadJenisPoin('pelanggaran');
    final prestasi = await loadJenisPoin('prestasi');
    return [...pelanggaran, ...prestasi];
  }

  // ===== POINT RECORDS (RIWAYAT POIN) =====

  /// Menyimpan seluruh riwayat poin ke SharedPreferences
  Future<void> savePointRecords(List<PointRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((r) => json.encode(r.toJson())).toList();
    await prefs.setStringList(_pointRecordsKey, jsonList);
  }

  /// Membaca seluruh riwayat poin dari SharedPreferences
  Future<List<PointRecord>> loadPointRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_pointRecordsKey) ?? [];
    return jsonList
        .map((s) => PointRecord.fromJson(json.decode(s)))
        .toList();
  }

  /// Menambah satu riwayat poin
  Future<void> addPointRecord(PointRecord record) async {
    final records = await loadPointRecords();
    records.insert(0, record);
    await savePointRecords(records);
  }

  /// Menghapus riwayat poin berdasarkan ID
  Future<void> deletePointRecord(String id) async {
    final records = await loadPointRecords();
    records.removeWhere((r) => r.id == id);
    await savePointRecords(records);
  }

  /// Mendapatkan riwayat poin untuk siswa tertentu (berdasarkan NIS)
  Future<List<PointRecord>> getPointRecordsBySiswa(String nis) async {
    final records = await loadPointRecords();
    return records.where((r) => r.nisSiswa == nis).toList();
  }

  /// Mendapatkan riwayat poin yang diberikan guru tertentu (berdasarkan nama guru)
  Future<List<PointRecord>> getPointRecordsByGuru(String namaGuru) async {
    final records = await loadPointRecords();
    return records.where((r) => r.namaGuru == namaGuru).toList();
  }

  /// Menghitung total poin apresiasi siswa
  Future<int> getTotalApresiasi(String nis) async {
    final records = await getPointRecordsBySiswa(nis);
    int total = 0;
    for (var r in records) {
      if (r.jenisPoin == 'prestasi') total += r.poin;
    }
    return total;
  }

  /// Menghitung total poin pelanggaran siswa
  Future<int> getTotalPelanggaran(String nis) async {
    final records = await getPointRecordsBySiswa(nis);
    int total = 0;
    for (var r in records) {
      if (r.jenisPoin == 'pelanggaran') total += r.poin;
    }
    return total;
  }

  // ===== DRAFTS (DRAFT GURU) =====

  /// Menyimpan seluruh draft ke SharedPreferences
  Future<void> saveDrafts(List<Draft> drafts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = drafts.map((d) => json.encode(d.toJson())).toList();
    await prefs.setStringList(_draftsKey, jsonList);
  }

  /// Membaca seluruh draft dari SharedPreferences
  Future<List<Draft>> loadDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_draftsKey) ?? [];
    return jsonList.map((s) => Draft.fromJson(json.decode(s))).toList();
  }

  /// Menambah satu draft
  Future<void> addDraft(Draft draft) async {
    final drafts = await loadDrafts();
    drafts.insert(0, draft);
    await saveDrafts(drafts);
  }

  /// Mengupdate draft berdasarkan ID
  Future<void> updateDraft(Draft updatedDraft) async {
    final drafts = await loadDrafts();
    final index = drafts.indexWhere((d) => d.id == updatedDraft.id);
    if (index != -1) {
      drafts[index] = updatedDraft;
      await saveDrafts(drafts);
    }
  }

  /// Menghapus draft berdasarkan ID
  Future<void> deleteDraft(String id) async {
    final drafts = await loadDrafts();
    drafts.removeWhere((d) => d.id == id);
    await saveDrafts(drafts);
  }

  // ===== MESSAGES (PESAN SISWA) =====

  /// Menyimpan seluruh pesan ke SharedPreferences
  Future<void> saveMessages(List<Message> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = messages.map((m) => json.encode(m.toJson())).toList();
    await prefs.setStringList(_messagesKey, jsonList);
  }

  /// Membaca seluruh pesan dari SharedPreferences
  Future<List<Message>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_messagesKey) ?? [];
    return jsonList.map((s) => Message.fromJson(json.decode(s))).toList();
  }

  /// Menambah satu pesan
  Future<void> addMessage(Message message) async {
    final messages = await loadMessages();
    messages.insert(0, message);
    await saveMessages(messages);
  }

  /// Mendapatkan pesan untuk siswa tertentu (berdasarkan NIS)
  Future<List<Message>> getMessagesBySiswa(String nis) async {
    final messages = await loadMessages();
    return messages.where((m) => m.nisTujuan == nis).toList();
  }

  /// Menghapus pesan berdasarkan ID
  Future<void> deleteMessage(String id) async {
    final messages = await loadMessages();
    messages.removeWhere((m) => m.id == id);
    await saveMessages(messages);
  }
}
