import 'package:get/get.dart';
import 'package:travel_app/data/continents.dart';
import 'package:travel_app/models/category_model.dart';
import 'package:travel_app/models/tour_model.dart';
import 'package:travel_app/network/database_service.dart';

class HomeController extends GetxController {
  bool isLoading = false;
  List<String> continents = [];
  List<CategoryModel> popularCategory = [];

  /// Filter index. -1 means "All continents", 0..N maps into [kContinents].
  int currentIndex = -1;

  /// All tours fetched across every continent. Filter on read via
  /// [tours] / [filteredTours].
  List<TourModel> _allTours = [];

  /// Backwards-compat: existing UI reads `controller.tours` directly.
  /// Returns the filtered subset based on [currentIndex].
  List<TourModel> get tours => filteredTours;

  List<TourModel> get filteredTours {
    if (currentIndex < 0 || currentIndex >= kContinents.length) {
      return _allTours;
    }
    final selectedEn =
        kContinents[currentIndex].displayNames['en']!.toLowerCase();
    return _allTours
        .where((t) => (t.continent?.toLowerCase() ?? '') == selectedEn)
        .toList();
  }

  @override
  void onInit() async {
    super.onInit();
    isLoading = true;
    update();

    await getContinents();
    await getPopularCategory();
    await _loadAllTours();

    isLoading = false;
    update();
  }

  Future<void> getContinents() async {
    continents = await DatabaseService.instance.getContinentNames();
    update();
  }

  Future<void> getPopularCategory() async {
    final rows = await DatabaseService.instance.getPopularCategories();
    popularCategory =
        rows.map((row) => CategoryModel.fromJson(row)).toList();
  }

  Future<void> _loadAllTours() async {
    final rows = await DatabaseService.instance.getTours();
    _allTours = rows.map((row) => TourModel.fromJson(row)).toList();
    update();
  }

  void onChangeContinents(int newIndex) {
    currentIndex = newIndex;
    update();
  }
}
