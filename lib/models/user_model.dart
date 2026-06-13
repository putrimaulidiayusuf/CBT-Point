/// Model untuk user (Guru dan Siswa)
/// Digunakan untuk autentikasi dan identifikasi pengguna

class Guru {
  final String nama;
  final String nip;

  Guru({required this.nama, required this.nip});

  factory Guru.fromJson(Map<String, dynamic> json) {
    return Guru(
      nama: json['nama'],
      nip: json['nip'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'nip': nip,
    };
  }
}

class Siswa {
  final String nama;
  final String nis;
  final String kelas;

  Siswa({required this.nama, required this.nis, required this.kelas});

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      nama: json['nama'],
      nis: json['nis'],
      kelas: json['kelas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'nis': nis,
      'kelas': kelas,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Siswa && runtimeType == other.runtimeType && nis == other.nis;

  @override
  int get hashCode => nis.hashCode;
}
