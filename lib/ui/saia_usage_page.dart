import 'package:flutter/material.dart';
import 'package:sint/sint.dart';

import 'widgets/saia_setting_header.dart';
import 'widgets/saia_usage_bar.dart';

/// A single metered quota row for [SaiaUsagePage].
///
/// `used` and `total` drive the bar fill; when `used >= 0.8 * total`
/// the bar turns red automatically. `resetText` is shown underneath
/// (e.g. "Resets in 2h 15m").
class SaiaQuotaSpec {
  final String label;
  final int used;
  final int total;
  final String? resetText;

  const SaiaQuotaSpec({
    required this.label,
    required this.used,
    required this.total,
    this.resetText,
  });
}

/// Agnostic usage page — renders a tier badge plus a list of quota bars.
///
/// Each host declares its own quota structure (Itzli has chat / docs /
/// images / pdfs / audio quotas; another app might have followers,
/// storage, API calls, etc.) and passes them as a list. Theme-driven.
///
/// Example usage from a host wrapper:
///
/// ```dart
/// SaiaUsagePage(
///   title: 'Uso',
///   tierLabel: 'Plan: Cuarzo',
///   quotasHeader: 'Cuotas',
///   quotas: [
///     SaiaQuotaSpec(
///       label: 'Mensajes / 3h',
///       used: limits.chatPer3Hours - usage.remainingChat,
///       total: limits.chatPer3Hours,
///       resetText: 'Resetea en ${formatDuration(usage.timeUntilChatRefill)}',
///     ),
///     // ... more quotas
///   ],
/// )
/// ```
class SaiaUsagePage extends StatelessWidget {
  /// AppBar title. Defaults to `settingsUsage.tr`.
  final String? title;

  /// Tier badge text shown at the top (e.g. "Plan: Cuarzo").
  final String tierLabel;

  /// Optional icon for the tier badge. Defaults to `Icons.diamond_outlined`.
  final IconData tierIcon;

  /// Header copy for the quotas list. Defaults to `settingsUsageQuotas.tr`.
  final String? quotasHeader;

  /// The list of quotas to render in order.
  final List<SaiaQuotaSpec> quotas;

  const SaiaUsagePage({
    super.key,
    required this.tierLabel,
    required this.quotas,
    this.title,
    this.tierIcon = Icons.diamond_outlined,
    this.quotasHeader,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.onSurface),
          onPressed: () => Sint.back(),
        ),
        title: Text(
          title ?? 'settingsUsage'.tr,
          style: TextStyle(
            color: scheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            children: [
              // ─── Tier badge ───
              Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(tierIcon, color: scheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      tierLabel,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              SaiaSettingHeader(
                title: quotasHeader ?? 'settingsUsageQuotas'.tr,
              ),

              for (final q in quotas)
                SaiaUsageBar(
                  label: q.label,
                  used: q.used,
                  total: q.total,
                  resetText: q.resetText,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
