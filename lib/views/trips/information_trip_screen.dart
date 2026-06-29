import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_button.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/components/glass_chip.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/views/trips/edit_trip_sheet.dart';
import 'package:travel_app/views/trips/invite_screen.dart';
import 'package:travel_app/views/trips/manage_trip_screen.dart';

class InformationTripScreen extends StatefulWidget {
  const InformationTripScreen({Key? key, required this.trip}) : super(key: key);
  final Trip trip;

  @override
  State<InformationTripScreen> createState() => _InformationTripScreenState();
}

class _InformationTripScreenState extends State<InformationTripScreen> {
  final TripController c = Get.find<TripController>();

  @override
  void initState() {
    super.initState();
    if (widget.trip.id != null) {
      c.getTripDetails(c.uid, widget.trip.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: GetBuilder<TripController>(
        builder: (_) {
          final trip = c.tripList.firstWhereOrNull(
                  (t) => t.id == widget.trip.id) ??
              widget.trip;
          final people = trip.details?.numberOfPeople ?? 1;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _Hero(trip: trip, c: c)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(k_pad, 24, k_pad, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(child: OverlineText('AT A GLANCE')),
                          _EditDetailsChip(
                            onTap: () => EditTripDetailsSheet.show(
                                context, trip),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SummaryGrid(trip: trip, people: people),
                      const SizedBox(height: 28),
                      const OverlineText('ABOUT THIS TRIP'),
                      const SizedBox(height: 10),
                      BodyText(
                        trip.details?.extraNotes?.isNotEmpty == true
                            ? trip.details!.extraNotes!
                            : 'No notes added yet. Tap "Edit" above to add transport, stay, budget, and notes.',
                        maxLines: 10,
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: people > 1
                            ? 'Invite travelers'
                            : 'Open trip planner',
                        icon: people > 1
                            ? Icons.group_add_rounded
                            : Icons.dashboard_rounded,
                        width: double.infinity,
                        radius: 100,
                        onPressed: () {
                          if (people > 1) {
                            Get.to(() => InviteScreen(trip: trip));
                          } else {
                            Get.to(
                                () => ManageTripScreen(trip: trip));
                          }
                        },
                      ),
                      if (people > 1) ...[
                        const SizedBox(height: 12),
                        CustomButton(
                          text: 'Skip — Manage trip',
                          variant: CustomButtonVariant.outline,
                          color: k_primary,
                          width: double.infinity,
                          radius: 100,
                          onPressed: () => Get.to(
                              () => ManageTripScreen(trip: trip)),
                        ),
                      ],
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EditDetailsChip extends StatelessWidget {
  const _EditDetailsChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit_rounded, color: k_primary, size: 14),
              const SizedBox(width: 6),
              CustomText(
                text: 'Edit',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: k_primary,
                letterSpacing: 0.4,
              ),
            ],
          ),
        ),
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
          EdgeInsets.fromLTRB(k_pad, mq.padding.top + 14, k_pad, 30),
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
              CircleIconButton(
                icon: Icons.ios_share_rounded,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              const Icon(Icons.place_rounded,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              CustomText(
                text: trip.destination ?? '',
                fontSize: 13,
                color: Colors.white.withOpacity(0.85),
              ),
            ],
          ),
          const SizedBox(height: 6),
          CustomText(
            text: trip.name ?? '',
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            height: 1.1,
            textAlign: TextAlign.start,
            maxLines: 3,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              GlassChip(
                label: c.formatDateRange(trip),
                icon: Icons.calendar_today_rounded,
              ),
              const SizedBox(width: 8),
              GlassChip(
                label: '${c.tripDayCount(trip)} days',
                icon: Icons.schedule_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.trip, required this.people});
  final Trip trip;
  final int people;

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryItem(Icons.group_rounded, 'Travelers', '$people', k_primary),
      _SummaryItem(Icons.directions_car_filled_rounded, 'Transport',
          trip.details?.travelMethod ?? '—', k_accent),
      _SummaryItem(Icons.hotel_rounded, 'Stay',
          trip.details?.accommodation ?? '—', const Color(0xFF6C5CE7)),
      _SummaryItem(
        Icons.account_balance_wallet_rounded,
        'Budget',
        trip.details?.budget != null
            ? '\$${trip.details!.budget!.toStringAsFixed(0)}'
            : '—',
        k_amber,
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.1,
      ),
      itemBuilder: (_, i) => items[i],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem(this.icon, this.label, this.value, this.tint);
  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(k_radMd),
        boxShadow: k_shadowCard,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tint, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: label,
                  fontSize: 11,
                  color: AppColors.textMuted,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: value,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
