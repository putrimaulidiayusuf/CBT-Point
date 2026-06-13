import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/siswa_view_model.dart';
import '../widgets/custom_header.dart';
import '../widgets/point_card.dart';
import '../widgets/discipline_indicator.dart';
import '../widgets/glass_container.dart';
import '../login_view.dart';
import 'qr_fullscreen_dialog.dart';
import 'riwayat_poin_siswa_view.dart';
import 'daftar_poin_siswa_view.dart';

class SiswaDashboardView extends StatelessWidget {
  const SiswaDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final siswaVm = Provider.of<SiswaViewModel>(context);
    final siswa = authVm.currentSiswa;
    final size = MediaQuery.of(context).size;

    if (siswa == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F6FC),
        body: Center(
          child: Text(
            'Data siswa tidak ditemukan',
            style: TextStyle(color: Color(0xFF1E1E38), fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      body: Stack(
        children: [
          // 1. Soft Pastel Glowing Background blobs
          Positioned(
            top: 40,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
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
          Positioned(
            bottom: 100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF2E93).withValues(alpha: 0.04),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // 2. Main content
          Column(
            children: [
              CustomHeader(
                nama: siswa.nama,
                detail1: '${siswa.nis} | ${siswa.kelas}',
                backgroundColor: const Color(0xFFF4F6FC),
                onLogout: () {
                  authVm.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginView()),
                  );
                },
              ),
              Expanded(
                child: siswaVm.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF6C63FF),
                        backgroundColor: Colors.white,
                        onRefresh: () => siswaVm.refreshData(),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ===== SECTION INFORMASI SISWA =====
                              _buildSectionTitle('Informasi QR & Poin'),
                              const SizedBox(height: 14),
                              _buildInfoSection(context, siswa.nis, siswa.nama, siswaVm),
                              const SizedBox(height: 26),

                              // ===== SECTION JENIS POIN =====
                              _buildSectionTitle('Kategori Poin'),
                              const SizedBox(height: 14),
                              _buildJenisPoinSection(context, siswaVm),
                              const SizedBox(height: 26),

                              // ===== SECTION STATUS DISIPLIN =====
                              _buildSectionTitle('Status Disiplin'),
                              const SizedBox(height: 14),
                              DisciplineIndicator(
                                currentPoin: siswaVm.statusDisiplin,
                                label: siswaVm.labelDisiplin,
                                peringatan: siswaVm.peringatanDisiplin,
                                onTap: () => _showDisciplineDetails(context, siswaVm),
                              ),
                              const SizedBox(height: 26),

                              // ===== SECTION INBOX =====
                              _buildSectionTitle('Kotak Masuk (Surat Peringatan/Apresiasi)'),
                              const SizedBox(height: 14),
                              _buildInboxSection(context, siswaVm),
                              const SizedBox(height: 36),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFFF2E93)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E38),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
      BuildContext context, String nis, String nama, SiswaViewModel vm) {
    return SizedBox(
      height: 260,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // QR Code (kiri)
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => QrFullscreenDialog(nis: nis, namaSiswa: nama),
                );
              },
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: nis,
                        version: QrVersions.auto,
                        size: 96,
                        gapless: true,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF1E1E38),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF1E1E38),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'QR Code Siswa',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1E1E38),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ketuk untuk perbesar',
                      style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xFF1E1E38).withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Poin (kanan)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: PointCard(
                    label: 'Total Apresiasi',
                    totalPoin: vm.totalApresiasi,
                    icon: Icons.emoji_events_rounded,
                    color: const Color(0xFF10B981), // Light Emerald Green
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RiwayatPoinSiswaView(
                            title: 'Riwayat Apresiasi',
                            records: vm.riwayatApresiasi,
                            isApresiasi: true,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: PointCard(
                    label: 'Total Pelanggaran',
                    totalPoin: vm.totalPelanggaran,
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFF43F5E), // Light Rose Pink
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RiwayatPoinSiswaView(
                            title: 'Riwayat Pelanggaran',
                            records: vm.riwayatPelanggaran,
                            isApresiasi: false,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJenisPoinSection(BuildContext context, SiswaViewModel vm) {
    return Row(
      children: [
        // Button Apresiasi
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DaftarPoinSiswaView(
                    title: 'Daftar Apresiasi',
                    items: vm.daftarApresiasi,
                    themeColor: const Color(0xFF10B981),
                  ),
                ),
              );
            },
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
              color: const Color(0xFF10B981).withValues(alpha: 0.06),
              borderColor: const Color(0xFF10B981).withValues(alpha: 0.2),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded, color: Color(0xFF10B981), size: 24),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Poin Apresiasi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E38)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vm.daftarApresiasi.length} item terdaftar',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Button Pelanggaran
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DaftarPoinSiswaView(
                    title: 'Daftar Pelanggaran',
                    items: vm.daftarPelanggaran,
                    themeColor: const Color(0xFFF43F5E),
                  ),
                ),
              );
            },
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
              color: const Color(0xFFF43F5E).withValues(alpha: 0.06),
              borderColor: const Color(0xFFF43F5E).withValues(alpha: 0.2),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.gavel_rounded, color: Color(0xFFF43F5E), size: 24),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Poin Pelanggaran',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E38)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vm.daftarPelanggaran.length} item terdaftar',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDisciplineDetails(BuildContext context, SiswaViewModel vm) {
    final score = vm.statusDisiplin;
    final color = score >= 50
        ? const Color(0xFF10B981)
        : (score > 0 ? const Color(0xFF0EA5E9) : (score == 0 ? const Color(0xFFD97706) : (score > -50 ? const Color(0xFFF97316) : const Color(0xFFF43F5E))));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: const Border(
                top: BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Analisis Indeks Kedisiplinan',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E1E38)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        vm.labelDisiplin,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Indeks Kedisiplinan dihitung murni dari selisih total poin apresiasi (positif) dan poin pelanggaran (negatif) dengan nilai awal default 0.',
                  style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                ),
                const SizedBox(height: 24),
                
                // Breakdown Box
                GlassContainer(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _breakdownRow('Skor Basis Standar', '0', Colors.black54),
                      const SizedBox(height: 12),
                      Container(height: 1, color: Colors.grey.shade200),
                      const SizedBox(height: 12),
                      _breakdownRow('Total Poin Apresiasi', '+${vm.totalApresiasi}', const Color(0xFF10B981)),
                      const SizedBox(height: 12),
                      Container(height: 1, color: Colors.grey.shade200),
                      const SizedBox(height: 12),
                      _breakdownRow('Total Poin Pelanggaran', '-${vm.totalPelanggaran}', const Color(0xFFF43F5E)),
                      const SizedBox(height: 16),
                      Container(height: 1.5, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      _breakdownRow('Net Indeks Kedisiplinan', '$score', color, isBold: true),
                    ],
                  ),
                ),
                
                // Critical homeroom check
                if (score <= -100) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF43F5E).withValues(alpha: 0.25), width: 1.2),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.gavel_rounded, color: Color(0xFFF43F5E), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PENTING: Batas Sanksi Tercapai (-100)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF43F5E)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Indeks disiplin Anda telah mencapai nilai sanksi berat. Harap segera meminta keringanan/pembinaan ke Wali Kelas secara offline.',
                                style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _breakdownRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
            color: const Color(0xFF1E1E38),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isBold ? 16 : 13,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInboxSection(BuildContext context, SiswaViewModel vm) {
    if (vm.inbox.isEmpty) {
      return GlassContainer(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Belum ada surat/pesan masuk',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Column(
      children: vm.inbox.map((msg) {
        return GlassContainer(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          color: msg.isRead 
              ? Colors.white.withValues(alpha: 0.5) 
              : const Color(0xFF6C63FF).withValues(alpha: 0.05),
          borderColor: msg.isRead 
              ? Colors.white.withValues(alpha: 0.7) 
              : const Color(0xFF6C63FF).withValues(alpha: 0.25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!msg.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF6C63FF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF6C63FF),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Text(
                      msg.judul,
                      style: TextStyle(
                        fontWeight: msg.isRead ? FontWeight.w600 : FontWeight.bold,
                        fontSize: 15,
                        color: const Color(0xFF1E1E38),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                msg.isiPesan,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (msg.catatan != null && msg.catatan!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.note_alt_rounded, size: 16, color: Color(0xFFD97706)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Catatan: ${msg.catatan}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (msg.lampiran != null && msg.lampiran!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file_rounded, size: 16, color: Color(0xFF0EA5E9)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Lampiran: ${msg.lampiran}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Container(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.person_pin_rounded, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    msg.pengirim,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today_rounded, size: 13, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    '${msg.tanggal} • ${msg.jam}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
