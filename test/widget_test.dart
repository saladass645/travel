import 'package:flutter_test/flutter_test.dart';
import 'package:travel_app/models/currency_model.dart';

void main() {
  group('CurrencyModel.fromJson', () {
    test('parses base fields and conversion rates', () {
      final model = CurrencyModel.fromJson({
        'result': 'success',
        'base_code': 'USD',
        'time_last_update_unix': 1700000000,
        'conversion_rates': {
          'USD': 1,
          'EUR': 0.92,
          'MYR': 4.71,
        },
      });

      expect(model.result, 'success');
      expect(model.baseCode, 'USD');
      expect(model.timeLastUpdateUnix, 1700000000);
      expect(model.conversionRates, isNotNull);
      expect(model.conversionRates!.uSD, 1);
      expect(model.conversionRates!.eUR, 0.92);
      expect(model.conversionRates!.mYR, 4.71);
    });

    test('handles missing conversion_rates gracefully', () {
      final model = CurrencyModel.fromJson({
        'result': 'success',
        'base_code': 'USD',
      });

      expect(model.baseCode, 'USD');
      expect(model.conversionRates, isNull);
    });
  });
}
