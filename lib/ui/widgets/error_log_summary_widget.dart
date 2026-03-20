import 'package:flutter/material.dart';
import 'package:neom_core/utils/constants/app_route_constants.dart';
import 'package:sint/sint.dart';

import '../../utils/constants/setting_translation_constants.dart';
import '../settings_controller.dart';

/// Inline error log summary for the Admin Center section.
///
/// Shows a compact list of modules with error counts and priority indicators.
/// Tapping "Ver todos" navigates to the full Error Monitor page.
class ErrorLogSummaryWidget extends StatelessWidget {

  final SettingsController controller;

  const ErrorLogSummaryWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final entries = controller.errorLogSummary;
      final isLoading = controller.isErrorLogLoading.value;

      if (entries.isEmpty && !isLoading) {
        // Auto-load on first view
        controller.loadErrorLogSummary();
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Cargando...', style: TextStyle(color: Colors.white38, fontSize: 12)),
        );
      }

      if (isLoading && entries.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }

      if (entries.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 16, color: Colors.green.shade300),
              const SizedBox(width: 8),
              Text(
                SettingTranslationConstants.noErrorsDetected,
                style: TextStyle(color: Colors.green.shade300, fontSize: 12),
              ),
            ],
          ),
        );
      }

      final totalErrors = controller.totalErrorCount;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with total
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.monitor_heart_outlined, size: 16, color: Colors.red.shade300),
                const SizedBox(width: 8),
                Text(
                  SettingTranslationConstants.errorLogSummaryTitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _totalColor(totalErrors).withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$totalErrors',
                    style: TextStyle(
                      color: _totalColor(totalErrors),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Module rows (top 8)
          ...entries.take(8).map((entry) => _buildModuleRow(entry)),
          // "View all" link
          if (entries.length > 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: GestureDetector(
                onTap: () => Sint.toNamed(AppRouteConstants.errorMonitor),
                child: Text(
                  SettingTranslationConstants.viewFullMonitor,
                  style: TextStyle(
                    color: Colors.amber.shade300,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.amber.shade300,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
        ],
      );
    });
  }

  Widget _buildModuleRow(Map<String, dynamic> entry) {
    final module = entry['module']?.toString() ?? '';
    final displayName = module.startsWith('neom_') ? module.substring(5) : module;
    final totalErrors = (entry['totalErrors'] as int?) ?? 0;
    final ops = entry['operations'] as Map<String, dynamic>? ?? {};
    final topOp = ops.isNotEmpty
        ? (ops.entries.toList()..sort((a, b) => (b.value as int).compareTo(a.value as int))).first
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Row(
        children: [
          _priorityDot(totalErrors),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              displayName,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Container(
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: _barFraction(totalErrors),
                  backgroundColor: Colors.white.withAlpha(12),
                  valueColor: AlwaysStoppedAnimation<Color>(_barColor(totalErrors)),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              '$totalErrors',
              style: TextStyle(
                color: _barColor(totalErrors),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          if (topOp != null) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: Text(
                topOp.key,
                style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _priorityDot(int count) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _barColor(count),
      ),
    );
  }

  double _barFraction(int count) {
    final max = controller.errorLogSummary.isNotEmpty
        ? ((controller.errorLogSummary.first['totalErrors'] as int?) ?? 1)
        : 1;
    if (max <= 0) return 0;
    return (count / max).clamp(0.0, 1.0);
  }

  Color _barColor(int count) {
    if (count >= 100) return Colors.red;
    if (count >= 30) return Colors.orange;
    if (count >= 10) return Colors.amber;
    return Colors.green;
  }

  Color _totalColor(int total) {
    if (total >= 500) return Colors.red;
    if (total >= 100) return Colors.orange;
    if (total >= 20) return Colors.amber;
    return Colors.green;
  }
}
