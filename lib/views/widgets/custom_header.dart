import 'dart:ui';
import 'package:flutter/material.dart';
import 'glass_container.dart';

class CustomHeader extends StatelessWidget {
  final String nama;
  final String? detail1; // Kelas (siswa) atau NIP (guru)
  final String? detail2; // NIS (siswa) atau null (guru)
  final VoidCallback onLogout;
  final Color backgroundColor;

  const CustomHeader({
    super.key,
    required this.nama,
    this.detail1,
    this.detail2,
    required this.onLogout,
    this.backgroundColor = const Color(0xFFF4F6FC),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        borderRadius: 0, // Full width header
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        color: Colors.white.withValues(alpha: 0.65),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              // Profile icon dengan logout
              GestureDetector(
                onTap: () => _showLogoutDialog(context),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFFFF2E93)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.face_retouching_natural_rounded, // Futuristic icon
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const Spacer(),
              // Info user di kanan
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      color: Color(0xFF1E1E38),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (detail1 != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      detail1!,
                      style: TextStyle(
                        color: const Color(0xFF1E1E38).withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  if (detail2 != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      detail2!,
                      style: TextStyle(
                        color: const Color(0xFF1E1E38).withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2E93).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: Color(0xFFFF2E93), size: 22),
              ),
              const SizedBox(width: 10),
              const Text(
                'Keluar Aplikasi',
                style: TextStyle(color: Color(0xFF1E1E38), fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'Apakah kamu yakin ingin logout?',
            style: TextStyle(color: Colors.black87, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF2E93),
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: const Color(0xFFFF2E93).withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
