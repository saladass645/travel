import 'package:get/get.dart';
import 'package:travel_app/models/category_model.dart';
import 'package:travel_app/models/tour_model.dart';
import 'package:travel_app/network/database_service.dart';

class HomeController extends GetxController {
  bool isLoading = false;
  List<String> continents = [];
  List<CategoryModel> popularCategory = [];
  int currentIndex = 0;
  List<TourModel> tours = [];

  @override
  void onInit() async {
    super.onInit();
    isLoading = true;
    update();

    await getContinents();
    await getPopularCategory();
    await getTours(currentIndex);

    isLoading = false;
    update();
  }

  Future<void> getContinents() async {
    continents = await DatabaseService.instance.getContinentNames();
    update();
  }

  Future<void> getPopularCategory() async {
    final rows = await DatabaseService.instance.getPopularCategories();
    popularCategory = rows.map((row) => CategoryModel.fromJson(row)).toList();
  }

  void onChangeContinents(int newIndex) {
    currentIndex = newIndex;
    getTours(currentIndex);
    update();
  }

  Future<void> getTours(int currentIndex) async {
    tours = [];
    if (continents.isEmpty) {
      update();
      return;
    }
    final selected = continents[currentIndex].toLowerCase();
    final showAll = selected == 'all';
    final rows = await DatabaseService.instance.getTours();

    for (final row in rows) {
      final tour = TourModel.fromJson(row);
      if (showAll || (tour.continent?.toLowerCase() ?? '') == selected) {
        tours.add(tour);
      }
    }

    update();
  }
}
