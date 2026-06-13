/// Model untuk pesan/inbox siswa
/// Pesan dikirim oleh guru ke siswa tertentu

class Message {
  final String id;
  final String judul;
  final String isiPesan;
  final String pengirim;
  final String nisTujuan;
  final String tanggal;
  final String jam;
  final String? catatan;
  final String? lampiran;
  final bool isRead;

  Message({
    required this.id,
    required this.judul,
    required this.isiPesan,
    required this.pengirim,
    required this.nisTujuan,
    required this.tanggal,
    required this.jam,
    this.catatan,
    this.lampiran,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      judul: json['judul'],
      isiPesan: json['isi_pesan'],
      pengirim: json['pengirim'],
      nisTujuan: json['nis_tujuan'],
      tanggal: json['tanggal'],
      jam: json['jam'],
      catatan: json['catatan'],
      lampiran: json['lampiran'],
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isi_pesan': isiPesan,
      'pengirim': pengirim,
      'nis_tujuan': nisTujuan,
      'tanggal': tanggal,
      'jam': jam,
      'catatan': catatan,
      'lampiran': lampiran,
      'is_read': isRead,
    };
  }
}
