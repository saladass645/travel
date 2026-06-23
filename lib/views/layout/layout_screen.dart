import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/controllers/layout/layout_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/views/account/account_screen.dart';
import 'package:travel_app/views/discovery/discovery_screen.dart';
import 'package:travel_app/views/trips/my_trips_screen.dart';

class LayoutScreen extends GetWidget<LayoutController> {
  const LayoutScreen({Key? key}) : super(key: key);

  static const _items = <_NavItem>[
    _NavItem(
      label: 'Discover',
      icon: Icons.explore_outlined,
      iconActive: Icons.explore_rounded,
    ),
    _NavItem(
      label: 'Trips',
      icon: Icons.flight_takeoff_outlined,
      iconActive: Icons.flight_takeoff_rounded,
    ),
    _NavItem(
      label: 'Account',
      icon: Icons.person_outline_rounded,
      iconActive: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.bg,
      body: GetBuilder<LayoutController>(
        builder: (controller) {
          return IndexedStack(
            index: controller.index,
            children: const [
              DiscoveryScreen(),
              MyTripsScreen(),
              AccountScreen(),
            ],
          );
        },
      ),
      bottomNavigationBar: GetBuilder<LayoutController>(
        builder: (c) => _FloatingNavBar(
          active: c.index,
          onTap: c.onTapChange,
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.iconActive,
  });
  final String label;
  final IconData icon;
  final IconData iconActive;
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({required this.active, required this.onTap});
  final int active;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, mq.padding.bottom + 12),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(LayoutScreen._items.length, (i) {
            final item = LayoutScreen._items[i];
            final selected = i == active;
            return _NavButton(
              item: item,
              selected: selected,
              onTap: () => onTap(i),
            );
          }),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 18 : 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            gradient: selected ? k_gradPrimary : null,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.iconActive : item.icon,
                color: selected ? Colors.white : AppColors.textMuted,
                size: 22,
              ),
              if (selected) ...[
                const SizedBox(width: 8),
                CustomText(
                  text: item.label,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
