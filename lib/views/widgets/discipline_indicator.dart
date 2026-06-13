import 'package:flutter/material.dart';

/// Widget reusable untuk indikator status disiplin siswa
/// Menampilkan progress bar dan peringatan jika diperlukan
/// Mendukung tap/click untuk melihat rincian detail

class DisciplineIndicator extends StatelessWidget {
  final int currentPoin;
  final int maxPoin;
  final String label;
  final String? peringatan;
  final VoidCallback? onTap;

  const DisciplineIndicator({
    super.key,
    required this.currentPoin,
    this.maxPoin = 100,
    required this.label,
    this.peringatan,
    this.onTap,
  });

  Color _getColor() {
    final score = currentPoin;
    if (score >= 90) return const Color(0xFF4CAF50); // Hijau Sangat Baik
    if (score >= 75) return Colors.teal;             // Teal Baik
    if (score >= 50) return Colors.amber.shade700;   // Amber Cukup
    if (score >= 0) return Colors.orange.shade800;   // Orange Kurang
    return Colors.red.shade700;                     // Merah Peringatan / Kritis
  }

  IconData _getIcon() {
    final score = currentPoin;
    if (score >= 75) return Icons.check_circle_outline;
    if (score >= 50) return Icons.info_outline;
    if (score >= 0) return Icons.warning_amber;
    return Icons.dangerous_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    // Progress bar mewakili nilai 0 - 100+
    final double progress = (currentPoin / 100.0).clamp(0.0, 1.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getIcon(), color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Status Disiplin (Poin Gabungan)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
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
            // Progress bar
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  height: 10,
                  width: (MediaQuery.of(context).size.width - 64) * progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.6), color],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Skor Indeks: $currentPoin',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}% Ketertiban',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (onTap != null) ...[
              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      'Tap untuk analisis detail',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            ],
            // Peringatan
            if (peringatan != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      currentPoin <= -100 ? Icons.error : Icons.warning_amber,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        peringatan!,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
