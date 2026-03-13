import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:neom_commons/app_flavour.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/ui/widgets/appbar_child.dart';
import 'package:neom_commons/utils/constants/translations/app_translation_constants.dart';
import 'package:neom_core/domain/model/subscription_plan.dart';
import 'package:neom_core/domain/use_cases/subscription_service.dart';
import 'package:neom_core/utils/core_utilities.dart';
import 'package:neom_core/utils/enums/profile_type.dart';
import 'package:neom_core/utils/enums/subscription_level.dart';
import 'package:sint/sint.dart';

import '../utils/constants/setting_translation_constants.dart';

/// Web-optimized subscription plans page with card layout.
///
/// Shows all available plans in a responsive grid with pricing,
/// features, and CTA buttons instead of a cramped dialog.
class SubscriptionPlansPage extends StatelessWidget {
  const SubscriptionPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionService = Sint.find<SubscriptionService>();

    return Scaffold(
      appBar: AppBarChild(title: SettingTranslationConstants.choosePlan.tr),
      backgroundColor: AppFlavour.getBackgroundColor(),
      body: FutureBuilder(
        future: subscriptionService.subscriptionPlans.isEmpty
            ? subscriptionService.initializeSubscriptions()
            : Future.value(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return _SubscriptionPlansBody(subscriptionService: subscriptionService);
        },
      ),
    );
  }
}

class _SubscriptionPlansBody extends StatelessWidget {
  final SubscriptionService subscriptionService;

  const _SubscriptionPlansBody({required this.subscriptionService});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = kIsWeb || screenWidth > 900;
    final plans = subscriptionService.profilePlans.values.toList();

    if (plans.isEmpty) {
      return Center(
        child: Text(
          AppTranslationConstants.noResults.tr,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    // Find recommended plan (artist level or middle plan)
    final recommendedIndex = _getRecommendedIndex(plans);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 40 : 16,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Text(
            SettingTranslationConstants.choosePlan.tr,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            SettingTranslationConstants.monthlySubscription.tr,
            style: const TextStyle(fontSize: 16, color: Colors.white60),
          ),
          const SizedBox(height: 12),

          // Profile type selector
          _ProfileTypeSelector(subscriptionService: subscriptionService),

          const SizedBox(height: 32),

          // Plans grid
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isWide
                  ? Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: List.generate(plans.length, (i) {
                        return SizedBox(
                          width: _cardWidth(screenWidth, plans.length),
                          child: _PlanCard(
                            plan: plans[i],
                            isRecommended: i == recommendedIndex,
                            subscriptionService: subscriptionService,
                          ),
                        );
                      }),
                    )
                  : Column(
                      children: List.generate(plans.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _PlanCard(
                            plan: plans[i],
                            isRecommended: i == recommendedIndex,
                            subscriptionService: subscriptionService,
                          ),
                        );
                      }),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  double _cardWidth(double screenWidth, int planCount) {
    final available = (screenWidth - 80).clamp(300, 1200).toDouble();
    // Fit 3 cards per row on wide screens, 2 on medium
    if (available > 900) return (available / 3) - 16;
    if (available > 600) return (available / 2) - 16;
    return available;
  }

  int _getRecommendedIndex(List<SubscriptionPlan> plans) {
    // Recommend artist level, or the middle plan
    for (int i = 0; i < plans.length; i++) {
      if (plans[i].level == SubscriptionLevel.artist) return i;
    }
    return (plans.length / 2).floor().clamp(0, plans.length - 1);
  }
}

class _ProfileTypeSelector extends StatelessWidget {
  final SubscriptionService subscriptionService;

  const _ProfileTypeSelector({required this.subscriptionService});

  @override
  Widget build(BuildContext context) {
    final profileTypes = AppFlavour.getProfileTypes();
    if (profileTypes.length <= 1) return const SizedBox.shrink();

    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${AppTranslationConstants.profileType.tr}: ',
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColor.bondiBlue25,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ProfileType>(
              items: profileTypes.map((type) {
                return DropdownMenuItem<ProfileType>(
                  value: type,
                  child: Text(type.value.tr.capitalize,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (type) {
                if (type != null) subscriptionService.selectProfileType(type);
              },
              value: subscriptionService.profileType,
              dropdownColor: AppColor.getMain(),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
              isDense: true,
            ),
          ),
        ),
      ],
    ));
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isRecommended;
  final SubscriptionService subscriptionService;

  const _PlanCard({
    required this.plan,
    required this.isRecommended,
    required this.subscriptionService,
  });

  @override
  Widget build(BuildContext context) {
    final price = plan.price;
    final currencySymbol = price != null
        ? CoreUtilities.getCurrencySymbol(price.currency)
        : '\$';
    final amount = price?.amount ?? 0.0;
    final currencyName = price?.currency.name.toUpperCase() ?? '';
    final planFeatures = _getPlanFeatures(plan.level);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.scaffold,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended ? AppColor.ceriseRed : Colors.white12,
          width: isRecommended ? 2 : 1,
        ),
        boxShadow: isRecommended
            ? [BoxShadow(color: AppColor.ceriseRed.withValues(alpha: 0.3), blurRadius: 16, spreadRadius: 2)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Recommended badge
          if (isRecommended)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.ceriseRed,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Text(
                SettingTranslationConstants.recommended.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan name
                Text(
                  plan.name.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$currencySymbol${amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '$currencyName${SettingTranslationConstants.perMonth.tr}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Features
                if (planFeatures.isNotEmpty) ...[
                  Text(
                    '${SettingTranslationConstants.includes.tr}:',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...planFeatures.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16, color: Colors.greenAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(fontSize: 13, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],

                const SizedBox(height: 20),

                // CTA button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      subscriptionService.changeSubscriptionPlan(plan.id);
                      await subscriptionService.paySubscription(plan, 'subscriptionPlans');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecommended ? AppColor.ceriseRed : AppColor.bondiBlue75,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      SettingTranslationConstants.selectPlan.tr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Generate feature descriptions based on subscription level.
  List<String> _getPlanFeatures(SubscriptionLevel? level) {
    if (level == null) return [];

    switch (level) {
      case SubscriptionLevel.basic:
        return [
          AppTranslationConstants.subscription.tr,
          ('${plan.name}Msg').tr,
        ];
      case SubscriptionLevel.creator:
        return [
          ('${plan.name}Msg').tr,
        ];
      case SubscriptionLevel.artist:
        return [
          ('${plan.name}Msg').tr,
        ];
      case SubscriptionLevel.professional:
        return [
          ('${plan.name}Msg').tr,
        ];
      case SubscriptionLevel.premium:
        return [
          ('${plan.name}Msg').tr,
        ];
      case SubscriptionLevel.publish:
        return [
          ('${plan.name}Msg').tr,
        ];
      default:
        return [('${plan.name}Msg').tr];
    }
  }
}
