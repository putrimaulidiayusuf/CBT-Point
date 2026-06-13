import 'package:flutter/material.dart';
import 'glass_container.dart';

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
    if (score >= 50) return const Color(0xFF10B981); // Emerald Green
    if (score > 0) return const Color(0xFF0EA5E9);  // Sky Cyan
    if (score == 0) return const Color(0xFFD97706); // Amber/Gold
    if (score > -50) return const Color(0xFFF97316); // Orange
    return const Color(0xFFF43F5E);                 // Rose Pink/Red
  }

  IconData _getIcon() {
    final score = currentPoin;
    if (score > 0) return Icons.verified_user_rounded;
    if (score == 0) return Icons.info_outline_rounded;
    return Icons.gpp_maybe_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final double progress = ((currentPoin + 100) / 200.0).clamp(0.0, 1.0);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getIcon(), color: color, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Indeks Kedisiplinan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E38),
                        ),
                      ),
                      Text(
                        'Gabungan Poin Real-time',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Glassy Progress Bar
            Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  height: 12,
                  width: (MediaQuery.of(context).size.width - 72) * progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.6),
                        color,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Skor Anda: $currentPoin Poin',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  'Batas Kritis: -100 Poin',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (onTap != null) ...[
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.analytics_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      'Ketuk untuk melihat detail grafik & sanksi',
                      style: TextStyle(
                        fontSize: 11, 
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Peringatan
            if (peringatan != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.2), width: 1.2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      currentPoin <= -100 ? Icons.gavel_rounded : Icons.report_problem_rounded,
                      color: color,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        peringatan!,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.bold,
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
