import 'package:flutter/material.dart';

/// Linear progress bar showing `used / total` for a metered resource
/// (messages, tokens, storage, etc.) with optional reset hint underneath.
///
/// Turns red when usage exceeds 80% of the total. Theme-driven and
/// host-agnostic.
class SaiaUsageBar extends StatelessWidget {
  final String label;
  final int used;
  final int total;
  final String? resetText;

  const SaiaUsageBar({
    super.key,
    required this.label,
    required this.used,
    required this.total,
    this.resetText,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final remaining = total - used;
    final fraction = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    final isHigh = fraction > 0.8;

    final barColor = isHigh ? scheme.error : scheme.primary;
    final trackColor = scheme.surfaceContainerHighest;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$remaining / $total',
                style: TextStyle(
                  color: isHigh ? scheme.error : scheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          if (resetText != null) ...[
            const SizedBox(height: 4),
            Text(
              resetText!,
              style: TextStyle(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
