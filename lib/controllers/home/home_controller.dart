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
    var value = await FirestoreServic.instance.getContinents();
    List<dynamic> newValue = value.data()?["names"];
    print(newValue.length);
    for (String n in newValue) {
      continents.add(n);
    }
    update();
    // var SelectForm = value.data()!["names"] as Map<String, dynamic>;
    // SelectForm.forEach((key, value) {
    //   continents.add(value);
    // });
    // update();
  }

  Future<void> getPopularCategory() async {
    popularCategory = [];
    var documents = await FirestoreServic.instance.getPopularCategories();

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
    var querySnapshot = await FirestoreServic.instance.getTours();

    querySnapshot.docs.forEach((element) {
      TourModel tour = TourModel.fromJson(element.data());
      // Add a filter based on the 'continent' field
      if (tour.continent == continents[currentIndex]) {
        tours.add(tour);
      } else if (continents[currentIndex] == "All") {
        tours.add(tour);
      }
    });

    update();
  }
}
