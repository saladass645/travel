import 'package:get/get.dart';
import 'package:travel_app/models/tour_model.dart';
import 'package:travel_app/network/database_service.dart';

class SearchResultsController extends GetxController {
  bool isLoading = false;
  List<TourModel> results = [];

  Future<void> searching({
    String? city,
    DateTime? checkIn,
    DateTime? checkOut,
  }) async {
    results = [];
    isLoading = true;
    update();

    final rows = await DatabaseService.instance.getTours();
    final query = city?.toLowerCase() ?? '';

    for (final row in rows) {
      final title = (row['title'] as String? ?? '').toLowerCase();
      if (title.contains(query)) {
        results.add(TourModel.fromJson(row));
      }
    }

    isLoading = false;
    update();
  }
}
