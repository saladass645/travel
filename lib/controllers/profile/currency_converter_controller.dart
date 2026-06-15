import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/models/currency_model.dart';

const String _kExchangeRateApiKey =
    String.fromEnvironment('EXCHANGERATE_API_KEY');

class CurrencyConverterController extends GetxController {
  bool isLoading = false;
  bool hasError = false;
  CurrencyModel? currencyModel;

  double result = 0;

  final TextEditingController amount = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  onInit() async {
    super.onInit();
    await getCurrency();
  }

  Future<void> getCurrency() async {
    isLoading = true;
    hasError = false;
    update();
    try {
      if (_kExchangeRateApiKey.isEmpty) {
        throw StateError(
            'EXCHANGERATE_API_KEY not provided. Pass it via --dart-define.');
      }
      final url =
          'https://v6.exchangerate-api.com/v6/$_kExchangeRateApiKey/latest/USD';
      final response = await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      )).get(url);

      if (response.statusCode != 200) throw 'Error with response';

      currencyModel = CurrencyModel.fromJson(response.data);
      isLoading = false;
      update();
    } catch (error) {
      isLoading = false;
      hasError = true;
      update();
      debugPrint('getCurrency failed: $error');
    }
  }

  void convertAmount() {
    if (!formKey.currentState!.validate()) return;
    final rate = currencyModel?.conversionRates?.mYR;
    final parsed = double.tryParse(amount.text);
    if (rate == null || parsed == null) return;
    result = (rate as num).toDouble() * parsed;
    update();
  }
}
