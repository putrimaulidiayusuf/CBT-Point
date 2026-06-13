import 'package:flutter/material.dart';

/// Widget reusable untuk indikator status disiplin siswa
/// Menampilkan progress bar 0-100 dan peringatan jika diperlukan

class DisciplineIndicator extends StatelessWidget {
  final int currentPoin;
  final int maxPoin;
  final String label;
  final String? peringatan;

  const DisciplineIndicator({
    super.key,
    required this.currentPoin,
    this.maxPoin = 100,
    required this.label,
    this.peringatan,
  });

  Color _getColor() {
    final ratio = currentPoin / maxPoin;
    if (ratio >= 1.0) return Colors.red.shade700;
    if (ratio >= 0.75) return Colors.orange.shade700;
    if (ratio >= 0.5) return Colors.amber.shade700;
    if (ratio >= 0.25) return Colors.yellow.shade700;
    return const Color(0xFF4CAF50);
  }

  IconData _getIcon() {
    final ratio = currentPoin / maxPoin;
    if (ratio >= 1.0) return Icons.dangerous;
    if (ratio >= 0.75) return Icons.warning_amber;
    if (ratio >= 0.5) return Icons.info_outline;
    return Icons.check_circle_outline;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final progress = (currentPoin / maxPoin).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              Text(
                'Status Disiplin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
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
                height: 12,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: 12,
                width: MediaQuery.of(context).size.width * progress * 0.75,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.7), color],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentPoin / $maxPoin',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
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
                  Icon(Icons.warning_amber, color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      peringatan!,
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.w500,
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
    );
  }
}
