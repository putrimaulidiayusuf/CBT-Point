import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/siswa_view_model.dart';
import '../widgets/custom_header.dart';
import '../widgets/point_card.dart';
import '../widgets/discipline_indicator.dart';
import '../login_view.dart';
import 'qr_fullscreen_dialog.dart';
import 'riwayat_poin_siswa_view.dart';
import 'daftar_poin_siswa_view.dart';

/// Halaman utama siswa (Dashboard)
/// Berisi: Header, Info Siswa (QR + Poin), Jenis Poin, Status Disiplin, Inbox

class SiswaDashboardView extends StatelessWidget {
  const SiswaDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final siswaVm = Provider.of<SiswaViewModel>(context);
    final siswa = authVm.currentSiswa;

    if (siswa == null) {
      return const Scaffold(body: Center(child: Text('Data siswa tidak ditemukan')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: Column(
        children: [
          // Header
          CustomHeader(
            nama: siswa.nama,
            detail1: siswa.kelas,
            detail2: 'NIS: ${siswa.nis}',
            backgroundColor: const Color(0xFF302B63),
            onLogout: () {
              authVm.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            },
          ),
          // Content
          Expanded(
            child: siswaVm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => siswaVm.refreshData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== SECTION INFORMASI SISWA =====
                          _buildSectionTitle('Informasi Siswa'),
                          const SizedBox(height: 12),
                          _buildInfoSection(context, siswa.nis, siswa.nama, siswaVm),
                          const SizedBox(height: 24),

                          // ===== SECTION JENIS POIN =====
                          _buildSectionTitle('Jenis Poin'),
                          const SizedBox(height: 12),
                          _buildJenisPoinSection(context, siswaVm),
                          const SizedBox(height: 24),

                          // ===== SECTION STATUS DISIPLIN =====
                          _buildSectionTitle('Status Disiplin'),
                          const SizedBox(height: 12),
                          DisciplineIndicator(
                            currentPoin: siswaVm.statusDisiplin,
                            label: siswaVm.labelDisiplin,
                            peringatan: siswaVm.peringatanDisiplin,
                            onTap: () => _showDisciplineDetails(context, siswaVm),
                          ),
                          const SizedBox(height: 24),

                          // ===== SECTION INBOX =====
                          _buildSectionTitle('Pesan Masuk'),
                          const SizedBox(height: 12),
                          _buildInboxSection(context, siswaVm),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A2E),
      ),
    );
  }

  /// Section informasi: QR Code + Total Apresiasi + Total Pelanggaran
  Widget _buildInfoSection(
      BuildContext context, String nis, String nama, SiswaViewModel vm) {
    return IntrinsicHeight(
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
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    QrImageView(
                      data: nis,
                      version: QrVersions.auto,
                      size: 100,
                      gapless: true,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF302B63),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF302B63),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'QR Code Siswa',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Tap untuk perbesar',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Poin (kanan)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: PointCard(
                    label: 'Poin Apresiasi',
                    totalPoin: vm.totalApresiasi,
                    icon: Icons.emoji_events,
                    color: const Color(0xFF4CAF50),
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
                const SizedBox(height: 12),
                Expanded(
                  child: PointCard(
                    label: 'Poin Pelanggaran',
                    totalPoin: vm.totalPelanggaran,
                    icon: Icons.warning_amber,
                    color: Colors.redAccent,
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

  /// Section jenis poin: daftar apresiasi dan pelanggaran dari JSON
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
                    themeColor: const Color(0xFF4CAF50),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.star_rounded, color: Color(0xFF4CAF50)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Poin Apresiasi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${vm.daftarApresiasi.length} item',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
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
                    themeColor: Colors.redAccent,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.gavel_rounded, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Poin Pelanggaran',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${vm.daftarPelanggaran.length} item',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
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
    final color = score >= 90
        ? const Color(0xFF4CAF50)
        : (score >= 75 ? Colors.teal : (score >= 50 ? Colors.amber.shade700 : (score >= 0 ? Colors.orange.shade800 : Colors.red.shade700)));

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Analisis Indeks Kedisiplinan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vm.labelDisiplin,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Indeks Kedisiplinan dihitung secara dinamis menggabungkan poin apresiasi (positif) dan poin pelanggaran (negatif) dari basis poin standar (100).',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              
              // Breakdown Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _breakdownRow('Skor Basis Standar', '+100', Colors.black87),
                    const Divider(height: 16),
                    _breakdownRow('Total Poin Apresiasi', '+${vm.totalApresiasi}', const Color(0xFF4CAF50)),
                    const Divider(height: 16),
                    _breakdownRow('Total Poin Pelanggaran', '-${vm.totalPelanggaran}', Colors.redAccent),
                    const Divider(height: 20, thickness: 1.5),
                    _breakdownRow('Net Indeks Kedisiplinan', '$score', color, isBold: true),
                  ],
                ),
              ),
              
              // Critical homeroom check
              if (score <= -100) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.gavel, color: Colors.redAccent, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PENTING: Batas Sanksi Tercapai (-100)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Indeks disiplin Anda telah mencapai nilai sanksi berat. Harap segera meminta keringanan/pembinaan ke Wali Kelas secara offline.',
                              style: TextStyle(fontSize: 12, color: Colors.red.shade900, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
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
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isBold ? 15 : 13,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  /// Section inbox / pesan masuk
  Widget _buildInboxSection(BuildContext context, SiswaViewModel vm) {
    if (vm.inbox.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              'Belum ada pesan masuk',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: vm.inbox.map((msg) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: msg.isRead
                  ? Colors.grey.withValues(alpha: 0.1)
                  : const Color(0xFF6C63FF).withValues(alpha: 0.3),
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
                      ),
                    ),
                  Expanded(
                    child: Text(
                      msg.judul,
                      style: TextStyle(
                        fontWeight: msg.isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                msg.isiPesan,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (msg.catatan != null && msg.catatan!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.note, size: 14, color: Colors.amber.shade700),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Catatan: ${msg.catatan}',
                          style: TextStyle(fontSize: 12, color: Colors.amber.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (msg.lampiran != null && msg.lampiran!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.attach_file, size: 14, color: Colors.blue.shade400),
                    const SizedBox(width: 4),
                    Text(
                      'Lampiran: ${msg.lampiran}',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade400),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    msg.pengirim,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    '${msg.tanggal} • ${msg.jam}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
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
