import 'package:flutter/material.dart';

/// Widget reusable untuk kotak poin (apresiasi/pelanggaran)
/// Menampilkan label dan total poin dengan styling berbeda per jenis

class PointCard extends StatelessWidget {
  final String label;
  final int totalPoin;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const PointCard({
    super.key,
    required this.label,
    required this.totalPoin,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              totalPoin.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            if (onTap != null) ...[
              const SizedBox(height: 4),
              Text(
                'Tap untuk lihat detail',
                style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
