import 'package:get/get.dart';
import 'package:travel_app/models/category_model.dart';
import 'package:travel_app/models/tour_model.dart';
import 'package:travel_app/network/firestore_service.dart';

class HomeController extends GetxController {
  bool isLoading = false;
  List<String> continents = [];
  List<CategoryModel> popularCategory = [];
  int currentIndex = 0;
  List<TourModel> tours = [];
  String currentContinent = "all";

  onInit() async {
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
    continents = [];
    final value = await FirestoreService.instance.getContinents();
    final List<dynamic> newValue = value.data()?['names'] ?? const [];
    for (final n in newValue.cast<String>()) {
      continents.add(n);
    }
    update();
  }

  Future<void> getPopularCategory() async {
    popularCategory = [];
    var documents = await FirestoreService.instance.getPopularCategories();

    if (documents.data() == null) return;

    documents.data()!.forEach((key, value) {
      popularCategory.add(CategoryModel.fromJson(value));
    });
  }

  void onChangeContinents(int newIndex) {
    currentIndex = newIndex;
    getTours(currentIndex);
    update();
  }

  Future<void> getTours(int currentIndex) async {
    tours = [];
    final selected = continents[currentIndex].toLowerCase();
    final showAll = selected == 'all';
    final querySnapshot = await FirestoreService.instance.getTours();

    for (final element in querySnapshot.docs) {
      final tour = TourModel.fromJson(element.data());
      if (showAll || (tour.continent?.toLowerCase() ?? '') == selected) {
        tours.add(tour);
      }
    }

    update();
  }
}
