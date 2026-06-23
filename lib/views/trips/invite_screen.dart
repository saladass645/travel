import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_button.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/views/trips/manage_trip_screen.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({Key? key, required this.trip}) : super(key: key);
  final Trip trip;

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final _email = TextEditingController();
  final TripController c = Get.find<TripController>();

  String get _shareLink =>
      'https://voyage.app/join/${widget.trip.id ?? ''}';

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
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
        title: const TitleText('Invite travelers'),
        centerTitle: false,
      ),
      body: GetBuilder<TripController>(
        builder: (_) {
          final invited = c.invitesFor(widget.trip.id ?? '');
          return Padding(
            padding: const EdgeInsets.fromLTRB(k_pad, 4, k_pad, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(k_radMd),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.group_add_rounded,
                            color: k_primary),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleText('Travel together'),
                            SizedBox(height: 2),
                            MutedText(
                              'Invite friends so everyone can plan and contribute.',
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const OverlineText('INVITE BY EMAIL'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textDark),
                        decoration: InputDecoration(
                          hintText: 'friend@example.com',
                          prefixIcon: Icon(Icons.email_outlined,
                              size: 18, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(k_radSm),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(k_radSm),
                          onTap: _addInvite,
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: k_gradPrimary,
                              borderRadius:
                                  BorderRadius.circular(k_radSm),
                            ),
                            child: const Center(
                              child: Icon(Icons.add_rounded,
                                  color: Colors.white, size: 22),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _ShareLinkCard(link: _shareLink),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const OverlineText('INVITED'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.field2,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: CustomText(
                        text: '${invited.length}',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: invited.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people_outline_rounded,
                                  size: 48, color: AppColors.textFaint),
                              const SizedBox(height: 8),
                              MutedText('No one invited yet'),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: invited.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final email = invited[i];
                            return _InviteRow(
                              email: email,
                              onRemove: () => c.removeInvite(
                                  widget.trip.id ?? '', email),
                            );
                          },
                        ),
                ),
                CustomButton(
                  text: 'Continue to planner',
                  icon: Icons.arrow_forward_rounded,
                  width: double.infinity,
                  radius: 100,
                  onPressed: () => Get.off(
                      () => ManageTripScreen(trip: widget.trip)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _addInvite() {
    final value = _email.text.trim();
    if (!value.contains('@') || value.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email')),
      );
      return;
    }
    c.addInvite(widget.trip.id ?? '', value);
    _email.clear();
  }
}

class _ShareLinkCard extends StatelessWidget {
  const _ShareLinkCard({required this.link});
  final String link;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(k_radMd),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.link_rounded, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: CustomText(
              text: link,
              fontSize: 12,
              color: AppColors.textBody,
              textAlign: TextAlign.start,
              maxLines: 1,
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: link));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link copied')),
              );
            },
            icon: const Icon(Icons.copy_rounded,
                size: 16, color: k_primary),
            label: const Text('Copy',
                style: TextStyle(
                    color: k_primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _InviteRow extends StatelessWidget {
  const _InviteRow({required this.email, required this.onRemove});
  final String email;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(k_radSm),
        boxShadow: k_shadowCard,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: k_primary.withOpacity(0.12),
            child: CustomText(
              text: email[0].toUpperCase(),
              color: k_primary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomText(
              text: email,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              textAlign: TextAlign.start,
              maxLines: 1,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded,
                color: AppColors.textMuted, size: 18),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
