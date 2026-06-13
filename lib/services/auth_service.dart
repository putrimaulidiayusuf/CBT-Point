import '../models/user_model.dart';

/// Service untuk autentikasi login
/// Berisi data contoh guru dan siswa
/// Login menggunakan Nama + NIP (guru) atau Nama + NIS (siswa)

class AuthService {
  // Data contoh guru
  static final List<Guru> _daftarGuru = [
    Guru(nama: 'Fajar M Sukmawijaya', nip: '1987654321'),
    Guru(nama: 'Sarah S Sumaerah', nip: '1987654322'),
  ];

  // Data contoh siswa
  static final List<Siswa> _daftarSiswa = [
    Siswa(nama: 'Putri Maulidia Yusuf', nis: '123456', kelas: 'XI RPL 1'),
    Siswa(nama: 'Putri Sebelas Rpl', nis: '123457', kelas: 'XI RPL 1'),
    Siswa(nama: 'Putri Rpl Dua', nis: '123458', kelas: 'XI RPL 2'),
  ];

  /// Mendapatkan seluruh daftar siswa
  List<Siswa> getAllSiswa() => _daftarSiswa;

  /// Mendapatkan seluruh daftar guru
  List<Guru> getAllGuru() => _daftarGuru;

  /// Mencari siswa berdasarkan NIS
  Siswa? getSiswaByNis(String nis) {
    try {
      return _daftarSiswa.firstWhere((s) => s.nis == nis);
    } catch (_) {
      return null;
    }
  }

  /// Login: mencocokkan nama dan password (NIP/NIS)
  /// Mengembalikan Map dengan key 'role' ('guru'/'siswa') dan 'user' (Guru/Siswa)
  /// Mengembalikan null jika gagal
  Map<String, dynamic>? login(String nama, String password) {
    // Cek apakah guru
    for (var guru in _daftarGuru) {
      if (guru.nama.toLowerCase() == nama.toLowerCase() &&
          guru.nip == password) {
        return {'role': 'guru', 'user': guru};
      }
    }

    // Cek apakah siswa
    for (var siswa in _daftarSiswa) {
      if (siswa.nama.toLowerCase() == nama.toLowerCase() &&
          siswa.nis == password) {
        return {'role': 'siswa', 'user': siswa};
      }
    }

    return null;
  }

  /// Mencari siswa berdasarkan query (nama, kelas, atau NIS)
  List<Siswa> searchSiswa(String query) {
    if (query.isEmpty) return _daftarSiswa;
    final q = query.toLowerCase();
    return _daftarSiswa.where((s) {
      return s.nama.toLowerCase().contains(q) ||
          s.kelas.toLowerCase().contains(q) ||
          s.nis.contains(q);
    }).toList();
  }
}
