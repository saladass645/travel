import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/components/custom_button.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/trip_details.dart';

class CreateTripDialog extends StatefulWidget {
  const CreateTripDialog({Key? key, this.presetName}) : super(key: key);
  final String? presetName;

  @override
  State<CreateTripDialog> createState() => _CreateTripDialogState();
}

class _CreateTripDialogState extends State<CreateTripDialog> {
  final _name = TextEditingController();
  final _destination = TextEditingController();
  final _start = TextEditingController();
  final _end = TextEditingController();
  final _people = TextEditingController(text: '1');
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.presetName != null) _name.text = widget.presetName!;
  }

  @override
  void dispose() {
    _name.dispose();
    _destination.dispose();
    _start.dispose();
    _end.dispose();
    _people.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController target) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2101),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: k_primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      target.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        HeadlineText('New trip'),
                        SizedBox(height: 2),
                        MutedText('Fill in a few quick details'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _field(_name, 'Trip name', Icons.label_outline_rounded),
              const SizedBox(height: 12),
              _field(_destination, 'Destination',
                  Icons.location_on_outlined),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _start,
                      'Start',
                      Icons.calendar_today_rounded,
                      readOnly: true,
                      onTap: () => _pickDate(_start),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(
                      _end,
                      'End',
                      Icons.event_rounded,
                      readOnly: true,
                      onTap: () => _pickDate(_end),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field(
                _people,
                'Travelers',
                Icons.group_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1) return 'Must be at least 1';
                  return null;
                },
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      variant: CustomButtonVariant.ghost,
                      color: AppColors.textMuted,
                      onPressed: () => Navigator.pop(context),
                      height: 50,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: 'Create trip',
                      loading: _submitting,
                      onPressed: _submit,
                      height: 50,
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

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: c,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      validator: validator ??
          (v) => (v == null || v.isEmpty) ? 'Required' : null,
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textDark,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 44, minHeight: 44),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final c = Get.find<TripController>();
    final people = int.tryParse(_people.text) ?? 1;
    c.setTripName(_name.text);
    c.setTripDestination(_destination.text);
    c.setTripStartDate(_start.text);
    c.setTripEndDate(_end.text);
    c.setNumberOfPeople(people);
    await c.addTrip();
    final added = c.tripList.isNotEmpty ? c.tripList.last : null;
    if (added?.id != null) {
      await c.updateTripDetails(
          added!.id!, TripDetails(numberOfPeople: people));
    }
    if (mounted) Navigator.pop(context);
  }
}
