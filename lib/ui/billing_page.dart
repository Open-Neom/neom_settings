import 'package:flutter/material.dart';
import 'package:neom_commons/app_flavour.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/ui/theme/app_theme.dart';
import 'package:neom_commons/ui/widgets/web_content_wrapper.dart';
import 'package:neom_core/app_config.dart';
import 'package:neom_core/data/firestore/subscription_event_firestore.dart';
import 'package:neom_core/domain/model/subscription_event.dart';
import 'package:neom_core/domain/use_cases/stripe_api_service.dart';
import 'package:neom_core/domain/use_cases/user_service.dart';
import 'package:neom_core/utils/neom_error_logger.dart';
import 'package:sint/sint.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/constants/setting_translation_constants.dart';

/// Standalone billing page showing subscription invoices and Stripe portal link.
class BillingPage extends StatefulWidget {
  const BillingPage({super.key});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  List<SubscriptionEvent>? _events;
  bool _loading = false;
  bool _portalLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      String subId = '';
      String customerId = '';
      if (Sint.isRegistered<UserService>()) {
        final user = Sint.find<UserService>().user;
        subId = user.subscriptionId;
        customerId = user.customerId;
      }

      List<SubscriptionEvent> events = [];

      // 1. Firestore events
      if (subId.isNotEmpty) {
        events = await SubscriptionEventFirestore().getBySubscriptionId(subId);
      }

      // 2. Fallback: Stripe invoices
      if (events.isEmpty && customerId.isNotEmpty && Sint.isRegistered<StripeApiService>()) {
        final invoices = await Sint.find<StripeApiService>().getInvoices(customerId: customerId, limit: 15);
        for (final inv in invoices) {
          final amount = ((inv['amount_paid'] ?? inv['total'] ?? 0) as num) / 100.0;
          final status = (inv['status'] ?? '').toString();
          final created = (inv['created'] as num?)?.toInt() ?? 0;
          events.add(SubscriptionEvent(
            id: (inv['id'] ?? '').toString(),
            subscriptionId: subId,
            stripeEventType: status == 'paid' ? 'invoice.payment_succeeded' : 'invoice.payment_failed',
            amount: amount,
            currency: (inv['currency'] ?? 'mxn').toString(),
            invoiceUrl: (inv['hosted_invoice_url'] ?? inv['invoice_pdf'] ?? '').toString(),
            createdAt: created * 1000,
          ));
        }
      }

      events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (mounted) setState(() { _events = events; _loading = false; });
    } catch (e, st) {
      NeomErrorLogger.recordError(e, st, module: 'neom_settings', operation: 'BillingPage._loadEvents');
      if (mounted) setState(() { _events = []; _loading = false; });
    }
  }

  Future<void> _openPortal() async {
    if (!Sint.isRegistered<StripeApiService>() || !Sint.isRegistered<UserService>()) return;
    final customerId = Sint.find<UserService>().user.customerId;
    if (customerId.isEmpty) return;

    setState(() => _portalLoading = true);
    try {
      final url = await Sint.find<StripeApiService>().createBillingPortalSession(customerId);
      if (url.isNotEmpty) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e, st) {
      NeomErrorLogger.recordError(e, st, module: 'neom_settings', operation: 'BillingPage._openPortal');
    } finally {
      if (mounted) setState(() => _portalLoading = false);
    }
  }

  String _formatDate(int ms) {
    if (ms <= 0) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  bool _isPaid(SubscriptionEvent e) =>
      e.stripeEventType.contains('succeeded') || e.emxiStatusColor == 'green';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SintAppBar(title: SettingTranslationConstants.billing.tr),
      backgroundColor: AppFlavour.getBackgroundColor(),
      body: WebContentWrapper(
        maxWidth: 700,
        padding: EdgeInsets.zero,
        child: Container(
          decoration: AppTheme.appBoxDecoration,
          padding: const EdgeInsets.all(16),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    // Portal button
                    ListTile(
                      leading: const Icon(Icons.open_in_new, color: AppColor.bondiBlue),
                      title: Text(SettingTranslationConstants.billing.tr),
                      subtitle: Text(
                        'Stripe Customer Portal',
                        style: TextStyle(color: Colors.white.withAlpha(120), fontSize: 12),
                      ),
                      trailing: _portalLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: _portalLoading ? null : _openPortal,
                    ),
                    const Divider(color: Colors.white12),

                    if (_events == null || _events!.where((e) => e.hasFinancialData).isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            SettingTranslationConstants.billing.tr,
                            style: TextStyle(color: Colors.white.withAlpha(100)),
                          ),
                        ),
                      )
                    else
                      ..._events!.where((e) => e.hasFinancialData).take(20).map((event) {
                        final paid = _isPaid(event);
                        return ListTile(
                          leading: Icon(
                            paid ? Icons.check_circle : Icons.error,
                            color: paid ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          title: Text(
                            '\$${event.amount.toStringAsFixed(2)} ${event.currency.toUpperCase()}',
                            style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
                          ),
                          subtitle: Text(
                            _formatDate(event.createdAt),
                            style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12),
                          ),
                          trailing: event.invoiceUrl.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.receipt_long, size: 18),
                                  onPressed: () => launchUrl(Uri.parse(event.invoiceUrl)),
                                  tooltip: SettingTranslationConstants.billingView.tr,
                                )
                              : Text(
                                  paid
                                      ? SettingTranslationConstants.billingPaid.tr
                                      : SettingTranslationConstants.billingFailed.tr,
                                  style: TextStyle(color: paid ? Colors.green : Colors.red, fontSize: 11),
                                ),
                        );
                      }),
                  ],
                ),
        ),
      ),
    );
  }
}
