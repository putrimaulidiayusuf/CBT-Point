import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/point_record_model.dart';
import '../widgets/glass_container.dart';

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
    final color = isApresiasi ? const Color(0xFF00FF87) : const Color(0xFFFF2E93);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AppBar(
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              backgroundColor: const Color(0xFF0F0C29).withValues(alpha: 0.7),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: 100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C63FF).withValues(alpha: 0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Main list
          SafeArea(
            child: records.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isApresiasi ? Icons.emoji_events_outlined : Icons.warning_amber_outlined,
                            size: 56,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Belum ada riwayat ${isApresiasi ? 'apresiasi' : 'pelanggaran'}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return _buildRecordCard(context, record, color);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, PointRecord record, Color color) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      color: Colors.white.withValues(alpha: 0.03),
      borderColor: Colors.white.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: nama poin + poin
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Text(
                  '${isApresiasi ? '+' : '-'}${record.poin}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  record.namaPoin,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Detail poin
          Text(
            record.detailPoin,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
          const SizedBox(height: 10),
          // Metadata rows
          _buildMetaRow(Icons.category_rounded, 'Jenis: ${record.jenisPoin == 'prestasi' ? 'Apresiasi' : 'Pelanggaran'}'),
          const SizedBox(height: 4),
          _buildMetaRow(Icons.account_box_rounded, 'Diberikan oleh: ${record.namaGuru}'),
          const SizedBox(height: 4),
          _buildMetaRow(Icons.schedule_rounded, '${record.tanggal}  •  ${record.jam}'),
        ],
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.45)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12, 
              color: Colors.white.withValues(alpha: 0.45),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
