import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_button.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/trip_extras.dart';
import 'package:travel_app/models/trip_model.dart';

class DayPlanScreen extends StatefulWidget {
  const DayPlanScreen({Key? key, required this.trip}) : super(key: key);
  final Trip trip;

  @override
  State<DayPlanScreen> createState() => _DayPlanScreenState();
}

class _DayPlanScreenState extends State<DayPlanScreen> {
  final TripController c = Get.find<TripController>();
  late int _activeDay;
  late int _dayCount;

  @override
  void initState() {
    super.initState();
    _dayCount = c.tripDayCount(widget.trip);
    _activeDay = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const TitleText('Day plan'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 88,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: k_pad),
              scrollDirection: Axis.horizontal,
              itemCount: _dayCount,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final day = i + 1;
                final selected = day == _activeDay;
                return GestureDetector(
                  onTap: () => setState(() => _activeDay = day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 64,
                    decoration: BoxDecoration(
                      gradient: selected ? k_gradPrimary : null,
                      color: selected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: selected ? null : k_shadowCard,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: 'DAY',
                          fontSize: 9,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white.withOpacity(0.7)
                              : AppColors.textMuted,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          text: '$day',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: selected ? Colors.white : AppColors.textDark,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GetBuilder<TripController>(
              builder: (_) {
                final items = c.dayPlanFor(widget.trip.id ?? '', _activeDay);
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
                              gradient: k_gradPrimary,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                                Icons.calendar_month_rounded,
                                color: Colors.white,
                                size: 40),
                          ),
                          const SizedBox(height: 18),
                          HeadlineText('Nothing planned for day $_activeDay'),
                          const SizedBox(height: 6),
                          const MutedText(
                            'Tap the button to add an activity to this day.',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding:
                      const EdgeInsets.fromLTRB(k_pad, 8, k_pad, 120),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ActivityCard(
                    item: items[i],
                    isLast: i == items.length - 1,
                    onDelete: () => c.removeDayPlanItem(items[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: _showAddDialog,
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
                  horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  CustomText(
                    text: 'Add activity',
                    fontSize: 13,
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

  void _showAddDialog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddActivitySheet(
        trip: widget.trip,
        day: _activeDay,
        onSubmit: (item) => c.addDayPlanItem(item),
      ),
    );
  }
}

// ============================================================ add sheet

class _Template {
  const _Template(this.title, this.icon, this.suggestedTime);
  final String title;
  final IconData icon;
  final String suggestedTime;
}

const _activityTemplates = <_Template>[
  _Template('Breakfast', Icons.coffee_rounded, '08:00'),
  _Template('Sightseeing', Icons.photo_camera_rounded, '10:00'),
  _Template('Lunch', Icons.lunch_dining_rounded, '12:30'),
  _Template('Activity', Icons.local_activity_rounded, '14:00'),
  _Template('Shopping', Icons.shopping_bag_rounded, '15:30'),
  _Template('Dinner', Icons.restaurant_rounded, '19:00'),
  _Template('Free time', Icons.beach_access_rounded, '17:00'),
  _Template('Transit', Icons.directions_bus_rounded, '09:00'),
];

class _AddActivitySheet extends StatefulWidget {
  const _AddActivitySheet({
    required this.trip,
    required this.day,
    required this.onSubmit,
  });
  final Trip trip;
  final int day;
  final void Function(DayPlanItem) onSubmit;

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  final _noteCtrl = TextEditingController();
  String? _title;
  String? _location;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  String get _timeLabel =>
      '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _applyTemplate(_Template t) {
    setState(() {
      _title = t.title;
      _location = null;
      final parts = t.suggestedTime.split(':');
      _time = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    });
  }

  void _applyCollection(String place) {
    setState(() {
      _title = 'Visit $place';
      _location = place;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TripController>();
    final mq = MediaQuery.of(context);
    final collection = c.collectionFor(widget.trip.id ?? '');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          k_pad, 12, k_pad, mq.viewInsets.bottom + 24),
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
          HeadlineText('Add to day ${widget.day}'),
          const SizedBox(height: 4),
          const MutedText('Pick a template or saved place — no typing required'),
          const SizedBox(height: 18),

          const OverlineText('QUICK ADD'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _activityTemplates.map((t) {
              final selected = _title == t.title;
              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () => _applyTemplate(t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primarySoft
                          : AppColors.field,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: selected ? k_primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.icon,
                            size: 15,
                            color: selected
                                ? k_primary
                                : AppColors.textBody),
                        const SizedBox(width: 6),
                        CustomText(
                          text: t.title,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? k_primary
                              : AppColors.textBody,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          if (collection.isNotEmpty) ...[
            const SizedBox(height: 22),
            const OverlineText('FROM YOUR COLLECTION'),
            const SizedBox(height: 10),
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: collection.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final tour = collection[i].tour;
                  final name = tour.title ?? 'Place';
                  final selected = _location == name;
                  return Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(k_radSm),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(k_radSm),
                      onTap: () => _applyCollection(name),
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primarySoft
                              : AppColors.field,
                          borderRadius: BorderRadius.circular(k_radSm),
                          border: Border.all(
                            color: selected
                                ? k_primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bookmark_rounded,
                                size: 16,
                                color: selected
                                    ? k_primary
                                    : AppColors.textMuted),
                            const SizedBox(height: 6),
                            CustomText(
                              text: name,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? k_primary
                                  : AppColors.textDark,
                              maxLines: 2,
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(k_radSm),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(k_radSm),
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.field,
                        borderRadius: BorderRadius.circular(k_radSm),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.schedule_rounded,
                                color: k_primary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: 'TIME',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                                letterSpacing: 1.0,
                              ),
                              const SizedBox(height: 2),
                              CustomText(
                                text: _timeLabel,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          TextField(
            controller: _noteCtrl,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Note (optional)',
              hintStyle: TextStyle(color: AppColors.textMuted),
              prefixIcon: Icon(Icons.notes_rounded,
                  color: AppColors.textMuted, size: 18),
              filled: true,
              fillColor: AppColors.field,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(k_radSm),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Cancel',
                  variant: CustomButtonVariant.ghost,
                  color: AppColors.textMuted,
                  height: 50,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: 'Add to plan',
                  icon: Icons.check_rounded,
                  height: 50,
                  onPressed: _title == null
                      ? null
                      : () {
                          widget.onSubmit(DayPlanItem(
                            tripId: widget.trip.id ?? '',
                            day: widget.day,
                            time: _timeLabel,
                            title: _title!,
                            location: _location,
                            note: _noteCtrl.text.trim().isEmpty
                                ? null
                                : _noteCtrl.text.trim(),
                          ));
                          Navigator.pop(context);
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.item,
    required this.isLast,
    required this.onDelete,
  });
  final DayPlanItem item;
  final bool isLast;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: k_primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: k_shadowCard,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(k_radMd),
                boxShadow: k_shadowCard,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomText(
                          text: item.time,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: k_primary,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onDelete,
                        child: Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TitleText(item.title, maxLines: 2),
                  if (item.location != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.place_outlined,
                            size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Flexible(
                          child: MutedText(item.location!, maxLines: 1),
                        ),
                      ],
                    ),
                  ],
                  if (item.note != null) ...[
                    const SizedBox(height: 6),
                    MutedText(item.note!, maxLines: 3),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
