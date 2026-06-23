import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/controllers/theme_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/views/profile/change_language_screen.dart';
import 'package:travel_app/views/profile/currency_converter_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _push = true;
  bool _email = false;

  @override
  Widget build(BuildContext context) {
    final themeC = Get.find<ThemeController>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const TitleText('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(k_pad, 4, k_pad, 40),
        children: [
          _Section(title: 'PREFERENCES', children: [
            _NavTile(
              icon: Icons.language_rounded,
              label: 'Language',
              onTap: () => Get.to(() => ChangeLanguageScreen()),
            ),
            _NavTile(
              icon: Icons.currency_exchange_rounded,
              label: 'Currency converter',
              onTap: () => Get.to(() => CurrencyConverterScreen()),
            ),
            GetBuilder<ThemeController>(
              builder: (_) => _SwitchTile(
                icon: AppColors.isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                label: 'Dark mode',
                value: themeC.isDark,
                onChanged: (v) => themeC.setDark(v),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          _Section(title: 'NOTIFICATIONS', children: [
            _SwitchTile(
              icon: Icons.notifications_rounded,
              label: 'Push notifications',
              value: _push,
              onChanged: (v) => setState(() => _push = v),
            ),
            _SwitchTile(
              icon: Icons.email_rounded,
              label: 'Email updates',
              value: _email,
              onChanged: (v) => setState(() => _email = v),
            ),
          ]),
          const SizedBox(height: 14),
          _Section(title: 'SECURITY', children: [
            _NavTile(
              icon: Icons.lock_rounded,
              label: 'Account security',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              ),
            ),
            _NavTile(
              icon: Icons.help_outline_rounded,
              label: 'Help & support',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: OverlineText(title),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(k_radMd),
            boxShadow: k_shadowCard,
          ),
          child: Column(
            children: List.generate(children.length, (i) {
              if (i == children.length - 1) return children[i];
              return Column(
                children: [
                  children[i],
                  Divider(height: 1, color: AppColors.border, indent: 56),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(k_radMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: k_primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: k_primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CustomText(
                text: label,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                textAlign: TextAlign.start,
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textFaint, size: 22),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: k_primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: k_primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: CustomText(
              text: label,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              textAlign: TextAlign.start,
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: k_primary,
          ),
        ],
      ),
    );
  }
}
