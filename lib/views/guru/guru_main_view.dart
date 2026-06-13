import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/guru_view_model.dart';
import 'guru_dashboard_view.dart';
import 'guru_riwayat_view.dart';
import 'guru_draft_view.dart';
import 'guru_scan_qr_view.dart';

/// Container Utama Guru (dengan BottomNavigationBar)
/// Berisi 4 tab: Dashboard, Riwayat, Draft, dan Scan QR
class GuruMainView extends StatefulWidget {
  const GuruMainView({super.key});

  @override
  State<GuruMainView> createState() => _GuruMainViewState();
}

class _GuruMainViewState extends State<GuruMainView> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    GuruDashboardView(),
    GuruRiwayatView(),
    GuruDraftView(),
    GuruScanQrView(),
  ];

  @override
  void initState() {
    super.initState();
    // Inisialisasi data GuruViewModel ketika pertama kali masuk halaman utama guru
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = Provider.of<AuthViewModel>(context, listen: false);
      final guruVm = Provider.of<GuruViewModel>(context, listen: false);
      final guru = authVm.currentGuru;
      if (guru != null) {
        guruVm.initGuru(guru.nama);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final guruVm = Provider.of<GuruViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
          if (guruVm.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF302B63)),
                        SizedBox(height: 16),
                        Text(
                          'Memproses data...',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF302B63),
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Draft',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: 'Scan QR',
          ),
        ],
      ),
    );
  }
}
