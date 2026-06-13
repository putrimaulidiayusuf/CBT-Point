import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/guru_view_model.dart';
import '../../models/jenis_catatan_model.dart';
import '../widgets/custom_header.dart';
import '../widgets/search_field.dart';
import '../login_view.dart';
import 'tambah_penerima_view.dart';
import 'guru_scan_qr_view.dart';
import 'guru_draft_view.dart';
import 'guru_riwayat_view.dart';

/// Halaman utama Guru (Dashboard)
/// Menampilkan: Header (NIP | Kelas/Role), Menu Utama Sejajar (Scan QR vs Riwayat/Draf), 
/// Menu Surat di bawahnya, dan shortcut pemberian poin cepat.
class GuruDashboardView extends StatefulWidget {
  const GuruDashboardView({super.key});

  @override
  State<GuruDashboardView> createState() => _GuruDashboardViewState();
}

class _GuruDashboardViewState extends State<GuruDashboardView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final guruVm = Provider.of<GuruViewModel>(context);
    final guru = authVm.currentGuru;

    if (guru == null) {
      return const Scaffold(body: Center(child: Text('Data guru tidak ditemukan')));
    }

    // Filter list berdasarkan search query
    final filteredApresiasi = guruVm.daftarApresiasi.where((item) {
      final query = _searchQuery.toLowerCase();
      return item.nama.toLowerCase().contains(query) ||
          item.deskripsi.toLowerCase().contains(query) ||
          item.poin.toString().contains(query);
    }).toList();

    final filteredPelanggaran = guruVm.daftarPelanggaran.where((item) {
      final query = _searchQuery.toLowerCase();
      return item.nama.toLowerCase().contains(query) ||
          item.deskripsi.toLowerCase().contains(query) ||
          item.poin.toString().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: Column(
        children: [
          // Header Guru (Request #1 & #5)
          CustomHeader(
            nama: guru.nama,
            detail1: '${guru.nip} | Guru',
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
            child: guruVm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => guruVm.refreshData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== MENU NAVIGASI GURU (Request #5) =====
                          _buildSectionTitle('Menu Utama'),
                          const SizedBox(height: 12),
                          _buildMenuLayout(context, guruVm),
                          const SizedBox(height: 24),

                          // ===== SECTION JENIS POIN =====
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionTitle('Pemberian Poin Cepat'),
                              if (_searchQuery.isNotEmpty)
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  child: const Text('Reset', style: TextStyle(fontSize: 12)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Search Bar
                          SearchField(
                            controller: _searchController,
                            hintText: 'Cari jenis poin...',
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                          ),
                          const SizedBox(height: 20),

                          // Section Apresiasi
                          _buildSubSectionTitle('Daftar Apresiasi (Poin Positif)'),
                          const SizedBox(height: 8),
                          if (filteredApresiasi.isEmpty)
                            _buildEmptyState('Apresiasi tidak ditemukan')
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredApresiasi.length,
                              itemBuilder: (context, index) {
                                return _buildPoinTile(
                                  context: context,
                                  item: filteredApresiasi[index],
                                  color: const Color(0xFF4CAF50),
                                );
                              },
                            ),
                          const SizedBox(height: 20),

                          // Section Pelanggaran
                          _buildSubSectionTitle('Daftar Pelanggaran (Poin Negatif)'),
                          const SizedBox(height: 8),
                          if (filteredPelanggaran.isEmpty)
                            _buildEmptyState('Pelanggaran tidak ditemukan')
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredPelanggaran.length,
                              itemBuilder: (context, index) {
                                return _buildPoinTile(
                                  context: context,
                                  item: filteredPelanggaran[index],
                                  color: Colors.redAccent,
                                );
                              },
                            ),
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

  Widget _buildSubSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF302B63),
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        ),
      ),
    );
  }

  /// Menu layout terstruktur setinggi 200px sejajar (Siswa-like layout)
  Widget _buildMenuLayout(BuildContext context, GuruViewModel vm) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kiri: Scan QR Code (Large Card) - Request #5 & #6
              Expanded(
                flex: 2,
                child: _buildLargeMenuCard(
                  context: context,
                  title: 'Scan QR Siswa',
                  description: 'Pindai instan NIS siswa menggunakan kamera pemindai',
                  icon: Icons.qr_code_scanner_rounded,
                  color: const Color(0xFF302B63),
                  destination: const GuruScanQrView(),
                ),
              ),
              const SizedBox(width: 12),
              // Kanan: Column berisi Riwayat dan Draf - Request #5
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildSmallMenuCard(
                        context: context,
                        title: 'Riwayat Poin',
                        subtitle: '${vm.riwayatPoin.length} Riwayat Diberikan',
                        icon: Icons.history_rounded,
                        color: Colors.teal.shade700,
                        destination: const GuruRiwayatView(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildSmallMenuCard(
                        context: context,
                        title: 'Kelola Draf',
                        subtitle: '${vm.drafts.length} Draf Tersimpan',
                        icon: Icons.drafts_rounded,
                        color: const Color(0xFF6C63FF),
                        destination: const GuruDraftView(initialTab: 0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Bawah Riwayat & Draf: Kirim Surat/Pesan (Full Width Card) - Request #5
        _buildFullWidthMenuCard(
          context: context,
          title: 'Kirim Surat Peringatan / Pembinaan',
          subtitle: 'Kirim surat peringatan atau apresiasi langsung ke inbox siswa',
          icon: Icons.mail_outline_rounded,
          color: const Color(0xFFFF2E93),
          destination: const GuruDraftView(initialTab: 1),
        ),
      ],
    );
  }

  Widget _buildLargeMenuCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => destination),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing scan icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => destination),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A1A2E)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullWidthMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => destination),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: color.withValues(alpha: 0.7)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPoinTile({
    required BuildContext context,
    required JenisCatatan item,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: color.withValues(alpha: 0.1),
          child: Text(
            '+${item.poin}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        title: Text(
          item.nama,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF1A1A2E),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(
            item.deskripsi,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 13,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TambahPenerimaView(selectedPoin: item),
            ),
          );
        },
      ),
    );
  }
}
