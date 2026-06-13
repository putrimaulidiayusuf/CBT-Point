import 'package:flutter/material.dart';
import '../../models/point_record_model.dart';

/// Halaman detail riwayat poin yang diterima siswa
/// Menampilkan daftar riwayat apresiasi atau pelanggaran

class RiwayatPoinSiswaView extends StatelessWidget {
  final String title;
  final List<PointRecord> records;
  final bool isApresiasi;

  const RiwayatPoinSiswaView({
    super.key,
    required this.title,
    required this.records,
    required this.isApresiasi,
  });

  @override
  Widget build(BuildContext context) {
    final color = isApresiasi ? const Color(0xFF4CAF50) : Colors.redAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
      ),
      body: records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isApresiasi ? Icons.emoji_events_outlined : Icons.warning_amber_outlined,
                    size: 64,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat ${isApresiasi ? 'apresiasi' : 'pelanggaran'}',
                    style: TextStyle(
                      color: Colors.grey.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return _buildRecordCard(context, record, color);
              },
            ),
    );
  }

  Widget _buildRecordCard(BuildContext context, PointRecord record, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: nama poin + poin
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${isApresiasi ? '+' : '-'}${record.poin}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  record.namaPoin,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Detail poin
          Text(
            record.detailPoin,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          // Jenis
          Row(
            children: [
              Icon(Icons.category_outlined, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                'Jenis: ${record.jenisPoin == 'prestasi' ? 'Apresiasi' : 'Pelanggaran'}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Guru pemberi poin
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                'Diberikan oleh: ${record.namaGuru}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Tanggal + jam
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                '${record.tanggal} • ${record.jam}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
