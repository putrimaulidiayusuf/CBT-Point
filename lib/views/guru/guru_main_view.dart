import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/guru_view_model.dart';
import '../widgets/glass_container.dart';
import 'guru_dashboard_view.dart';

class GuruMainView extends StatefulWidget {
  const GuruMainView({super.key});

  @override
  State<GuruMainView> createState() => _GuruMainViewState();
}

class _GuruMainViewState extends State<GuruMainView> {
  @override
  void initState() {
    super.initState();
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
      backgroundColor: const Color(0xFFF4F6FC),
      body: Stack(
        children: [
          const GuruDashboardView(),
          if (guruVm.isLoading)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withValues(alpha: 0.15),
                child: Center(
                  child: GlassContainer(
                    width: 220,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                          strokeWidth: 3.5,
                        ),
                        SizedBox(height: 18),
                        Text(
                          'Memproses data...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 14,
                            color: Color(0xFF1E1E38),
                            letterSpacing: 0.5,
                          ),
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
