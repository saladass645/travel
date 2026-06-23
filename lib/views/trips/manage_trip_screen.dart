import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/components/glass_chip.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/views/trips/manage/budget_expense_screen.dart';
import 'package:travel_app/views/trips/manage/day_plan_screen.dart';
import 'package:travel_app/views/trips/manage/memories_screen.dart';
import 'package:travel_app/views/trips/manage/trip_collection_screen.dart';
import 'package:travel_app/views/trips/manage/trip_discovery_screen.dart';

class ManageTripScreen extends StatelessWidget {
  const ManageTripScreen({Key? key, required this.trip}) : super(key: key);
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TripController>();

    final entries = <_HubEntry>[
      _HubEntry(
        icon: Icons.explore_rounded,
        label: 'Discovery',
        subtitle: 'Find places near your destination',
        color: const Color(0xFF0F766E),
        builder: () => TripDiscoveryScreen(trip: trip),
      ),
      _HubEntry(
        icon: Icons.collections_bookmark_rounded,
        label: 'Collection',
        subtitle: 'Saved spots for this trip',
        color: const Color(0xFFFF7B5A),
        builder: () => TripCollectionScreen(trip: trip),
      ),
      _HubEntry(
        icon: Icons.calendar_month_rounded,
        label: 'Day plan',
        subtitle: 'Schedule each day',
        color: const Color(0xFF6C5CE7),
        builder: () => DayPlanScreen(trip: trip),
      ),
      _HubEntry(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Budget',
        subtitle: 'Track expenses and remaining funds',
        color: const Color(0xFFFFB347),
        builder: () => BudgetExpenseScreen(trip: trip),
      ),
      _HubEntry(
        icon: Icons.photo_camera_rounded,
        label: 'Memories',
        subtitle: 'Photos & moments from the journey',
        color: const Color(0xFF00B894),
        builder: () => MemoriesScreen(trip: trip),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Hero(trip: trip, c: c)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(k_pad, 24, k_pad, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  OverlineText('TRIP PLANNER'),
                  SizedBox(height: 6),
                  HeadlineText('Everything for this trip'),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: k_pad),
            sliver: SliverGrid.builder(
              itemCount: entries.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (_, i) => _HubTile(entry: entries[i]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.trip, required this.c});
  final Trip trip;
  final TripController c;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      padding:
          EdgeInsets.fromLTRB(k_pad, mq.padding.top + 14, k_pad, 26),
      decoration: const BoxDecoration(
        gradient: k_gradPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Get.back(),
              ),
              const Spacer(),
              CircleIconButton(
                icon: Icons.tune_rounded,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 22),
          const GlassChip(
            label: 'PLANNING',
            icon: Icons.dashboard_rounded,
          ),
          const SizedBox(height: 12),
          CustomText(
            text: trip.name ?? '',
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            textAlign: TextAlign.start,
            maxLines: 2,
          ),
          const SizedBox(height: 6),
          CustomText(
            text:
                '${trip.destination ?? ''} · ${c.tripDayCount(trip)} days',
            color: Colors.white.withOpacity(0.85),
            fontSize: 13,
          ),
        ],
      ),
    );
  }
}

class _HubEntry {
  _HubEntry({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.builder,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Widget Function() builder;
}

class _HubTile extends StatelessWidget {
  const _HubTile({required this.entry});
  final _HubEntry entry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(entry.builder),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(k_radLg),
          boxShadow: k_shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: entry.color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(entry.icon, color: entry.color, size: 26),
            ),
            const Spacer(),
            CustomText(
              text: entry.label,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.2,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 4),
            CustomText(
              text: entry.subtitle,
              fontSize: 11,
              color: AppColors.textMuted,
              textAlign: TextAlign.start,
              maxLines: 2,
              height: 1.3,
            ),
          ],
        ),
      ),
    );
  }
}
