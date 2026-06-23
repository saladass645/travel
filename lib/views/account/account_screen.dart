import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/build_image.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/components/glass_chip.dart';
import 'package:travel_app/controllers/profile/profile_controller.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/helpers/main_user.dart';
import 'package:travel_app/views/account/gamification_screen.dart';
import 'package:travel_app/views/account/saved_places_screen.dart';
import 'package:travel_app/views/account/settings_screen.dart';
import 'package:travel_app/views/account/share_screen.dart';
import 'package:travel_app/views/profile/edit_account_screen.dart';

class AccountScreen extends GetWidget<ProfileController> {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: _ProfileHero()),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: k_pad),
              child: _StatsRow(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: k_pad),
              child: _Section(
                title: 'PROFILE',
                items: [
                  _AccountItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit account',
                    onTap: () => Get.to(() => EditAccountScreen()),
                  ),
                  _AccountItem(
                    icon: Icons.bookmark_outline_rounded,
                    label: 'Saved places',
                    onTap: () => Get.to(() => const SavedPlacesScreen()),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: k_pad),
              child: _Section(
                title: 'APP',
                items: [
                  _AccountItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => Get.to(() => const SettingsScreen()),
                  ),
                  _AccountItem(
                    icon: Icons.emoji_events_outlined,
                    label: 'Achievements',
                    onTap: () =>
                        Get.to(() => const GamificationScreen()),
                  ),
                  _AccountItem(
                    icon: Icons.ios_share_rounded,
                    label: 'Share photos & journeys',
                    onTap: () => Get.to(() => const ShareScreen()),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: k_pad),
              child: _Section(
                title: 'SESSION',
                items: [
                  _AccountItem(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    danger: true,
                    onTap: () => controller.logut(),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 130)),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final tripC = Get.find<TripController>();
    return Container(
      padding:
          EdgeInsets.fromLTRB(k_pad, mq.padding.top + 14, k_pad, 30),
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
              const GlassChip(
                label: 'ACCOUNT',
                icon: Icons.person_outline_rounded,
              ),
              const Spacer(),
              CircleIconButton(
                icon: Icons.notifications_none_rounded,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          GetBuilder<ProfileController>(
            builder: (_) {
              final user = MainUser.instance.model;
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: k_gradAccent,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: BuildImage(
                        image: user?.image ?? '',
                        width: 78,
                        height: 78,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: user?.name ?? 'Traveler',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          text: user?.email ?? '',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.85),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 8),
                        GetBuilder<TripController>(
                          builder: (_) {
                            final trips = tripC.tripList.length;
                            return GlassChip(
                              label:
                                  '$trips ${trips == 1 ? "journey" : "journeys"}',
                              icon: Icons.flight_rounded,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tripC = Get.find<TripController>();
    return GetBuilder<TripController>(
      builder: (_) {
        final memCount = tripC.memories.values
            .fold<int>(0, (s, l) => s + l.length);
        return Row(
          children: [
            Expanded(
              child: _StatBox(
                label: 'Trips',
                value: '${tripC.tripList.length}',
                icon: Icons.flight_takeoff_rounded,
                tint: k_primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatBox(
                label: 'Saved',
                value: '${tripC.savedPlaces.length}',
                icon: Icons.bookmark_rounded,
                tint: k_accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatBox(
                label: 'Memories',
                value: '$memCount',
                icon: Icons.photo_camera_rounded,
                tint: const Color(0xFF6C5CE7),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(k_radMd),
        boxShadow: k_shadowCard,
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: tint, size: 18),
          ),
          const SizedBox(height: 8),
          CustomText(
            text: value,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
          const SizedBox(height: 2),
          CustomText(
            text: label,
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});
  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: OverlineText(title),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(k_radMd),
            boxShadow: k_shadowCard,
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              if (i == items.length - 1) return items[i];
              return Column(
                children: [
                  items[i],
                  Divider(height: 1, color: AppColors.border, indent: 56),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _AccountItem extends StatelessWidget {
  const _AccountItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(k_radMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (danger ? k_error : k_primary).withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon,
                  color: danger ? k_error : k_primary, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CustomText(
                text: label,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: danger ? k_error : AppColors.textDark,
                textAlign: TextAlign.start,
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textFaint, size: 22),
          ],
        ),
      ),
    );
  }
}
