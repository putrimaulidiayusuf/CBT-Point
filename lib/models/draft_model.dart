import 'user_model.dart';

/// Model untuk draft poin guru yang belum diproses
/// Draft menyimpan jenis poin yang dipilih dan daftar siswa penerima

class Draft {
  final String id;
  final String namaPoin;
  final String detailPoin;
  final String jenisPoin; // 'pelanggaran' atau 'prestasi'
  final int poin;
  final List<Siswa> daftarSiswa;
  final String createdAt;

  Draft({
    required this.id,
    required this.namaPoin,
    required this.detailPoin,
    required this.jenisPoin,
    required this.poin,
    required this.daftarSiswa,
    required this.createdAt,
  });

  factory Draft.fromJson(Map<String, dynamic> json) {
    return Draft(
      id: json['id'],
      namaPoin: json['nama_poin'],
      detailPoin: json['detail_poin'],
      jenisPoin: json['jenis_poin'],
      poin: json['poin'],
      daftarSiswa: (json['daftar_siswa'] as List)
          .map((s) => Siswa.fromJson(s))
          .toList(),
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_poin': namaPoin,
      'detail_poin': detailPoin,
      'jenis_poin': jenisPoin,
      'poin': poin,
      'daftar_siswa': daftarSiswa.map((s) => s.toJson()).toList(),
      'created_at': createdAt,
    };
  }

  Draft copyWith({
    String? id,
    String? namaPoin,
    String? detailPoin,
    String? jenisPoin,
    int? poin,
    List<Siswa>? daftarSiswa,
    String? createdAt,
  }) {
    return Draft(
      id: id ?? this.id,
      namaPoin: namaPoin ?? this.namaPoin,
      detailPoin: detailPoin ?? this.detailPoin,
      jenisPoin: jenisPoin ?? this.jenisPoin,
      poin: poin ?? this.poin,
      daftarSiswa: daftarSiswa ?? this.daftarSiswa,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
