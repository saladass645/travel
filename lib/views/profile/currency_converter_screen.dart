import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:travel_app/components/custom_button.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/components/glass_chip.dart';
import 'package:travel_app/controllers/profile/currency_converter_controller.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';

class CurrencyConverterScreen extends GetWidget<CurrencyConverterController> {
  const CurrencyConverterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const TitleText('Currency converter'),
        centerTitle: false,
      ),
      body: GetBuilder<CurrencyConverterController>(
        builder: (c) {
          if (c.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: k_primary),
            );
          }
          if (c.hasError == true) {
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
                          Icons.signal_wifi_connected_no_internet_4_rounded,
                          color: Colors.white,
                          size: 40),
                    ),
                    const SizedBox(height: 18),
                    const HeadlineText('Could not load rates'),
                    const SizedBox(height: 6),
                    const MutedText(
                      'Check your connection — we use exchangerate-api.com.',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 18),
                    CustomButton(
                      text: 'Try again',
                      icon: Icons.refresh_rounded,
                      onPressed: c.onInit,
                      width: 200,
                    ),
                  ],
                ),
              ),
            );
          }

          final rate = c.currencyModel?.conversionRates?.mYR;
          final rateLabel = rate == null
              ? '—'
              : '1 USD = ${(rate as num).toDouble().toStringAsFixed(3)} MYR';

          return SingleChildScrollView(
            padding:
                const EdgeInsets.fromLTRB(k_pad, 8, k_pad, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: k_gradPrimary,
                    borderRadius: BorderRadius.circular(k_radLg),
                    boxShadow: [
                      BoxShadow(
                        color: k_primary.withOpacity(0.3),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          GlassChip(
                            label: 'LIVE RATE',
                            icon: Icons.trending_up_rounded,
                          ),
                          Spacer(),
                        ],
                      ),
                      const SizedBox(height: 18),
                      CustomText(
                        text: rateLabel,
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      const SizedBox(height: 6),
                      CustomText(
                        text: 'Today\'s exchange rate',
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: const [
                    Expanded(child: _Pill(code: 'USD', label: 'US Dollar')),
                    SizedBox(width: 12),
                    Padding(
                      padding: EdgeInsets.only(top: 22),
                      child: Icon(Icons.compare_arrows_rounded,
                          color: k_primary, size: 22),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                        child: _Pill(code: 'MYR', label: 'Malaysian RM')),
                  ],
                ),
                const SizedBox(height: 24),
                Form(
                  key: c.formKey,
                  child: TextFormField(
                    controller: c.amount,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(v) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter amount in USD',
                      hintStyle:
                          TextStyle(color: AppColors.textMuted, fontSize: 14),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: CustomText(
                          text: '\$',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: k_primary,
                        ),
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Convert',
                  icon: Icons.arrow_downward_rounded,
                  width: double.infinity,
                  radius: 100,
                  onPressed: c.convertAmount,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(k_radMd),
                    boxShadow: k_shadowCard,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const OverlineText('CONVERTED AMOUNT'),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomText(
                            text: c.result.toStringAsFixed(2),
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: -1,
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: CustomText(
                              text: 'MYR',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.code, required this.label});
  final String code;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(k_radMd),
        boxShadow: k_shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: code,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 2),
          CustomText(
            text: label,
            fontSize: 11,
            color: AppColors.textMuted,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
