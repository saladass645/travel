import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_button.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/trip_details.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/views/pickers/option_pickers.dart';

class EditTripDetailsSheet extends StatefulWidget {
  const EditTripDetailsSheet({Key? key, required this.trip}) : super(key: key);
  final Trip trip;

  static Future<void> show(BuildContext context, Trip trip) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditTripDetailsSheet(trip: trip),
    );
  }

  @override
  State<EditTripDetailsSheet> createState() => _EditTripDetailsSheetState();
}

class _EditTripDetailsSheetState extends State<EditTripDetailsSheet> {
  String? _travelMethod;
  String? _accommodation;
  double? _budget;
  String? _notes;
  late TextEditingController _notesCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.trip.details;
    _travelMethod = d?.travelMethod;
    _accommodation = d?.accommodation;
    _budget = d?.budget;
    _notes = d?.extraNotes;
    _notesCtrl = TextEditingController(text: _notes ?? '');
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
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
          const HeadlineText('Trip details'),
          const SizedBox(height: 4),
          const MutedText('Tap any row to update', maxLines: 1),
          const SizedBox(height: 18),
          _PickerRow(
            label: 'Transport',
            value: _travelMethod ?? 'Choose a method',
            icon: TravelMethodPicker.iconFor(_travelMethod),
            placeholder: _travelMethod == null,
            onTap: () async {
              final picked = await TravelMethodPicker.pick(
                context,
                current: _travelMethod,
              );
              if (picked != null) setState(() => _travelMethod = picked);
            },
          ),
          const SizedBox(height: 10),
          _PickerRow(
            label: 'Stay',
            value: _accommodation ?? 'Pick where you\'ll stay',
            icon: AccommodationPicker.iconFor(_accommodation),
            placeholder: _accommodation == null,
            onTap: () async {
              final picked = await AccommodationPicker.pick(
                context,
                current: _accommodation,
              );
              if (picked != null) setState(() => _accommodation = picked);
            },
          ),
          const SizedBox(height: 10),
          _PickerRow(
            label: 'Budget',
            value: _budget == null
                ? 'Set a trip budget'
                : '\$${_budget!.toStringAsFixed(0)}',
            icon: Icons.account_balance_wallet_rounded,
            placeholder: _budget == null,
            onTap: () async {
              final picked = await BudgetPicker.pick(
                context,
                current: _budget,
              );
              if (picked != null) setState(() => _budget = picked);
            },
          ),
          const SizedBox(height: 18),
          CustomText(
            text: 'NOTES',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: AppColors.textMuted,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            minLines: 2,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Anything extra worth remembering…',
              hintStyle: TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.field,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(k_radSm),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 22),
          CustomButton(
            text: 'Save changes',
            icon: Icons.check_rounded,
            width: double.infinity,
            radius: 100,
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final tripId = widget.trip.id;
    if (tripId == null) {
      Navigator.pop(context);
      return;
    }
    setState(() => _saving = true);
    final c = Get.find<TripController>();
    final details = TripDetails(
      travelMethod: _travelMethod,
      accommodation: _accommodation,
      budget: _budget,
      numberOfPeople: widget.trip.details?.numberOfPeople ?? 1,
      extraNotes: _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
    );
    await c.updateTripDetails(tripId, details);
    if (mounted) Navigator.pop(context);
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    required this.placeholder,
  });
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool placeholder;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(k_radSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(k_radSm),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(k_radSm),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: placeholder
                      ? AppColors.surface
                      : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon,
                    color: placeholder ? AppColors.textMuted : k_primary,
                    size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: label,
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      text: value,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: placeholder
                          ? AppColors.textMuted
                          : AppColors.textDark,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
