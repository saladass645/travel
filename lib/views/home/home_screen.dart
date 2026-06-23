import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:travel_app/components/build_image.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/controllers/home/home_controller.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/helpers/main_user.dart';
import 'package:travel_app/models/category_model.dart';
import 'package:travel_app/models/tour_model.dart';
import 'package:travel_app/views/home/search_option_screen.dart';
import 'package:travel_app/views/home/tour_details_screen.dart';

class HomeScreen extends GetWidget<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 360;
    final isWide = size.width >= 600;
    final hPad = isWide ? 32.0 : (isCompact ? 18.0 : 22.0);

    return GetBuilder<HomeController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: k_primaryColor),
          );
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(),
              const SizedBox(height: 22),
              _Greeting(isCompact: isCompact),
              const SizedBox(height: 22),
              _SearchPill(),
              const SizedBox(height: 24),
              _ContinentTabs(controller: controller),
              const SizedBox(height: 22),
              _SectionHeader(title: 'Popular destinations'),
              const SizedBox(height: 14),
              _TourCards(tours: controller.tours, isWide: isWide),
              const SizedBox(height: 28),
              _SectionHeader(title: 'Popular_Categories'.tr),
              const SizedBox(height: 14),
              _CategoryRow(categories: controller.popularCategory),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- top bar

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _RoundIconButton(icon: LineIcons.bars, onTap: () {}),
        Stack(
          clipBehavior: Clip.none,
          children: [
            _RoundIconButton(icon: LineIcons.bell, onTap: () {}),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: k_primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: k_fieldGray,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, size: 22, color: const Color(0xFF191C32)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- greeting

class _Greeting extends StatelessWidget {
  const _Greeting({required this.isCompact});
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final name = MainUser.instance.model?.name;
    final greeting = (name != null && name.isNotEmpty)
        ? 'Hi, $name 👋'
        : 'Hello, traveler 👋';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: greeting,
          fontSize: 14,
          color: const Color(0xFF7A869A),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 6),
        CustomText(
          text: 'where_Do_you_want_go'.tr,
          fontSize: isCompact ? 26 : 30,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.start,
          maxLines: 2,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- search

class _SearchPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => SearchOptionScreen()),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: k_fieldGray,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(left: 18),
        child: Row(
          children: [
            Icon(LineIcons.search, color: const Color(0xFF7A869A), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: CustomText(
                text: 'search_trip'.tr,
                fontSize: 14,
                color: const Color(0xFF7A869A),
                textAlign: TextAlign.start,
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    k_primaryColor,
                    k_primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: k_primaryColor.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                LineIcons.search,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- continents

class _ContinentTabs extends StatelessWidget {
  const _ContinentTabs({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: controller.continents.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final active = controller.currentIndex == index;
          return _ContinentPill(
            label: controller.continents[index],
            active: active,
            onTap: () => controller.onChangeContinents(index),
          );
        },
      ),
    );
  }
}

class _ContinentPill extends StatelessWidget {
  const _ContinentPill({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? k_primaryColor : k_fieldGray,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          child: CustomText(
            text: label,
            fontSize: 14,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? Colors.white : const Color(0xFF191C32),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- section header

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: title,
          fontSize: 17,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.start,
        ),
        Row(
          children: [
            CustomText(
              text: 'See all',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: k_primaryColor,
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: k_primaryColor,
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- tour cards

class _TourCards extends StatelessWidget {
  const _TourCards({required this.tours, required this.isWide});
  final List<TourModel> tours;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (tours.isEmpty) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          color: k_fieldGray,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: CustomText(
          text: 'No destinations yet',
          fontSize: 14,
          color: const Color(0xFF7A869A),
        ),
      );
    }

    final cardWidth = isWide ? 240.0 : 215.0;
    final cardHeight = isWide ? 300.0 : 270.0;

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: tours.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final tour = tours[index];
          return _TourCard(
            tour: tour,
            width: cardWidth,
            height: cardHeight,
          );
        },
      ),
    );
  }
}

class _TourCard extends StatelessWidget {
  const _TourCard({
    required this.tour,
    required this.width,
    required this.height,
  });
  final TourModel tour;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => TourDetailsScreen(model: tour)),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              BuildImage(
                image: tour.image ?? '',
                borderRadius: 24,
                width: width,
                height: height,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.65),
                      ],
                      stops: const [0.45, 1.0],
                    ),
                  ),
                ),
              ),
              if (tour.rating != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: _RatingChip(rating: tour.rating!),
                ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tour.continent != null && tour.continent!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 13,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: CustomText(
                              text: tour.continent!,
                              fontSize: 12,
                              color: Colors.white70,
                              maxLines: 1,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    CustomText(
                      text: tour.title ?? '',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      maxLines: 2,
                      textAlign: TextAlign.start,
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

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB300)),
          const SizedBox(width: 2),
          CustomText(
            text: rating.toStringAsFixed(1),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF191C32),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- categories

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.categories});
  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 108,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final c = categories[index];
          return _CategoryTile(name: c.name ?? '', image: c.image ?? '');
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.name, required this.image});
  final String name;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BuildImage(
              image: image,
              borderRadius: 20,
              width: 68,
              height: 68,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: CustomText(
            text: name,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
