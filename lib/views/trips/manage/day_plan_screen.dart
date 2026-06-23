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
    final titleC = TextEditingController();
    final timeC = TextEditingController(text: '09:00');
    final locC = TextEditingController();
    final noteC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(k_radLg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeadlineText('Add to day $_activeDay'),
              const SizedBox(height: 14),
              TextField(
                controller: titleC,
                style: TextStyle(color: AppColors.textDark, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Activity',
                  prefixIcon: Icon(Icons.bolt_rounded, size: 18),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeC,
                style: TextStyle(color: AppColors.textDark, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Time (HH:mm)',
                  prefixIcon: Icon(Icons.schedule_rounded, size: 18),
                ),
                onTap: () async {
                  final t = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay.now(),
                  );
                  if (t != null) {
                    timeC.text =
                        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                  }
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locC,
                style: TextStyle(color: AppColors.textDark, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Location (optional)',
                  prefixIcon:
                      Icon(Icons.place_outlined, size: 18),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteC,
                style: TextStyle(color: AppColors.textDark, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Note (optional)',
                  prefixIcon: Icon(Icons.notes_rounded, size: 18),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      variant: CustomButtonVariant.ghost,
                      color: AppColors.textMuted,
                      height: 48,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: 'Add',
                      height: 48,
                      onPressed: () {
                        if (titleC.text.trim().isEmpty) return;
                        c.addDayPlanItem(DayPlanItem(
                          tripId: widget.trip.id ?? '',
                          day: _activeDay,
                          time: timeC.text,
                          title: titleC.text.trim(),
                          location:
                              locC.text.isEmpty ? null : locC.text,
                          note: noteC.text.isEmpty ? null : noteC.text,
                        ));
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
