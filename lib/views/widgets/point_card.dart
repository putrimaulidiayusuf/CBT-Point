import 'package:flutter/material.dart';
import 'glass_container.dart';

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
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        color: color.withValues(alpha: 0.06),
        borderColor: color.withValues(alpha: 0.25),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              totalPoin.toString(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
                shadows: [
                  Shadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            if (onTap != null) ...[
              const SizedBox(height: 4),
              Text(
                'Lihat Detail',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
