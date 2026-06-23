import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:travel_app/components/build_image.dart';
import 'package:travel_app/components/custom_button.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/components/glass_chip.dart';
import 'package:travel_app/controllers/home/tour_details_controller.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/tour_model.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/views/trips/create_trip_dialog.dart';

class TourDetailsScreen extends GetWidget<TourDetailsController> {
  TourDetailsScreen({Key? key, required this.model}) : super(key: key);
  final TourModel model;

  @override
  Widget build(BuildContext context) {
    final tripC = Get.find<TripController>();
    final mq = MediaQuery.of(context);
    final heroHeight = mq.size.height * 0.55;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: GetBuilder<TourDetailsController>(
        builder: (controller) {
          return Stack(
            children: [
              // ----- hero gallery -----
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: heroHeight + 40,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CarouselSlider.builder(
                      itemCount: model.images!.length,
                      itemBuilder: (context, i, _) {
                        return BuildImage(
                          image: model.images![i],
                          borderRadius: 0,
                          height: heroHeight + 40,
                        );
                      },
                      options: CarouselOptions(
                        enableInfiniteScroll: false,
                        height: heroHeight + 40,
                        viewportFraction: 1.0,
                        onPageChanged: (i, _) =>
                            controller.onPageChanged(i),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                              Colors.black.withOpacity(0.25),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: mq.padding.top + 12,
                      left: k_pad,
                      right: k_pad,
                      child: Row(
                        children: [
                          CircleIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Get.back(),
                          ),
                          const Spacer(),
                          GetBuilder<TripController>(
                            builder: (_) {
                              final saved = tripC.isSaved(model);
                              return CircleIconButton(
                                icon: saved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                color:
                                    saved ? k_accent : Colors.white,
                                onTap: () => tripC.toggleSaved(model),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          CircleIconButton(
                            icon: Icons.ios_share_rounded,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 60,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedSmoothIndicator(
                          activeIndex: controller.currentCarouselIndex,
                          count: model.images!.length,
                          effect: const ExpandingDotsEffect(
                            spacing: 6,
                            dotWidth: 8,
                            dotHeight: 8,
                            expansionFactor: 3,
                            dotColor: Color(0x66FFFFFF),
                            activeDotColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ----- content sheet -----
              Positioned.fill(
                top: heroHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(34),
                      topRight: Radius.circular(34),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                        k_pad, 14, k_pad, 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (model.continent != null)
                          Row(
                            children: [
                              Icon(Icons.place_outlined,
                                  size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              CustomText(
                                text: model.continent!,
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        DisplayText(model.title ?? '', maxLines: 3),
                        const SizedBox(height: 14),
                        _MetaRow(model: model),
                        const SizedBox(height: 22),
                        _DetailTabs(
                          tabs: controller.viewDetail,
                          active: controller.currentViewDetailIndex,
                          onTap: controller.onChangeViewDetail,
                        ),
                        const SizedBox(height: 18),
                        _BuildDetails(
                          index: controller.currentViewDetailIndex,
                          model: model,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ----- bottom action dock -----
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ActionDock(
                  model: model,
                  onAddToTrip: () => _showAddToTripSheet(context, tripC),
                  onPlanNew: () => showDialog(
                    context: context,
                    builder: (_) =>
                        CreateTripDialog(presetName: model.title),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddToTripSheet(BuildContext context, TripController c) {
    final trips = c.tripList;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(k_pad, 14, k_pad,
              MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              HeadlineText('Add to trip'),
              const SizedBox(height: 4),
              MutedText('Pick a trip and we\'ll save this place to it'),
              const SizedBox(height: 16),
              if (trips.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.field,
                    borderRadius: BorderRadius.circular(k_radMd),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.flight_takeoff_rounded,
                            color: k_primary, size: 28),
                      ),
                      const SizedBox(height: 12),
                      const TitleText('No trips yet',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      const MutedText(
                        'Create your first trip to start saving places',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Create trip',
                        width: double.infinity,
                        onPressed: () {
                          Navigator.pop(ctx);
                          showDialog(
                            context: context,
                            builder: (_) => CreateTripDialog(
                                presetName: model.title),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.5,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: trips.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final Trip trip = trips[i];
                      final tripId = trip.id ?? '';
                      final inIt = c
                          .collectionFor(tripId)
                          .any((s) =>
                              (s.tour.id ?? s.tour.title) ==
                              (model.id ?? model.title));
                      return InkWell(
                        borderRadius: BorderRadius.circular(k_radMd),
                        onTap: () {
                          if (!inIt) {
                            c.addToTripCollection(tripId, model);
                          }
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    inIt
                                        ? 'Already in ${trip.name}'
                                        : 'Saved to ${trip.name}')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: inIt ? AppColors.primarySoft : AppColors.field,
                            borderRadius:
                                BorderRadius.circular(k_radMd),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                    Icons.flight_takeoff_rounded,
                                    color: k_primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    TitleText(trip.name ?? '',
                                        maxLines: 1),
                                    const SizedBox(height: 2),
                                    MutedText(trip.destination ?? '',
                                        maxLines: 1),
                                  ],
                                ),
                              ),
                              Icon(
                                inIt
                                    ? Icons.check_circle_rounded
                                    : Icons.add_circle_outline_rounded,
                                color:
                                    inIt ? k_primary : AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.model});
  final TourModel model;

  @override
  Widget build(BuildContext context) {
    final items = <_Meta>[
      if (model.rating != null)
        _Meta(Icons.star_rounded,
            model.rating!.toStringAsFixed(1), 'Rating', k_amber),
      if (model.distance != null)
        _Meta(Icons.straighten_rounded, '${model.distance} km', 'Distance',
            k_primary),
      if (model.temperature != null)
        _Meta(Icons.thermostat_rounded,
            '${model.temperature}°C', model.weatherCondition ?? 'Weather',
            k_accent),
    ];
    return Row(
      children: items
          .map((m) => Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4),
                  child: _MetaBox(meta: m),
                ),
              ))
          .toList(),
    );
  }
}

class _Meta {
  _Meta(this.icon, this.title, this.label, this.tint);
  final IconData icon;
  final String title;
  final String label;
  final Color tint;
}

class _MetaBox extends StatelessWidget {
  const _MetaBox({required this.meta});
  final _Meta meta;

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
              color: meta.tint.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(meta.icon, color: meta.tint, size: 18),
          ),
          const SizedBox(height: 8),
          CustomText(
            text: meta.title,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
          const SizedBox(height: 2),
          CustomText(
            text: meta.label,
            fontSize: 11,
            color: AppColors.textMuted,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _DetailTabs extends StatelessWidget {
  const _DetailTabs({
    required this.tabs,
    required this.active,
    required this.onTap,
  });
  final List<String> tabs;
  final int active;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = i == active;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: selected ? k_shadowCard : null,
                ),
                alignment: Alignment.center,
                child: CustomText(
                  text: tabs[i],
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.textDark : AppColors.textMuted,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BuildDetails extends StatelessWidget {
  const _BuildDetails({required this.index, required this.model});
  final int index;
  final TourModel model;

  @override
  Widget build(BuildContext context) {
    String body;
    switch (index) {
      case 1:
        body = model.details ?? '';
        break;
      case 2:
        body = model.reviews ?? '';
        break;
      case 3:
        body = model.costs ?? '';
        break;
      default:
        body = model.overview ?? '';
    }
    return BodyText(body.isEmpty ? 'No information available.' : body,
        maxLines: 50);
  }
}

class _ActionDock extends StatelessWidget {
  const _ActionDock({
    required this.model,
    required this.onAddToTrip,
    required this.onPlanNew,
  });
  final TourModel model;
  final VoidCallback onAddToTrip;
  final VoidCallback onPlanNew;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
          k_pad, 14, k_pad, mq.padding.bottom + 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Add to trip',
                variant: CustomButtonVariant.outline,
                color: k_primary,
                icon: Icons.bookmark_add_outlined,
                onPressed: onAddToTrip,
                radius: 100,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Plan new trip',
                icon: Icons.flight_takeoff_rounded,
                onPressed: onPlanNew,
                radius: 100,
                gradient: k_gradAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
