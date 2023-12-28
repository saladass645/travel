import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/models/trip_details.dart';
import 'package:travel_app/models/trip_model.dart';

class TripController extends GetxController {
  RxList<Trip> tripList = <Trip>[].obs;
  RxString tripName = ''.obs;
  RxString tripDestination = ''.obs;
  RxString tripStartDate = ''.obs;
  RxString tripEndDate = ''.obs;

  // New attributes for trip details
  RxString travelMethod = ''.obs;
  RxString accommodation = ''.obs;
  RxDouble budget = 0.0.obs;
  RxInt numberOfPeople = 0.obs;
  RxString extraNotes = ''.obs;

  // Controllers for trip details
  final TextEditingController travelMethodController = TextEditingController();
  final TextEditingController accommodationController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController numberOfPeopleController =
      TextEditingController();
  final TextEditingController extraNotesController = TextEditingController();

  void setTravelMethod(String value) => travelMethod.value = value;
  void setAccommodation(String value) => accommodation.value = value;
  void setBudget(double value) => budget.value = value;
  void setNumberOfPeople(int value) => numberOfPeople.value = value;
  void setExtraNotes(String value) => extraNotes.value = value;

  void setTripName(String value) => tripName.value = value;
  void setTripDestination(String value) => tripDestination.value = value;
  void setTripStartDate(String value) => tripStartDate.value = value;
  void setTripEndDate(String value) => tripEndDate.value = value;

  void addTrip() {
    Trip newTrip = Trip(
      id: DateTime.now().millisecondsSinceEpoch,
      name: tripName.value,
      destination: tripDestination.value,
      startDate: tripStartDate.value,
      endDate: tripEndDate.value,
      details: TripDetails(
        travelMethod: travelMethod.value,
        accommodation: accommodation.value,
        budget: budget.value,
        numberOfPeople: numberOfPeople.value,
        extraNotes: extraNotes.value,
      ),
    );

    tripList.add(newTrip);

    resetTripData();
    update();
  }

  void editTrip(int id) {
    // Implement logic to edit an existing trip
    Trip existingTrip = tripList.firstWhere((trip) => trip.id == id);
    existingTrip.name = tripName.value;
    existingTrip.destination = tripDestination.value;
    existingTrip.startDate = tripStartDate.value;
    existingTrip.endDate = tripEndDate.value;
    existingTrip.details = TripDetails(
      travelMethod: travelMethod.value,
      accommodation: accommodation.value,
      budget: budget.value,
      numberOfPeople: numberOfPeople.value,
      extraNotes: extraNotes.value,
    );

    resetTripData();
    update(); // This ensures that GetBuilder is triggered to rebuild the UI
  }

  void deleteTrip(int id) {
    tripList.removeWhere((trip) => trip.id == id);
    update();
  }

  void toggleFavorite(int id) {
    Trip toggledTrip = tripList.firstWhere((trip) => trip.id == id);
    if (toggledTrip.favorite != null) {
      toggledTrip.favorite = !(toggledTrip.favorite ?? false);
      update();
    }
  }

  void saveDetails(int tripId) {
    // Convert relevant properties to double or int
    double budgetValue = double.tryParse(budgetController.text) ?? 0.0;
    int numberOfPeopleValue = int.tryParse(numberOfPeopleController.text) ?? 0;

    TripDetails details = TripDetails(
      travelMethod: travelMethodController.text,
      accommodation: accommodationController.text,
      budget: budgetValue,
      numberOfPeople: numberOfPeopleValue,
      extraNotes: extraNotesController.text,
    );

    // Assuming you have a method in TripController to save details
    // Make sure to handle null or add a default behavior if the details field is null
    TripController().saveTripDetails(tripId, details);

    // Clear controllers after saving
    travelMethodController.clear();
    accommodationController.clear();
    budgetController.clear();
    numberOfPeopleController.clear();
    extraNotesController.clear();
  }

  void resetTripData() {
    tripName.value = '';
    tripDestination.value = '';
    tripStartDate.value = '';
    tripEndDate.value = '';
    travelMethod.value = '';
    accommodation.value = '';
    budget.value = 0.0;
    numberOfPeople.value = 0;
    extraNotes.value = '';

    // Clear controllers for trip details
    travelMethodController.clear();
    accommodationController.clear();
    budgetController.clear();
    numberOfPeopleController.clear();
    extraNotesController.clear();
  }

  void saveTripDetails(int tripId, TripDetails details) {
    // Find the trip in the list
    Trip? tripToUpdate = tripList.firstWhereOrNull((trip) => trip.id == tripId);

    if (tripToUpdate != null) {
      // Update the details of the found trip
      tripToUpdate.details = details;
      update(); // Trigger a rebuild to reflect the changes in the UI
    }
  }
}
