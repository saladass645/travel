import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/build_image.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/controllers/home/home_controller.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/tour_model.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/views/home/tour_details_screen.dart';

class TripDiscoveryScreen extends StatelessWidget {
  const TripDiscoveryScreen({Key? key, required this.trip}) : super(key: key);
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final tripC = Get.find<TripController>();
    final destination = (trip.destination ?? '').toLowerCase();
    final filtered = home.tours.where((t) {
      final c = (t.continent ?? '').toLowerCase();
      final title = (t.title ?? '').toLowerCase();
      return destination.isEmpty ||
          c.contains(destination) ||
          destination.contains(c) ||
          title.contains(destination);
    }).toList();
    final list = filtered.isEmpty ? home.tours : filtered;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: TitleText('Near ${trip.destination ?? ''}', maxLines: 1),
        centerTitle: false,
      ),
      body: GetBuilder<TripController>(
        builder: (_) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.travel_explore_rounded,
                      size: 60, color: AppColors.textFaint),
                  const SizedBox(height: 12),
                  const MutedText('No places to show'),
                ],
              ),
            );
          }
          return ListView.separated(
            padding:
                const EdgeInsets.fromLTRB(k_pad, 4, k_pad, 30),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final t = list[i];
              final inIt = tripC
                  .collectionFor(trip.id ?? '')
                  .any((s) =>
                      (s.tour.id ?? s.tour.title) ==
                      (t.id ?? t.title));
              return _DiscoverTile(
                tour: t,
                inCollection: inIt,
                onToggle: () {
                  if (inIt) {
                    tripC.removeFromTripCollection(trip.id ?? '', t);
                  } else {
                    tripC.addToTripCollection(trip.id ?? '', t);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _DiscoverTile extends StatelessWidget {
  const _DiscoverTile({
    required this.tour,
    required this.inCollection,
    required this.onToggle,
  });
  final TourModel tour;
  final bool inCollection;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => TourDetailsScreen(model: tour)),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(k_radMd),
          boxShadow: k_shadowCard,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BuildImage(
                  image: tour.image ?? '', width: 84, height: 84),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleText(tour.title ?? '', maxLines: 1),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Flexible(
                          child: MutedText(tour.continent ?? '',
                              maxLines: 1)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (tour.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: k_amber, size: 14),
                        const SizedBox(width: 2),
                        CustomText(
                          text: tour.rating!.toStringAsFixed(1),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: inCollection ? AppColors.primarySoft : AppColors.field,
                borderRadius: BorderRadius.circular(100),
              ),
              child: IconButton(
                icon: Icon(
                  inCollection
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: inCollection ? k_primary : AppColors.textMuted,
                ),
                onPressed: onToggle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
