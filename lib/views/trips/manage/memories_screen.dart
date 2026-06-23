import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/components/custom_button.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/components/glass_chip.dart';
import 'package:travel_app/controllers/trip/trip_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/trip_extras.dart';
import 'package:travel_app/models/trip_model.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({Key? key, required this.trip}) : super(key: key);
  final Trip trip;

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  final TripController c = Get.find<TripController>();
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const TitleText('Memories'),
        centerTitle: false,
      ),
      body: GetBuilder<TripController>(
        builder: (_) {
          final items = c.memoriesFor(widget.trip.id ?? '');
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: k_gradAccent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                          Icons.photo_camera_rounded,
                          color: Colors.white,
                          size: 40),
                    ),
                    const SizedBox(height: 18),
                    const HeadlineText('No memories yet'),
                    const SizedBox(height: 6),
                    const MutedText(
                      'Capture moments from your trip — they\'ll appear here as a beautiful gallery.',
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Add a photo',
                      icon: Icons.add_a_photo_rounded,
                      onPressed: _pickPhoto,
                      width: 200,
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding:
                const EdgeInsets.fromLTRB(k_pad, 8, k_pad, 120),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (_, i) => _MemoryCard(
              item: items[i],
              onDelete: () => c.removeMemory(items[i]),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: _pickPhoto,
            child: Ink(
              decoration: BoxDecoration(
                gradient: k_gradAccent,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: k_accent.withOpacity(0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_a_photo_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  CustomText(
                    text: 'Add photo',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final captionC = TextEditingController();
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(k_radLg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeadlineText('Add a caption'),
                const SizedBox(height: 14),
                TextField(
                  controller: captionC,
                  style: TextStyle(color: AppColors.textDark, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Say something about this moment',
                    prefixIcon:
                        Icon(Icons.format_quote_rounded, size: 18),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Skip',
                        variant: CustomButtonVariant.ghost,
                        color: AppColors.textMuted,
                        height: 48,
                        onPressed: () {
                          c.addMemory(MemoryItem(
                            tripId: widget.trip.id ?? '',
                            imagePath: picked.path,
                            createdAt: DateTime.now(),
                          ));
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: 'Save',
                        height: 48,
                        onPressed: () {
                          c.addMemory(MemoryItem(
                            tripId: widget.trip.id ?? '',
                            imagePath: picked.path,
                            caption: captionC.text.isEmpty
                                ? null
                                : captionC.text,
                            createdAt: DateTime.now(),
                          ));
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick image: $e')),
      );
    }
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.item, required this.onDelete});
  final MemoryItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: k_shadowCard,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _imageWidget(),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleIconButton(
                icon: Icons.close_rounded,
                size: 30,
                onTap: onDelete,
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: GlassChip(
                label: DateFormat('MMM d').format(item.createdAt),
                icon: Icons.calendar_today_rounded,
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.caption != null)
                    CustomText(
                      text: item.caption!,
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.start,
                      maxLines: 2,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageWidget() {
    if (item.isAsset) {
      return Image.asset(item.imagePath, fit: BoxFit.cover);
    }
    if (item.imagePath.startsWith('http')) {
      return Image.network(item.imagePath, fit: BoxFit.cover);
    }
    final file = File(item.imagePath);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return Container(
      color: AppColors.field,
      alignment: Alignment.center,
      child: Icon(Icons.broken_image_rounded,
          size: 36, color: AppColors.textFaint),
    );
  }
}
