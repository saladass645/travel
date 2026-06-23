import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/build_image.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/components/glass_chip.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/views/home/tour_details_screen.dart';

class TripCollectionScreen extends StatelessWidget {
  const TripCollectionScreen({Key? key, required this.trip}) : super(key: key);
  final Trip trip;

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
        title: const TitleText('Collection'),
        centerTitle: false,
      ),
      body: GetBuilder<TripController>(
        builder: (_) {
          final items = c.collectionFor(trip.id ?? '');
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: k_gradAccent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                          Icons.collections_bookmark_rounded,
                          size: 40,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 18),
                    const HeadlineText('Nothing saved yet'),
                    const SizedBox(height: 6),
                    const MutedText(
                      'Save places from Discovery — they\'ll appear here.',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding:
                const EdgeInsets.fromLTRB(k_pad, 4, k_pad, 30),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (_, i) {
              final tour = items[i].tour;
              return GestureDetector(
                onTap: () => Get.to(() => TourDetailsScreen(model: tour)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BuildImage(image: tour.image ?? ''),
                    ),
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
                    Positioned(
                      top: 10,
                      right: 10,
                      child: CircleIconButton(
                        icon: Icons.close_rounded,
                        size: 32,
                        onTap: () => c.removeFromTripCollection(
                            trip.id ?? '', tour),
                      ),
                    ),
                    if (tour.continent != null)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: GlassChip(label: tour.continent!),
                      ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
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
                          if (tour.rating != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: k_amber, size: 14),
                                const SizedBox(width: 2),
                                CustomText(
                                  text:
                                      tour.rating!.toStringAsFixed(1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
