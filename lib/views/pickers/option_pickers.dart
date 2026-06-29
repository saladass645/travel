import 'package:flutter/material.dart';
import 'package:travel_app/components/custom_button.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';

class _Option {
  const _Option({
    required this.value,
    required this.label,
    required this.icon,
  });
  final String value;
  final String label;
  final IconData icon;
}

/// Generic bottom-sheet picker. Returns the picked `value` or null on dismiss.
Future<String?> _pickFromSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required List<_Option> options,
  String? current,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(k_pad, 12, k_pad, 28),
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
            HeadlineText(title),
            const SizedBox(height: 4),
            MutedText(subtitle, maxLines: 2),
            const SizedBox(height: 18),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (_, i) {
                final opt = options[i];
                final selected = opt.value == current;
                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(k_radMd),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(k_radMd),
                    onTap: () => Navigator.of(ctx).pop(opt.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primarySoft : AppColors.field,
                        borderRadius: BorderRadius.circular(k_radMd),
                        border: Border.all(
                          color: selected
                              ? k_primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected
                                  ? k_primary
                                  : AppColors.surface,
                              shape: BoxShape.circle,
                              boxShadow: selected
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.04),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Icon(
                              opt.icon,
                              size: 22,
                              color:
                                  selected ? Colors.white : k_primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomText(
                            text: opt.label,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? k_primary
                                : AppColors.textDark,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

// ============================================================ travel method

class TravelMethodPicker {
  static const options = <_Option>[
    _Option(value: 'Flight', label: 'Flight', icon: Icons.flight_rounded),
    _Option(
        value: 'Car',
        label: 'Car',
        icon: Icons.directions_car_filled_rounded),
    _Option(
        value: 'Train',
        label: 'Train',
        icon: Icons.train_rounded),
    _Option(
        value: 'Bus',
        label: 'Bus',
        icon: Icons.directions_bus_rounded),
    _Option(
        value: 'Boat',
        label: 'Boat',
        icon: Icons.directions_boat_rounded),
    _Option(
        value: 'Walk',
        label: 'Walk',
        icon: Icons.directions_walk_rounded),
  ];

  static Future<String?> pick(BuildContext context, {String? current}) =>
      _pickFromSheet(
        context: context,
        title: 'How are you getting there?',
        subtitle: 'Choose your main mode of transport',
        options: options,
        current: current,
      );

  static IconData iconFor(String? value) {
    return options
            .firstWhere(
              (o) => o.value == value,
              orElse: () => options.first,
            )
            .icon;
  }
}

// ============================================================ accommodation

class AccommodationPicker {
  static const options = <_Option>[
    _Option(value: 'Hotel', label: 'Hotel', icon: Icons.hotel_rounded),
    _Option(
        value: 'Hostel',
        label: 'Hostel',
        icon: Icons.bedroom_parent_rounded),
    _Option(
        value: 'Airbnb',
        label: 'Airbnb',
        icon: Icons.house_rounded),
    _Option(
        value: 'Resort',
        label: 'Resort',
        icon: Icons.pool_rounded),
    _Option(
        value: 'Camping',
        label: 'Camping',
        icon: Icons.forest_rounded),
    _Option(
        value: 'With family',
        label: 'Family',
        icon: Icons.groups_rounded),
  ];

  static Future<String?> pick(BuildContext context, {String? current}) =>
      _pickFromSheet(
        context: context,
        title: 'Where will you stay?',
        subtitle: 'Pick the type of accommodation',
        options: options,
        current: current,
      );

  static IconData iconFor(String? value) {
    return options
            .firstWhere(
              (o) => o.value == value,
              orElse: () => options.first,
            )
            .icon;
  }
}

// ============================================================ budget

class BudgetTier {
  const BudgetTier(this.label, this.amount, this.icon);
  final String label;
  final double amount;
  final IconData icon;
}

class BudgetPicker {
  static const tiers = <BudgetTier>[
    BudgetTier('Budget', 500, Icons.savings_rounded),
    BudgetTier('Comfort', 1500, Icons.travel_explore_rounded),
    BudgetTier('Premium', 3500, Icons.diamond_rounded),
    BudgetTier('Luxury', 7000, Icons.workspace_premium_rounded),
  ];

  static Future<double?> pick(BuildContext context, {double? current}) {
    final initial =
        current ?? tiers[1].amount; // default to "Comfort"
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BudgetSheet(initial: initial),
    );
  }
}

class _BudgetSheet extends StatefulWidget {
  const _BudgetSheet({required this.initial});
  final double initial;

  @override
  State<_BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends State<_BudgetSheet> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initial.clamp(0, 20000);
  }

  BudgetTier? get _tierFor {
    BudgetTier? best;
    for (final t in BudgetPicker.tiers) {
      if (_value >= t.amount * 0.6 && _value <= t.amount * 1.4) {
        best = t;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(k_pad, 12, k_pad, 24),
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
          const HeadlineText('Set your trip budget'),
          const SizedBox(height: 4),
          const MutedText(
              'Pick a tier or fine-tune with the slider', maxLines: 2),
          const SizedBox(height: 22),
          // big amount readout
          Center(
            child: Column(
              children: [
                CustomText(
                  text: '\$${_value.toStringAsFixed(0)}',
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: k_primary,
                  letterSpacing: -1,
                ),
                const SizedBox(height: 4),
                if (_tierFor != null)
                  CustomText(
                    text: _tierFor!.label.toUpperCase(),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 1.4,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: k_primary,
              inactiveTrackColor: AppColors.field2,
              thumbColor: k_primary,
              overlayColor: k_primary.withOpacity(0.18),
              trackHeight: 6,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 22),
            ),
            child: Slider(
              value: _value,
              min: 100,
              max: 20000,
              divisions: 199,
              onChanged: (v) => setState(() => _value = v),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MutedText('\$100'),
                MutedText('\$20,000'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: BudgetPicker.tiers.map((t) {
              final selected = _tierFor?.label == t.label;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(k_radSm),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(k_radSm),
                      onTap: () => setState(() => _value = t.amount),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primarySoft
                              : AppColors.field,
                          borderRadius: BorderRadius.circular(k_radSm),
                          border: Border.all(
                            color: selected ? k_primary : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(t.icon,
                                size: 18,
                                color: selected
                                    ? k_primary
                                    : AppColors.textMuted),
                            const SizedBox(height: 4),
                            CustomText(
                              text: t.label,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? k_primary
                                  : AppColors.textBody,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          CustomButton(
            text: 'Set budget',
            icon: Icons.check_rounded,
            width: double.infinity,
            radius: 100,
            onPressed: () => Navigator.of(context).pop(_value),
          ),
        ],
      ),
    );
  }
}
