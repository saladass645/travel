import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/build_image.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/components/glass_chip.dart';
import 'package:travel_app/components/section_header.dart';
import 'package:travel_app/controllers/home/home_controller.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/helpers/main_user.dart';
import 'package:travel_app/models/tour_model.dart';
import 'package:travel_app/views/home/search_option_screen.dart';
import 'package:travel_app/views/home/tour_details_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  static const _tabs = [
    'For You',
    'Hot Places',
    'Featured',
    'Stories',
    'Top Journeys',
  ];

  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: k_primary),
          );
        }
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: _HeroHeader()),
            SliverToBoxAdapter(child: _SearchPill()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: _DiscoveryTabs(
                tabs: _tabs,
                active: _activeTab,
                onTap: (i) => setState(() => _activeTab = i),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(
              child: _DiscoveryContent(
                tab: _tabs[_activeTab],
                tours: controller.tours,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 130)),
          ],
        );
      },
    );
  }
}

// =================================================================== hero

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final name = MainUser.instance.model?.name?.split(' ').first;
    final hello = name != null && name.isNotEmpty ? name : 'Traveler';

    return Container(
      padding: EdgeInsets.fromLTRB(
          k_pad, MediaQuery.of(context).padding.top + 18, k_pad, 28),
      decoration: const BoxDecoration(
        gradient: k_gradHero,
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
                label: 'EXPLORE',
                icon: Icons.public_rounded,
              ),
              const Spacer(),
              CircleIconButton(
                icon: Icons.notifications_none_rounded,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 22),
          CustomText(
            text: 'Hi, $hello',
            fontSize: 14,
            color: Colors.white.withOpacity(0.85),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 6),
          CustomText(
            text: 'Where will you\nwander next?',
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: Colors.white,
            height: 1.1,
            textAlign: TextAlign.start,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

// =================================================================== search

class _SearchPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: k_pad),
        child: GestureDetector(
          onTap: () => Get.to(() => SearchOptionScreen()),
          child: Container(
            height: 60,
            padding:
                const EdgeInsets.symmetric(horizontal: 8).copyWith(left: 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    color: AppColors.textMuted, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomText(
                    text: 'Where to?',
                    fontSize: 14,
                    color: AppColors.textMuted,
                    textAlign: TextAlign.start,
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    gradient: k_gradAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.tune_rounded,
                      color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =================================================================== tabs

class _DiscoveryTabs extends StatelessWidget {
  const _DiscoveryTabs({
    required this.tabs,
    required this.active,
    required this.onTap,
  });
  final List<String> tabs;
  final int active;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: k_pad),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == active;
          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.textDark : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                border: selected
                    ? null
                    : Border.all(color: AppColors.border, width: 1),
              ),
              child: CustomText(
                text: tabs[index],
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textBody,
              ),
            ),
          );
        },
      ),
    );
  }
}

// =================================================================== content

class _DiscoveryContent extends StatelessWidget {
  const _DiscoveryContent({required this.tab, required this.tours});
  final String tab;
  final List<TourModel> tours;

  @override
  Widget build(BuildContext context) {
    if (tours.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: k_pad),
        child: _EmptyBox(label: 'No destinations to show yet'),
      );
    }
    switch (tab) {
      case 'Hot Places':
        return _HotPlacesView(tours: tours);
      case 'Featured':
        return _FeaturedView(tours: tours);
      case 'Stories':
        return _StoriesView(tours: tours);
      case 'Top Journeys':
        return _TopJourneysView(tours: tours);
      case 'For You':
      default:
        return _ForYouView(tours: tours);
    }
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(k_radLg),
      ),
      alignment: Alignment.center,
      child: CustomText(
        text: label,
        fontSize: 14,
        color: AppColors.textMuted,
      ),
    );
  }
}

// ---------- For You ----------

class _ForYouView extends StatelessWidget {
  const _ForYouView({required this.tours});
  final List<TourModel> tours;

  @override
  Widget build(BuildContext context) {
    final featured = tours.first;
    final rest = tours.skip(1).take(8).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: k_pad),
          child: _FeatureCard(tour: featured, height: 380),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: k_pad),
          child: SectionHeader(
            title: 'Trending now',
            subtitle: 'Picked for your travel mood',
            actionLabel: 'See all',
            onAction: () {},
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: k_pad),
            itemCount: rest.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) =>
                _MediumTourCard(tour: rest[i], width: 210),
          ),
        ),
      ],
    );
  }
}

// ---------- Hot Places ----------

class _HotPlacesView extends StatelessWidget {
  const _HotPlacesView({required this.tours});
  final List<TourModel> tours;

  @override
  Widget build(BuildContext context) {
    final sorted = [...tours]
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    final pageTours = sorted.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: k_pad),
          child: SectionHeader(
            title: 'Hot right now',
            subtitle: 'Places everyone is going to',
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.86),
            physics: const BouncingScrollPhysics(),
            itemCount: pageTours.length,
            itemBuilder: (_, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _FeatureCard(
                  tour: pageTours[i],
                  height: 320,
                  showHotBadge: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------- Featured ----------

class _FeaturedView extends StatelessWidget {
  const _FeaturedView({required this.tours});
  final List<TourModel> tours;

  @override
  Widget build(BuildContext context) {
    final list = tours.take(6).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: k_pad),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.74,
        ),
        itemBuilder: (_, i) =>
            _MediumTourCard(tour: list[i], width: double.infinity),
      ),
    );
  }
}

