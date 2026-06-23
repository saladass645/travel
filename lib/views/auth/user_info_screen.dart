import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_button.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/network/database_service.dart';
import 'package:travel_app/views/layout/layout_screen.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  static const _interestOptions = [
    'Beaches',
    'Mountains',
    'City life',
    'Food',
    'History',
    'Nature',
    'Adventure',
    'Culture',
    'Nightlife',
    'Wellness',
  ];

  static const _styleOptions = ['Solo', 'Couple', 'Family', 'Group'];
  static const _budgetOptions = ['Budget', 'Mid-range', 'Luxury'];

  final Set<String> _interests = {};
  String _style = 'Solo';
  String _budget = 'Mid-range';
  int _step = 0;
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await DatabaseService.instance.saveUserOnboarding(
        interests: _interests.toList(),
        travelStyle: _style,
        preferredBudget: _budget,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    }
    if (mounted) Get.offAll(() => const LayoutScreen());
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_interestsPage(), _stylePage(), _budgetPage()];
    final isLast = _step == pages.length - 1;
    final canAdvance = _stepReady;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(k_pad, 16, k_pad, 22),
          child: Column(
            children: [
              Row(
                children: [
                  if (_step > 0)
                    GestureDetector(
                      onTap: () => setState(() => _step--),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: k_shadowCard,
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: AppColors.textDark),
                      ),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () => Get.offAll(() => const LayoutScreen()),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StepIndicator(total: pages.length, active: _step),
              const SizedBox(height: 28),
              Expanded(child: pages[_step]),
              CustomButton(
                text: _submitting
                    ? '...'
                    : (isLast ? 'Finish' : 'Continue'),
                icon: isLast
                    ? Icons.check_rounded
                    : Icons.arrow_forward_rounded,
                width: double.infinity,
                radius: 100,
                onPressed: !canAdvance || _submitting
                    ? null
                    : () {
                        if (isLast) {
                          _submit();
                        } else {
                          setState(() => _step++);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _stepReady {
    switch (_step) {
      case 0:
        return _interests.isNotEmpty;
      default:
        return true;
    }
  }

  Widget _interestsPage() {
    return _Page(
      eyebrow: 'STEP 1',
      title: 'What are you into?',
      subtitle: 'Pick a few — we use this to tailor recommendations.',
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _interestOptions.map((opt) {
            final selected = _interests.contains(opt);
            return _Chip(
              label: opt,
              selected: selected,
              onTap: () => setState(() {
                if (selected) {
                  _interests.remove(opt);
                } else {
                  _interests.add(opt);
                }
              }),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _stylePage() {
    return _Page(
      eyebrow: 'STEP 2',
      title: 'How do you travel?',
      subtitle: 'Your usual travel style helps us match the right places.',
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: _styleOptions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final s = _styleOptions[i];
          return _Option(
            label: s,
            selected: _style == s,
            onTap: () => setState(() => _style = s),
          );
        },
      ),
    );
  }

  Widget _budgetPage() {
    return _Page(
      eyebrow: 'STEP 3',
      title: 'What\'s your budget?',
      subtitle: 'We\'ll match suggestions to your range.',
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: _budgetOptions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final b = _budgetOptions[i];
          return _Option(
            label: b,
            selected: _budget == b,
            onTap: () => setState(() => _budget = b),
          );
        },
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OverlineText(eyebrow),
        const SizedBox(height: 8),
        DisplayText(title),
        const SizedBox(height: 10),
        BodyText(subtitle, maxLines: 3),
        const SizedBox(height: 24),
        Expanded(child: child),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.total, required this.active});
  final int total;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isActive = i <= active;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 5,
            decoration: BoxDecoration(
              gradient: isActive ? k_gradPrimary : null,
              color: isActive ? null : AppColors.field,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: selected ? k_gradPrimary : null,
            color: selected ? null : AppColors.field,
            borderRadius: BorderRadius.circular(100),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: k_primary.withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: CustomText(
            text: label,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.textBody,
          ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(k_radMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(k_radMd),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : Colors.white,
            borderRadius: BorderRadius.circular(k_radMd),
            border: Border.all(
              color: selected ? k_primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected ? null : k_shadowCard,
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? k_primary : AppColors.field2,
                ),
                child: selected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: CustomText(
                  text: label,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? k_primary : AppColors.textDark,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
