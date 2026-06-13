/// Model untuk riwayat poin yang diberikan guru ke siswa
/// Digunakan di riwayat guru dan riwayat siswa

class PointRecord {
  final String id;
  final String namaPoin;
  final String detailPoin;
  final String jenisPoin; // 'pelanggaran' atau 'prestasi'
  final int poin;
  final String namaGuru;
  final String namaSiswa;
  final String kelasSiswa;
  final String nisSiswa;
  final String tanggal;
  final String jam;

  PointRecord({
    required this.id,
    required this.namaPoin,
    required this.detailPoin,
    required this.jenisPoin,
    required this.poin,
    required this.namaGuru,
    required this.namaSiswa,
    required this.kelasSiswa,
    required this.nisSiswa,
    required this.tanggal,
    required this.jam,
  });

  factory PointRecord.fromJson(Map<String, dynamic> json) {
    return PointRecord(
      id: json['id'],
      namaPoin: json['nama_poin'],
      detailPoin: json['detail_poin'],
      jenisPoin: json['jenis_poin'],
      poin: json['poin'],
      namaGuru: json['nama_guru'],
      namaSiswa: json['nama_siswa'],
      kelasSiswa: json['kelas_siswa'],
      nisSiswa: json['nis_siswa'],
      tanggal: json['tanggal'],
      jam: json['jam'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_poin': namaPoin,
      'detail_poin': detailPoin,
      'jenis_poin': jenisPoin,
      'poin': poin,
      'nama_guru': namaGuru,
      'nama_siswa': namaSiswa,
      'kelas_siswa': kelasSiswa,
      'nis_siswa': nisSiswa,
      'tanggal': tanggal,
      'jam': jam,
    };
  }
}
