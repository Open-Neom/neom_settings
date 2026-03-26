import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:neom_commons/app_flavour.dart';
import 'package:neom_commons/ui/theme/app_color.dart';
import 'package:neom_commons/utils/constants/translations/app_translation_constants.dart';
import 'package:neom_core/domain/model/subscription_plan.dart';
import 'package:neom_core/domain/use_cases/subscription_service.dart';
import 'package:neom_core/utils/core_utilities.dart';
import 'package:neom_core/utils/enums/profile_type.dart';
import 'package:neom_core/utils/enums/subscription_level.dart';
import 'package:sint/sint.dart';

import '../utils/constants/setting_translation_constants.dart';

/// Web-optimized subscription plans page with TabView per profile type.
class SubscriptionPlansPage extends StatelessWidget {
  const SubscriptionPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionService = Sint.find<SubscriptionService>();

    return Scaffold(
      appBar: SintAppBar(title: SettingTranslationConstants.choosePlan.tr),
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

class _SubscriptionPlansBody extends StatefulWidget {
  final SubscriptionService subscriptionService;

  const _SubscriptionPlansBody({required this.subscriptionService});

  @override
  State<_SubscriptionPlansBody> createState() => _SubscriptionPlansBodyState();
}

class _SubscriptionPlansBodyState extends State<_SubscriptionPlansBody>
    with SingleTickerProviderStateMixin {

  late final List<ProfileType> _profileTypes;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _profileTypes = AppFlavour.getProfileTypes();
    _tabController = TabController(length: _profileTypes.length, vsync: this);

    // Sync initial tab with current profile type
    final currentIndex = _profileTypes.indexOf(widget.subscriptionService.profileType);
    if (currentIndex >= 0) _tabController.index = currentIndex;

    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      widget.subscriptionService.selectProfileType(_profileTypes[_tabController.index]);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = kIsWeb || screenWidth > 900;

    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 40 : 16,
            vertical: 20,
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                SettingTranslationConstants.monthlySubscription.tr,
                style: const TextStyle(fontSize: 16, color: Colors.white60),
              ),
            ],
          ),
        ),

        // Tab bar
        if (_profileTypes.length > 1)
          Container(
            margin: EdgeInsets.symmetric(horizontal: isWide ? 40 : 16),
            decoration: BoxDecoration(
              color: AppColor.surfaceDim,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              indicator: BoxDecoration(
                color: AppColor.bondiBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              dividerHeight: 0,
              labelPadding: EdgeInsets.zero,
              tabs: _profileTypes.map((type) => Tab(
                text: _profileTypeLabel(type),
              )).toList(),
            ),
          ),

        const SizedBox(height: 8),

        // Tab content
        Expanded(
          child: _profileTypes.length > 1
              ? TabBarView(
                  controller: _tabController,
                  children: _profileTypes.map((type) =>
                    _ProfileTabContent(
                      profileType: type,
                      subscriptionService: widget.subscriptionService,
                      isWide: isWide,
                      screenWidth: screenWidth,
                    ),
                  ).toList(),
                )
              : Obx(() => _PlansGrid(
                  plans: widget.subscriptionService.profilePlans.values.toList(),
                  subscriptionService: widget.subscriptionService,
                  isWide: isWide,
                  screenWidth: screenWidth,
                )),
        ),
      ],
    );
  }

  String _profileTypeLabel(ProfileType type) {
    switch (type) {
      case ProfileType.general: return AppTranslationConstants.general.tr.capitalize;
      case ProfileType.appArtist: return AppTranslationConstants.artist.tr.capitalize;
      case ProfileType.facilitator: return SettingTranslationConstants.facilitator.tr.capitalize;
      case ProfileType.host: return SettingTranslationConstants.promoter.tr.capitalize;
      default: return type.value.tr.capitalize;
    }
  }
}

/// Content for each profile type tab: description + plans grid.
class _ProfileTabContent extends StatelessWidget {
  final ProfileType profileType;
  final SubscriptionService subscriptionService;
  final bool isWide;
  final double screenWidth;

