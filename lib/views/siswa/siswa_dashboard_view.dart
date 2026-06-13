import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/siswa_view_model.dart';
import '../../models/jenis_catatan_model.dart';
import '../widgets/custom_header.dart';
import '../widgets/point_card.dart';
import '../widgets/discipline_indicator.dart';
import '../login_view.dart';
import 'qr_fullscreen_dialog.dart';
import 'riwayat_poin_siswa_view.dart';

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                children: [
                  QrImageView(
                    data: nis,
                    version: QrVersions.auto,
                    size: 120,
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
        // Poin (kanan atas + kanan bawah)
        Expanded(
          flex: 2,
          child: Column(
            children: [
              PointCard(
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
              const SizedBox(height: 12),
              PointCard(
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
            ],
          ),
        ),
      ],
    );
  }

  /// Section jenis poin: daftar apresiasi dan pelanggaran dari JSON
  Widget _buildJenisPoinSection(BuildContext context, SiswaViewModel vm) {
    return Column(
      children: [
        // Daftar Apresiasi
        _buildJenisPoinCard(
          context: context,
          title: 'Daftar Apresiasi',
          icon: Icons.star,
          color: const Color(0xFF4CAF50),
          items: vm.daftarApresiasi,
        ),
        const SizedBox(height: 12),
        // Daftar Pelanggaran
        _buildJenisPoinCard(
          context: context,
          title: 'Daftar Pelanggaran',
          icon: Icons.gavel,
          color: Colors.redAccent,
          items: vm.daftarPelanggaran,
        ),
      ],
    );
  }

  Widget _buildJenisPoinCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<JenisCatatan> items,
  }) {
    return Container(
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
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          '${items.length} item',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        children: items.map((item) {
          return ListTile(
            onTap: () => _showDetailPoin(context, item, color),
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Text(
                '${item.poin}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(item.nama, style: const TextStyle(fontSize: 14)),
            subtitle: Text(
              item.deskripsi,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
          );
        }).toList(),
      ),
    );
  }

  void _showDetailPoin(BuildContext context, JenisCatatan item, Color color) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Text(
                '${item.poin}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(item.nama, style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Nama', item.nama),
            _detailRow('Detail', item.deskripsi),
            _detailRow('Jenis', item.tipe == 'prestasi' ? 'Apresiasi' : 'Pelanggaran'),
            _detailRow('Poin', item.poin.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
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
