import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/components/custom_button.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/trip_details.dart';
import 'package:travel_app/views/pickers/destination_picker.dart';

class CreateTripDialog extends StatefulWidget {
  const CreateTripDialog({Key? key, this.presetName}) : super(key: key);
  final String? presetName;

  @override
  State<CreateTripDialog> createState() => _CreateTripDialogState();
}

class _CreateTripDialogState extends State<CreateTripDialog> {
  final _name = TextEditingController();
  String? _destination;
  DateTime? _start;
  DateTime? _end;
  int _people = 1;
  bool _submitting = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.presetName != null) {
      _name.text = widget.presetName!;
      _destination = widget.presetName;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDestination() async {
    final picked = await DestinationPickerScreen.pick(
      context,
      initial: _destination,
    );
    if (picked != null) {
      setState(() {
        _destination = picked.displayValue;
        if (_name.text.isEmpty) _name.text = '${picked.label} trip';
      });
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      initialDateRange: _start != null && _end != null
          ? DateTimeRange(start: _start!, end: _end!)
          : null,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: k_primary,
            primary: k_primary,
            brightness: AppColors.isDark
                ? Brightness.dark
                : Brightness.light,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _start = picked.start;
        _end = picked.end;
      });
    }
  }

  String _dateLabel() {
    if (_start == null || _end == null) return 'Select trip dates';
    final f = DateFormat('MMM d');
    final ys = _start!.year;
    final ye = _end!.year;
    return ys == ye
        ? '${f.format(_start!)} - ${f.format(_end!)}, $ys'
        : '${f.format(_start!)}, $ys - ${f.format(_end!)}, $ye';
  }

  int get _dayCount {
    if (_start == null || _end == null) return 0;
    return _end!.difference(_start!).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(k_radLg),
        ),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: k_gradAccent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.flight_takeoff_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeadlineText('Plan a trip'),
                        SizedBox(height: 2),
                        MutedText('Just pick — we\'ll handle the rest'),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              _Tappable(
                icon: Icons.place_rounded,
                title: _destination ?? 'Choose destination',
                placeholder: _destination == null,
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: k_primary),
                onTap: _pickDestination,
              ),
              const SizedBox(height: 12),

              _Tappable(
                icon: Icons.calendar_today_rounded,
                title: _dateLabel(),
                placeholder: _start == null,
                trailing: _dayCount > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: CustomText(
                          text: '$_dayCount days',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: k_primary,
                        ),
                      )
                    : const Icon(Icons.chevron_right_rounded,
                        color: k_primary),
                onTap: _pickDateRange,
              ),
              const SizedBox(height: 12),

              _PeopleStepper(
                value: _people,
                onChanged: (v) => setState(() => _people = v),
              ),
              const SizedBox(height: 12),

              // Trip name (optional — auto-fills from destination)
              TextFormField(
                controller: _name,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Trip name (optional)',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  prefixIcon:
                      Icon(Icons.bookmark_outline_rounded,
                          color: AppColors.textMuted, size: 20),
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
                      height: 52,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: 'Create trip',
                      icon: Icons.check_rounded,
                      height: 52,
                      loading: _submitting,
                      onPressed: _canSubmit ? _submit : null,
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

  bool get _canSubmit =>
      _destination != null && _start != null && _end != null;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final c = Get.find<TripController>();
    final fmt = DateFormat('yyyy-MM-dd');
    final name = _name.text.trim().isEmpty
        ? '$_destination trip'
        : _name.text.trim();

    c.setTripName(name);
    c.setTripDestination(_destination!);
    c.setTripStartDate(fmt.format(_start!));
    c.setTripEndDate(fmt.format(_end!));
    c.setNumberOfPeople(_people);

    await c.addTrip();
    final added = c.tripList.isNotEmpty ? c.tripList.last : null;
    if (added?.id != null) {
      await c.updateTripDetails(
          added!.id!, TripDetails(numberOfPeople: _people));
    }
    if (mounted) Navigator.pop(context);
  }
}

class _Tappable extends StatelessWidget {
  const _Tappable({
    required this.icon,
    required this.title,
    required this.onTap,
    this.placeholder = false,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool placeholder;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(k_radSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(k_radSm),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
                child: Icon(icon, color: k_primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomText(
                  text: title,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: placeholder
                      ? AppColors.textMuted
                      : AppColors.textDark,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _PeopleStepper extends StatelessWidget {
  const _PeopleStepper({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
            child: const Icon(Icons.group_rounded,
                color: k_primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: 'Travelers',
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: '$value ${value == 1 ? "person" : "people"}',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ],
            ),
          ),
          _StepBtn(
            icon: Icons.remove_rounded,
            enabled: value > 1,
            onTap: () => onChanged(value - 1),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: CustomText(
              text: '$value',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          _StepBtn(
            icon: Icons.add_rounded,
            enabled: value < 20,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? k_primary : AppColors.field2,
            shape: BoxShape.circle,
          ),
          child: Icon(icon,
              color: enabled ? Colors.white : AppColors.textFaint,
              size: 18),
        ),
      ),
    );
  }
}
