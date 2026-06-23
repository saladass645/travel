import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/components/glass_chip.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/views/trips/create_trip_dialog.dart';
import 'package:travel_app/views/trips/information_trip_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({Key? key}) : super(key: key);

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TripController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: GetBuilder<TripController>(
        builder: (_) {
          final ongoing = c.ongoingTrips;
          final past = c.pastTrips;
          final trips = _tab == 0 ? ongoing : past;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _MyTripsHeader(
                  ongoingCount: ongoing.length,
                  pastCount: past.length,
                ),
              ),
              SliverToBoxAdapter(
                child: _TripsTabs(
                  active: _tab,
                  onTap: (i) => setState(() => _tab = i),
                  ongoing: ongoing.length,
                  past: past.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (trips.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    isPast: _tab == 1,
                    onCreate: () => showDialog(
                      context: context,
                      builder: (_) => const CreateTripDialog(),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(k_pad, 0, k_pad, 130),
                  sliver: SliverList.separated(
                    itemCount: trips.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 14),
                    itemBuilder: (_, i) => _TripCard(trip: trips[i]),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 78),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () => showDialog(
              context: context,
              builder: (_) => const CreateTripDialog(),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: k_gradAccent,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: k_accent.withOpacity(0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 22, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  CustomText(
                    text: 'New trip',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MyTripsHeader extends StatelessWidget {
  const _MyTripsHeader({required this.ongoingCount, required this.pastCount});
  final int ongoingCount;
  final int pastCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          k_pad, MediaQuery.of(context).padding.top + 22, k_pad, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                OverlineText('YOUR JOURNEYS'),
                SizedBox(height: 6),
                DisplayText('My Trips'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                const Icon(Icons.flight_takeoff_rounded,
                    color: k_primary, size: 16),
                const SizedBox(width: 6),
                CustomText(
                  text: '${ongoingCount + pastCount} trips',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: k_primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripsTabs extends StatelessWidget {
  const _TripsTabs({
    required this.active,
    required this.onTap,
    required this.ongoing,
    required this.past,
  });
  final int active;
  final ValueChanged<int> onTap;
  final int ongoing;
  final int past;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: k_pad),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          _TabBtn(
              label: 'Ongoing',
              count: ongoing,
              selected: active == 0,
              onTap: () => onTap(0)),
          _TabBtn(
              label: 'Past',
              count: past,
              selected: active == 1,
              onTap: () => onTap(1)),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  const _TabBtn({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.textDark : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: label,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textBody,
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(0.18)
                      : AppColors.field2,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: CustomText(
                  text: '$count',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isPast, required this.onCreate});
  final bool isPast;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                gradient: k_gradPrimary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.luggage_rounded,
                  color: Colors.white, size: 44),
            ),
            const SizedBox(height: 22),
            CustomText(
              text: isPast
                  ? 'No completed trips yet'
                  : 'Your adventure starts here',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: isPast
                  ? 'Trips you\'ve finished will appear here as memories.'
                  : 'Plan your first journey and we\'ll help you organize every detail.',
              fontSize: 13,
              color: AppColors.textMuted,
              maxLines: 3,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TripController>();
    return GestureDetector(
      onTap: () => Get.to(() => InformationTripScreen(trip: trip)),
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: k_shadowCard,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(gradient: k_gradPrimary),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0.32,
                  child: CustomPaint(painter: _TopoPainter()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const GlassChip(
                          label: 'TRIP',
                          icon: Icons.flight_rounded,
                        ),
                        const Spacer(),
                        CircleIconButton(
                          icon: Icons.more_horiz_rounded,
                          size: 36,
                          onTap: () =>
                              _showMenu(context, c),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: trip.destination ?? '',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.85),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          text: trip.name ?? '',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            GlassChip(
                              label: c.formatDateRange(trip),
                              icon: Icons.calendar_today_rounded,
                            ),
                            const SizedBox(width: 8),
                            GlassChip(
                              label:
                                  '${c.tripDayCount(trip)} days',
                              icon: Icons.schedule_rounded,
                            ),
                          ],
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

  void _showMenu(BuildContext context, TripController c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading:
                  const Icon(Icons.open_in_new_rounded, color: k_primary),
              title: const TitleText('Open trip'),
              onTap: () {
                Navigator.pop(ctx);
                Get.to(() => InformationTripScreen(trip: trip));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: k_error),
              title:
                  const TitleText('Delete trip', color: k_error),
              onTap: () {
                Navigator.pop(ctx);
                c.deleteTrip(trip.id!);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _TopoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 6; i++) {
      final path = Path()
        ..moveTo(-20, size.height * (0.2 + i * 0.12))
        ..quadraticBezierTo(
          size.width * 0.5,
          size.height * (0.1 + i * 0.12),
          size.width + 20,
          size.height * (0.25 + i * 0.12),
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
