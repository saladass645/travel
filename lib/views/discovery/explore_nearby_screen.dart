import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/build_image.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/components/glass_chip.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/tour_model.dart';
import 'package:travel_app/network/geocoding_service.dart';
import 'package:travel_app/network/places_service.dart';
import 'package:travel_app/views/home/tour_details_screen.dart';
import 'package:travel_app/views/pickers/destination_picker.dart';

/// "Explore globally" — pick any city worldwide, browse OpenTripMap POIs near
/// it on demand. No upfront cache, no curated featured list — pure live data.
class ExploreNearbyScreen extends StatefulWidget {
  const ExploreNearbyScreen({Key? key, this.initial}) : super(key: key);
  final DestinationHit? initial;

  @override
  State<ExploreNearbyScreen> createState() => _ExploreNearbyScreenState();
}

class _ExploreNearbyScreenState extends State<ExploreNearbyScreen> {
  DestinationHit? _destination;
  List<TourModel> _tours = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _destination = widget.initial;
      _load();
    } else {
      // Open the picker immediately on first paint so the user lands directly
      // on the search experience.
      WidgetsBinding.instance.addPostFrameCallback((_) => _pick());
    }
  }

  Future<void> _pick() async {
    final hit = await DestinationPickerScreen.pick(context);
    if (hit == null) {
      if (_destination == null && mounted) Get.back();
      return;
    }
    setState(() => _destination = hit);
    _load();
  }

  Future<void> _load() async {
    final dest = _destination;
    if (dest == null) return;
    setState(() {
      _loading = true;
      _tours = const [];
    });
    final rows = await PlacesService.instance.fetchNearbyPlaces(
      lat: dest.lat,
      lon: dest.lon,
      cityLabel: dest.label,
    );
    if (!mounted) return;
    setState(() {
      _tours = rows.map((r) => TourModel.fromJson(r)).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Hero(dest: _destination, onChange: _pick)),
          if (_loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: CircularProgressIndicator(color: k_primary),
                ),
              ),
            )
          else if (_destination != null && _tours.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(),
            )
          else if (_tours.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: k_pad),
              sliver: SliverGrid.builder(
                itemCount: _tours.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (_, i) => _PlaceCard(tour: _tours[i]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.dest, required this.onChange});
  final DestinationHit? dest;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      padding:
          EdgeInsets.fromLTRB(k_pad, mq.padding.top + 14, k_pad, 26),
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
              CircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Get.back(),
              ),
              const Spacer(),
              const GlassChip(
                label: 'EXPLORE GLOBALLY',
                icon: Icons.public_rounded,
              ),
            ],
          ),
          const SizedBox(height: 26),
          CustomText(
            text: dest == null
                ? 'Pick a city to start'
                : 'Discovering places near',
            color: Colors.white.withOpacity(0.85),
            fontSize: 13,
          ),
          const SizedBox(height: 6),
          CustomText(
            text: dest?.label ?? 'anywhere on earth',
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Colors.white,
            height: 1.1,
            textAlign: TextAlign.start,
            maxLines: 2,
          ),
          if (dest != null && dest!.subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.place_rounded,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: CustomText(
                    text: dest!.subtitle,
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: onChange,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 6, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        color: AppColors.textMuted, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomText(
                        text: dest == null
                            ? 'Search any city worldwide'
                            : 'Change destination',
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
                          color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_off_rounded,
                size: 56, color: AppColors.textFaint),
            const SizedBox(height: 12),
            const HeadlineText('No notable places found'),
            const SizedBox(height: 6),
            const MutedText(
              'Try a bigger city nearby — OpenTripMap focuses on points of interest with Wikipedia coverage.',
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.tour});
  final TourModel tour;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => TourDetailsScreen(model: tour)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: k_shadowCard,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              BuildImage(image: tour.image ?? ''),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.75),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
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
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: tour.title ?? '',
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                    ),
                    if (tour.category != null) ...[
                      const SizedBox(height: 4),
                      CustomText(
                        text: tour.category!,
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                      ),
                    ],
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