  const _ProfileTabContent({
    required this.profileType,
    required this.subscriptionService,
    required this.isWide,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 40 : 16,
        vertical: 16,
      ),
      child: Column(
        children: [
          // Profile type description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accentColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(_profileIcon, color: _accentColor, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profileTitle,
                        style: TextStyle(
                          color: _accentColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _profileDescription,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Plans grid
          Obx(() {
            final plans = subscriptionService.profilePlans.values.toList();
            return _PlansGrid(
              plans: plans,
              subscriptionService: subscriptionService,
              isWide: isWide,
              screenWidth: screenWidth,
            );
          }),
        ],
      ),
    );
  }

  String get _profileTitle {
    switch (profileType) {
      case ProfileType.general:
        return SettingTranslationConstants.generalProfileTitle.tr;
      case ProfileType.appArtist:
        return SettingTranslationConstants.artistProfileTitle.tr;
      case ProfileType.facilitator:
        return SettingTranslationConstants.facilitatorProfileTitle.tr;
      case ProfileType.host:
        return SettingTranslationConstants.promoterProfileTitle.tr;
      default:
        return profileType.value.tr;
    }
  }

  String get _profileDescription {
    switch (profileType) {
      case ProfileType.general:
        return SettingTranslationConstants.generalProfileDesc.tr;
      case ProfileType.appArtist:
        return SettingTranslationConstants.artistProfileDesc.tr;
      case ProfileType.facilitator:
        return SettingTranslationConstants.facilitatorProfileDesc.tr;
      case ProfileType.host:
        return SettingTranslationConstants.promoterProfileDesc.tr;
      default:
        return '';
    }
  }

  IconData get _profileIcon {
    switch (profileType) {
      case ProfileType.general: return Icons.person_outline;
      case ProfileType.appArtist: return Icons.brush_outlined;
      case ProfileType.facilitator: return Icons.handshake_outlined;
      case ProfileType.host: return Icons.campaign_outlined;
      default: return Icons.person_outline;
    }
  }

  Color get _accentColor {
    switch (profileType) {
      case ProfileType.general: return const Color(0xFF4FC3F7);
      case ProfileType.appArtist: return const Color(0xFFAED581);
      case ProfileType.facilitator: return const Color(0xFFFFB74D);
      case ProfileType.host: return const Color(0xFFBA68C8);
      default: return AppColor.bondiBlue;
    }
  }
}

/// Reusable plans grid (Wrap on wide, Column on mobile).
class _PlansGrid extends StatelessWidget {
  final List<SubscriptionPlan> plans;
  final SubscriptionService subscriptionService;
  final bool isWide;
  final double screenWidth;

  const _PlansGrid({
    required this.plans,
    required this.subscriptionService,
    required this.isWide,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            AppTranslationConstants.noResults.tr,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    final recommendedIndex = _getRecommendedIndex(plans);

    if (isWide) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Wrap(
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
          ),
        ),
      );
    }

    return Column(
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
    );
  }

  double _cardWidth(double screenWidth, int planCount) {
    final available = (screenWidth - 80).clamp(300, 1200).toDouble();
    if (available > 900) return (available / 3) - 16;
    if (available > 600) return (available / 2) - 16;
    return available;
  }

  int _getRecommendedIndex(List<SubscriptionPlan> plans) {
    for (int i = 0; i < plans.length; i++) {
      if (plans[i].level == SubscriptionLevel.artist) return i;
    }
    return (plans.length / 2).floor().clamp(0, plans.length - 1);
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
                Text(
                  plan.name.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

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
                        style: const TextStyle(fontSize: 14, color: Colors.white60),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

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
                          child: Text(feature, style: const TextStyle(fontSize: 13, color: Colors.white70)),
                        ),
                      ],
                    ),
                  )),
                ],

                const SizedBox(height: 20),

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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      SettingTranslationConstants.selectPlan.tr,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

  List<String> _getPlanFeatures(SubscriptionLevel? level) {
    if (level == null) return [];

    switch (level) {
      case SubscriptionLevel.basic:
        return [
          AppTranslationConstants.subscription.tr,
          ('${plan.name}Msg').tr,
        ];
      default:
        return [('${plan.name}Msg').tr];
    }
  }
}
