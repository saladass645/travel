import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
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

  @override
  onInit() async {
    super.onInit();
    await getCurrency();
  }

  Future<void> getCurrency() async {
    isLoading = true;
    hasError = false;
    update();
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      Response<dynamic> response;
      Map<String, dynamic> parsed;

      if (_kExchangeRateApiKey.isNotEmpty) {
        response = await dio.get(
          'https://v6.exchangerate-api.com/v6/$_kExchangeRateApiKey/latest/USD',
        );
        if (response.statusCode != 200) throw 'rate request failed';
        parsed = (response.data as Map).cast<String, dynamic>();
      } else {
        // No key? Fall back to the open ExchangeRate-API mirror (no key
        // required, same JSON shape except `rates` instead of
        // `conversion_rates`). Lets the converter work out of the box.
        response = await dio.get('https://open.er-api.com/v6/latest/USD');
        if (response.statusCode != 200) throw 'rate request failed';
        final raw = (response.data as Map).cast<String, dynamic>();
        parsed = {
          ...raw,
          'conversion_rates': raw['rates'] ?? raw['conversion_rates'],
        };
      }

      currencyModel = CurrencyModel.fromJson(parsed);
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
