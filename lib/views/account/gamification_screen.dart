import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/components/glass_chip.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({Key? key}) : super(key: key);

  static const int _pointsPerTrip = 50;
  static const int _pointsPerSaved = 5;
  static const int _pointsPerMemory = 10;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TripController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const TitleText('Achievements'),
        centerTitle: false,
      ),
      body: GetBuilder<TripController>(
        builder: (_) {
          final trips = c.tripList.length;
          final saved = c.savedPlaces.length;
          final mems =
              c.memories.values.fold<int>(0, (s, l) => s + l.length);
          final points = trips * _pointsPerTrip +
              saved * _pointsPerSaved +
              mems * _pointsPerMemory;
          final level = (points ~/ 100) + 1;
          final progressInLevel = (points % 100) / 100;
          final nextLevel = (level * 100) - points;

          final badges = <_Badge>[
            _Badge(
              icon: Icons.luggage_rounded,
              title: 'First Trip',
              earned: trips >= 1,
            ),
            _Badge(
              icon: Icons.public_rounded,
              title: 'Explorer',
              earned: trips >= 3,
            ),
            _Badge(
              icon: Icons.bookmark_rounded,
              title: 'Collector',
              earned: saved >= 5,
            ),
            _Badge(
              icon: Icons.photo_camera_rounded,
              title: 'Storyteller',
              earned: mems >= 5,
            ),
            _Badge(
              icon: Icons.local_fire_department_rounded,
              title: 'Trotter',
              earned: trips >= 10,
            ),
            _Badge(
              icon: Icons.workspace_premium_rounded,
              title: 'Legend',
              earned: points >= 500,
            ),
          ];

          return ListView(
            padding:
                const EdgeInsets.fromLTRB(k_pad, 4, k_pad, 40),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(k_radLg),
                  gradient: k_gradHero,
                  boxShadow: [
                    BoxShadow(
                      color: k_primary.withOpacity(0.4),
                      blurRadius: 26,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GlassChip(
                          label: 'LEVEL $level',
                          icon: Icons.bolt_rounded,
                        ),
                        const Spacer(),
                        const Icon(Icons.emoji_events_rounded,
                            size: 32, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CustomText(
                          text: '$points',
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2,
                          height: 1,
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CustomText(
                            text: 'points',
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: progressInLevel,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(
                            Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      text: '$nextLevel pts to level ${level + 1}',
                      color: Colors.white70,
                      fontSize: 12,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const OverlineText('BADGES'),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: badges.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.92,
                ),
                itemBuilder: (_, i) => _BadgeTile(badge: badges[i]),
              ),
              const SizedBox(height: 24),
              _PointGuide(),
            ],
          );
        },
      ),
    );
  }
}

class _Badge {
  _Badge({required this.icon, required this.title, required this.earned});
  final IconData icon;
  final String title;
  final bool earned;
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});
  final _Badge badge;

  @override
  Widget build(BuildContext context) {
    final color = badge.earned ? k_primary : AppColors.textFaint;
    return Container(
      decoration: BoxDecoration(
        color: badge.earned ? AppColors.primarySoft : AppColors.field,
        borderRadius: BorderRadius.circular(k_radMd),
        border: Border.all(
          color: badge.earned
              ? k_primary.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: badge.earned ? k_primary : AppColors.field2,
              shape: BoxShape.circle,
            ),
            child: Icon(badge.icon,
                size: 20,
                color: badge.earned ? Colors.white : color),
          ),
          const SizedBox(height: 8),
          CustomText(
            text: badge.title,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _PointGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(k_radMd),
        boxShadow: k_shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleText('How to earn points'),
          const SizedBox(height: 14),
          _line(Icons.flight_takeoff_rounded, 'Create a trip', '+50',
              k_primary),
          _line(Icons.bookmark_rounded, 'Save a place', '+5', k_accent),
          _line(Icons.photo_camera_rounded, 'Add a memory', '+10',
              const Color(0xFF6C5CE7)),
        ],
      ),
    );
  }

  Widget _line(IconData icon, String label, String pts, Color tint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: tint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomText(
              text: label,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody,
              textAlign: TextAlign.start,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(100),
            ),
            child: CustomText(
              text: pts,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: k_primary,
            ),
          ),
        ],
      ),
    );
  }
}
