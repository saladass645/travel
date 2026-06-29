import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/data/continents.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/network/geocoding_service.dart';

/// Searchable destination picker.
///
/// Resolves on pop with the chosen [DestinationHit] (label, subtitle, lat,
/// lon) or `null` if the user backs out. Callers that only need a display
/// string can read `hit.displayValue` (e.g. "Kyoto, Japan").
class DestinationPickerScreen extends StatefulWidget {
  const DestinationPickerScreen({Key? key, this.initial}) : super(key: key);
  final String? initial;

  static Future<DestinationHit?> pick(BuildContext context,
      {String? initial}) {
    return Navigator.of(context).push<DestinationHit>(
      MaterialPageRoute(
        builder: (_) => DestinationPickerScreen(initial: initial),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<DestinationPickerScreen> createState() =>
      _DestinationPickerScreenState();
}

class _DestinationPickerScreenState extends State<DestinationPickerScreen> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _debounce;
  bool _loading = false;
  List<DestinationHit> _results = const [];

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) _query.text = widget.initial!;
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _query.dispose();
    _focus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _results = const [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final hits = await GeocodingService.instance.search(value);
      if (!mounted) return;
      setState(() {
        _results = hits;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.text.trim();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Get.back(),
        ),
        title: const TitleText('Where to?'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(k_pad, 4, k_pad, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(100),
              ),
              child: TextField(
                controller: _query,
                focusNode: _focus,
                onChanged: _onChanged,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Search a city, country, or place',
                  hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.textMuted),
                  suffixIcon: _query.text.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: AppColors.textMuted, size: 18),
                          onPressed: () {
                            _query.clear();
                            _onChanged('');
                            setState(() {});
                          },
                        ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 16),
                ),
              ),
            ),
          ),
          if (_loading)
            const LinearProgressIndicator(
              minHeight: 2,
              color: k_primary,
              backgroundColor: Colors.transparent,
            ),
          Expanded(
            child: query.length < 2
                ? _FeaturedList(onPick: _pickFeatured)
                : _ResultsList(
                    results: _results,
                    loading: _loading,
                    onPick: _pickHit,
                  ),
          ),
        ],
      ),
    );
  }

  void _pickFeatured(FeaturedCity city) => Get.back<DestinationHit>(
        result: DestinationHit(
          label: city.name,
          subtitle: '',
          lat: city.lat,
          lon: city.lon,
        ),
      );

  void _pickHit(DestinationHit hit) =>
      Get.back<DestinationHit>(result: hit);
}

class _FeaturedList extends StatelessWidget {
  const _FeaturedList({required this.onPick});
  final ValueChanged<FeaturedCity> onPick;

  IconData _iconFor(String key) {
    switch (key) {
      case 'asia':
        return Icons.temple_buddhist_rounded;
      case 'europe':
        return Icons.castle_rounded;
      case 'americas':
        return Icons.location_city_rounded;
      case 'africa':
        return Icons.savings_rounded;
      case 'oceania':
        return Icons.surfing_rounded;
      default:
        return Icons.public_rounded;
    }
  }

  Color _tintFor(String key) {
    switch (key) {
      case 'asia':
        return const Color(0xFFFF7B5A);
      case 'europe':
        return const Color(0xFF6C5CE7);
      case 'americas':
        return const Color(0xFF0F766E);
      case 'africa':
        return const Color(0xFFFFB347);
      case 'oceania':
        return const Color(0xFF00B894);
      default:
        return k_primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(k_pad, 8, k_pad, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(k_radMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded,
                  color: k_primary, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: BodyText(
                  'Start typing to search any city worldwide — or pick a featured destination below.',
                  maxLines: 3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        ...kContinents.expand((continent) {
          return [
            _SectionHeader(
              label: continent.displayNames['en']!.toUpperCase(),
              icon: _iconFor(continent.key),
              tint: _tintFor(continent.key),
              count: continent.featuredCities.length,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: continent.featuredCities.map((city) {
                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: () => onPick(city),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(100),
                        border:
                            Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.place_rounded,
                              color: _tintFor(continent.key), size: 15),
                          const SizedBox(width: 6),
                          CustomText(
                            text: city.name,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ];
        }),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.tint,
    required this.count,
  });
  final String label;
  final IconData icon;
  final Color tint;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tint.withOpacity(0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: tint, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomText(
            text: label,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            letterSpacing: 1.2,
            textAlign: TextAlign.start,
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(100),
          ),
          child: CustomText(
            text: '$count',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.results,
    required this.loading,
    required this.onPick,
  });
  final List<DestinationHit> results;
  final bool loading;
  final ValueChanged<DestinationHit> onPick;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty && !loading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.travel_explore_rounded,
                  size: 56, color: AppColors.textFaint),
              const SizedBox(height: 10),
              MutedText(
                'No matches — try another spelling',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(k_pad, 4, k_pad, 40),
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final hit = results[i];
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(k_radMd),
          child: InkWell(
            borderRadius: BorderRadius.circular(k_radMd),
            onTap: () => onPick(hit),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(k_radMd),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.place_rounded,
                        color: k_primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitleText(hit.label, maxLines: 1),
                        if (hit.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          MutedText(hit.subtitle, maxLines: 1),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.north_east_rounded,
                      color: AppColors.textMuted, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
