import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/guru_view_model.dart';
import '../widgets/custom_header.dart';
import '../widgets/glass_container.dart';
import '../login_view.dart';
import 'guru_scan_qr_view.dart';
import 'guru_draft_view.dart';
import 'guru_riwayat_view.dart';
import 'guru_daftar_poin_view.dart';

class GuruDashboardView extends StatefulWidget {
  const GuruDashboardView({super.key});

  @override
  State<GuruDashboardView> createState() => _GuruDashboardViewState();
}

class _GuruDashboardViewState extends State<GuruDashboardView> {
  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final guruVm = Provider.of<GuruViewModel>(context);
    final guru = authVm.currentGuru;

    if (guru == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0C29),
        body: Center(
          child: Text(
            'Data guru tidak ditemukan',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      body: Stack(
        children: [
          // 1. Glowing Neon Background Circles
          Positioned(
            top: 60,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF2E93).withValues(alpha: 0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 75, sigmaY: 75),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // 2. Main content Column
Container(
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0F0C29),
        Color(0xFF1B1A3A),
        Color(0xFF0F0C29),
      ],
    ),
  ),
  child: Column(
    children: [
      CustomHeader(
        nama: guru.nama,
        detail1: '${guru.nip} | Akun Guru',
        backgroundColor: const Color(0xFF0F0C29),
        onLogout: () {
  authVm.logout();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const LoginView()),
  );
},
      ),

      Expanded(
        child: RefreshIndicator(
          color: const Color(0xFF6C63FF),
          backgroundColor: const Color(0xFF1E1B3A),
          onRefresh: () => guruVm.refreshData(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _buildSectionTitle('Layanan & Fitur Utama'),
              const SizedBox(height: 16),
              _buildMenuLayout(context, guruVm),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    ],
  ),
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
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuLayout(BuildContext context, GuruViewModel vm) {
    return Column(
      children: [
        // Row 1: QR Scan (Left) & Point categories (Right)
        SizedBox(
          height: 260,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: Scan QR Code
              Expanded(
                flex: 2,
                child: _buildLargeMenuCard(
                  context: context,
                  title: 'Scan QR Siswa',
                  description: 'Pindai instan kartu siswa untuk memberikan poin secara cepat',
                  icon: Icons.qr_code_scanner_rounded,
                  color: const Color(0xFF6C63FF),
                  destination: const GuruScanQrView(),
                ),
              ),
              const SizedBox(width: 14),
              // Right: Apresiasi & Pelanggaran
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildPointMenuCard(
                        context: context,
                        title: 'Kategori Apresiasi',
                        subtitle: '${vm.daftarApresiasi.length} item',
                        icon: Icons.emoji_events_rounded,
                        color: const Color(0xFF00FF87), // Neon green
                        destination: GuruDaftarPoinView(
                          title: 'Daftar Apresiasi',
                          items: vm.daftarApresiasi,
                          themeColor: const Color(0xFF00FF87),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: _buildPointMenuCard(
                        context: context,
                        title: 'Kategori Pelanggaran',
                        subtitle: '${vm.daftarPelanggaran.length} item',
                        icon: Icons.warning_amber_rounded,
                        color: const Color(0xFFFF2E93), // Neon pink
                        destination: GuruDaftarPoinView(
                          title: 'Daftar Pelanggaran',
                          items: vm.daftarPelanggaran,
                          themeColor: const Color(0xFFFF2E93),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Row 2: Riwayat Poin
        _buildFullWidthMenuCard(
          context: context,
          title: 'Riwayat Pemberian Poin',
          subtitle: '${vm.riwayatPoin.length} riwayat poin siswa telah dicatat',
          icon: Icons.history_toggle_off_rounded,
          color: const Color(0xFF00F2FE), // Neon cyan
          destination: const GuruRiwayatView(),
        ),
        const SizedBox(height: 16),

        // Row 3: Kelola Draf & Kirim Surat
        Row(
          children: [
            Expanded(
              child: _buildSmallMenuCard(
                context: context,
                title: 'Kelola Draf',
                subtitle: '${vm.drafts.length} Tersimpan',
                icon: Icons.drafts_rounded,
                color: const Color(0xFFA855F7), // Neon purple
                destination: const GuruDraftView(initialTab: 0),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildSmallMenuCard(
                context: context,
                title: 'Kirim Pesan/Surat',
                subtitle: 'Kirim Peringatan',
                icon: Icons.mark_as_unread_rounded,
                color: const Color(0xFFFF5252), // Light red
                destination: const GuruDraftView(initialTab: 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPointMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        color: color.withValues(alpha: 0.05),
        borderColor: color.withValues(alpha: 0.15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.45), fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(18),
        color: color.withValues(alpha: 0.08),
        borderColor: color.withValues(alpha: 0.25),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 36),
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
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.5),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        color: color.withValues(alpha: 0.05),
        borderColor: color.withValues(alpha: 0.15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.45), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white.withValues(alpha: 0.35)),
          ],
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
      child: GlassContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: color.withValues(alpha: 0.05),
        borderColor: color.withValues(alpha: 0.15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.45)),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white.withValues(alpha: 0.35)),
          ],
        ),
      ),
    );
  }
}
