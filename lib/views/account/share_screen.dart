import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/trip_extras.dart';

class ShareScreen extends StatelessWidget {
  const ShareScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TripController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const TitleText('Share & inspire'),
        centerTitle: false,
      ),
      body: GetBuilder<TripController>(
        builder: (_) {
          final journeys = c.tripList;
          final memoryItems = c.memories.values
              .expand((l) => l)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView(
            padding:
                const EdgeInsets.fromLTRB(k_pad, 4, k_pad, 40),
            children: [
              const OverlineText('MY JOURNEYS'),
              const SizedBox(height: 10),
              if (journeys.isEmpty)
                _emptyBox('Create a trip to share it')
              else
                Column(
                  children: journeys
                      .map((trip) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _JourneyRow(
                              trip: trip,
                              onShare: () =>
                                  _shareJourney(context, trip),
                            ),
                          ))
                      .toList(),
                ),
              const SizedBox(height: 24),
              const OverlineText('MY PHOTOS'),
              const SizedBox(height: 10),
              if (memoryItems.isEmpty)
                _emptyBox('Add memories from a trip to share them')
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: memoryItems.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (_, i) {
                    final m = memoryItems[i];
                    return GestureDetector(
                      onTap: () => _sharePhoto(context, m),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: _photo(m),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyBox(String label) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(k_radMd),
        boxShadow: k_shadowCard,
      ),
      alignment: Alignment.center,
      child: MutedText(label),
    );
  }

  Widget _photo(MemoryItem m) {
    if (m.isAsset) return Image.asset(m.imagePath, fit: BoxFit.cover);
    if (m.imagePath.startsWith('http')) {
      return Image.network(m.imagePath, fit: BoxFit.cover);
    }
    final f = File(m.imagePath);
    if (f.existsSync()) return Image.file(f, fit: BoxFit.cover);
    return Container(
      color: AppColors.field,
      alignment: Alignment.center,
      child: Icon(Icons.broken_image_rounded, color: AppColors.textFaint),
    );
  }

  Future<void> _shareJourney(BuildContext context, dynamic trip) async {
    final text =
        'Check out my trip "${trip.name}" to ${trip.destination}!';
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Journey copied to clipboard')),
    );
  }

  Future<void> _sharePhoto(BuildContext context, MemoryItem m) async {
    await Clipboard.setData(ClipboardData(text: m.caption ?? m.imagePath));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo info copied to clipboard')),
    );
  }
}

class _JourneyRow extends StatelessWidget {
  const _JourneyRow({required this.trip, required this.onShare});
  final dynamic trip;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(k_radMd),
        boxShadow: k_shadowCard,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: k_gradPrimary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.flight_takeoff_rounded,
                color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleText(trip.name ?? '', maxLines: 1),
                const SizedBox(height: 2),
                MutedText(trip.destination ?? '', maxLines: 1),
              ],
            ),
          ),
          GestureDetector(
            onTap: onShare,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.ios_share_rounded,
                  color: k_primary, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

