import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/guru_view_model.dart';
import 'guru_dashboard_view.dart';

/// Container Utama Guru (Dashboard)
class GuruMainView extends StatefulWidget {
  const GuruMainView({super.key});

  @override
  State<GuruMainView> createState() => _GuruMainViewState();
}

class _GuruMainViewState extends State<GuruMainView> {
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
          const GuruDashboardView(),
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
    );
  }
}