// ---------- Stories ----------

class _StoriesView extends StatelessWidget {
  const _StoriesView({required this.tours});
  final List<TourModel> tours;

  @override
  Widget build(BuildContext context) {
    final list = tours.take(10).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: k_pad),
          child: SectionHeader(
            title: 'Travel stories',
            subtitle: 'Real moments from real travelers',
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: k_pad),
            physics: const BouncingScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              final t = list[i];
              return GestureDetector(
                onTap: () => Get.to(() => TourDetailsScreen(model: t)),
                child: Column(
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: k_gradAccent,
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: ClipOval(
                          child: BuildImage(
                            image: t.image ?? '',
                            width: 70,
                            height: 70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 86,
                      child: CustomText(
                        text: t.title ?? '',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBody,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: k_pad),
          child: SectionHeader(title: 'Recent journeys'),
        ),
        const SizedBox(height: 12),
        ...list.take(4).map(
              (t) => Padding(
                padding: const EdgeInsets.fromLTRB(k_pad, 0, k_pad, 12),
                child: _StoryRow(tour: t),
              ),
            ),
      ],
    );
  }
}

class _StoryRow extends StatelessWidget {
  const _StoryRow({required this.tour});
  final TourModel tour;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => TourDetailsScreen(model: tour)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(k_radMd),
          boxShadow: k_shadowCard,
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BuildImage(
                image: tour.image ?? '',
                width: 84,
                height: 84,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: tour.title ?? '',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Flexible(
                        child: CustomText(
                          text: tour.continent ?? '',
                          fontSize: 12,
                          color: AppColors.textMuted,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  CustomText(
                    text: tour.overview ?? '',
                    fontSize: 12,
                    color: AppColors.textBody,
                    height: 1.4,
                    textAlign: TextAlign.start,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Top Journeys ----------

class _TopJourneysView extends StatelessWidget {
  const _TopJourneysView({required this.tours});
  final List<TourModel> tours;

  @override
  Widget build(BuildContext context) {
    final ranked = [...tours]
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: k_pad),
      child: Column(
        children: List.generate(ranked.length.clamp(0, 12), (i) {
          final t = ranked[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => Get.to(() => TourDetailsScreen(model: t)),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(k_radMd),
                  boxShadow: k_shadowCard,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: CustomText(
                        text: '${i + 1}',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: i < 3 ? k_accent : AppColors.textFaint,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BuildImage(
                        image: t.image ?? '',
                        width: 64,
                        height: 64,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: t.title ?? '',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          CustomText(
                            text: t.continent ?? '',
                            fontSize: 12,
                            color: AppColors.textMuted,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    if (t.rating != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: k_amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: k_amber, size: 14),
                            const SizedBox(width: 2),
                            CustomText(
                              text: t.rating!.toStringAsFixed(1),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// =================================================================== cards

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.tour,
    required this.height,
    this.showHotBadge = false,
  });
  final TourModel tour;
  final double height;
  final bool showHotBadge;

  @override
  Widget build(BuildContext context) {
    final tripC = Get.find<TripController>();
    return GestureDetector(
      onTap: () => Get.to(() => TourDetailsScreen(model: tour)),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              BuildImage(image: tour.image ?? '', borderRadius: 28),
              const _ImageScrim(),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (showHotBadge)
                          const GlassChip(
                            label: 'TRENDING',
                            icon: Icons.local_fire_department_rounded,
                            tint: Color(0x55FF6B47),
                          )
                        else if (tour.continent != null)
                          GlassChip(
                            label: tour.continent!,
                            icon: Icons.place_outlined,
                          ),
                        const Spacer(),
                        GetBuilder<TripController>(
                          builder: (_) {
                            final saved = tripC.isSaved(tour);
                            return CircleIconButton(
                              icon: saved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: saved ? k_accent : Colors.white,
                              onTap: () => tripC.toggleSaved(tour),
                            );
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                    CustomText(
                      text: tour.title ?? '',
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      height: 1.1,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (tour.rating != null) ...[
                          const Icon(Icons.star_rounded,
                              color: k_amber, size: 18),
                          const SizedBox(width: 4),
                          CustomText(
                            text:
                                '${tour.rating!.toStringAsFixed(1)} · ${tour.numberOfReviews ?? 0} reviews',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ] else
                          CustomText(
                            text: tour.continent ?? 'Discover',
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Icon(Icons.arrow_forward_rounded,
                              color: AppColors.textDark, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediumTourCard extends StatelessWidget {
  const _MediumTourCard({required this.tour, required this.width});
  final TourModel tour;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => TourDetailsScreen(model: tour)),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: k_shadowCard,
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1.05,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    BuildImage(image: tour.image ?? ''),
                    if (tour.rating != null)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GlassChip(
                          label: tour.rating!.toStringAsFixed(1),
                          icon: Icons.star_rounded,
                          tint: const Color(0x66000000),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: tour.title ?? '',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Flexible(
                        child: CustomText(
                          text: tour.continent ?? '',
                          fontSize: 11,
                          color: AppColors.textMuted,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _ImageScrim extends StatelessWidget {
  const _ImageScrim();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.15),
              Colors.transparent,
              Colors.black.withOpacity(0.75),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
      ),
    );
  }
}
