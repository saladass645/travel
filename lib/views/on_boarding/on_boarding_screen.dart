import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:travel_app/components/custom_button.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/helpers/catch_storage.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/views/auth/login_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _ctrl = PageController();
  int _index = 0;

  static const _items = <_OnboardItem>[
    _OnboardItem(
      icon: Icons.explore_rounded,
      title: 'Discover hidden gems',
      subtitle:
          'Curated places, real stories and recommendations for every type of traveler.',
    ),
    _OnboardItem(
      icon: Icons.event_note_rounded,
      title: 'Plan day by day',
      subtitle:
          'Build itineraries, track budgets and keep every detail of your trip organised.',
    ),
    _OnboardItem(
      icon: Icons.photo_library_rounded,
      title: 'Capture every moment',
      subtitle:
          'Save memories, share journeys and look back on the adventures you\'ve had.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _items.length - 1;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 14, 0),
                child: TextButton(
                  onPressed: () async {
                    await CatchStorage.save(k_onBoardingKey, true);
                    await Get.off(() => LoginScreen());
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                physics: const BouncingScrollPhysics(),
                controller: _ctrl,
                itemCount: _items.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _OnboardSlide(item: _items[i]),
              ),
            ),
            SmoothPageIndicator(
              controller: _ctrl,
              count: _items.length,
              effect: ExpandingDotsEffect(
                spacing: 6,
                radius: 100,
                dotWidth: 8,
                dotHeight: 8,
                expansionFactor: 4,
                dotColor: AppColors.border,
                activeDotColor: k_primary,
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: k_pad),
              child: Row(
                children: [
                  if (_index > 0)
                    Expanded(
                      child: CustomButton(
                        text: 'Back',
                        variant: CustomButtonVariant.ghost,
                        color: AppColors.textMuted,
                        onPressed: () => _ctrl.previousPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                        ),
                      ),
                    ),
                  if (_index > 0) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: isLast ? 'Get started' : 'Continue',
                      icon: isLast
                          ? Icons.arrow_forward_rounded
                          : null,
                      radius: 100,
                      onPressed: () async {
                        if (isLast) {
                          await CatchStorage.save(k_onBoardingKey, true);
                          await Get.off(() => LoginScreen());
                        } else {
                          _ctrl.nextPage(
                            duration:
                                const Duration(milliseconds: 280),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _OnboardItem {
  const _OnboardItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
}

class _OnboardSlide extends StatelessWidget {
  const _OnboardSlide({required this.item});
  final _OnboardItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(k_pad, 0, k_pad, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200,
            height: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: k_gradHero,
              borderRadius: BorderRadius.circular(48),
              boxShadow: [
                BoxShadow(
                  color: k_primary.withOpacity(0.3),
                  blurRadius: 36,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Icon(item.icon, color: Colors.white, size: 84),
          ),
          const SizedBox(height: 40),
          DisplayText(item.title, maxLines: 3),
          const SizedBox(height: 14),
          BodyText(item.subtitle, maxLines: 4),
        ],
      ),
    );
  }
}
