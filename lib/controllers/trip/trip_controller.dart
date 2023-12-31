//import 'dart:convert';
//import 'package:collection/collection.dart';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/models/trip_details.dart';
import 'package:travel_app/models/trip_model.dart';
//import 'package:travel_app/models/user_model.dart';
import 'package:travel_app/network/firestore_service.dart';

class TripController extends GetxController {
  final RxList<Trip> tripList = <Trip>[].obs;
  RxString name = ''.obs;
  RxString destination = ''.obs;
  RxString startDate = ''.obs;
  RxString endDate = ''.obs;

  // New attributes for trip details
  RxString travelMethod = ''.obs;
  RxString accommodation = ''.obs;
  RxDouble budget = 0.0.obs;
  RxInt numberOfPeople = 0.obs;
  RxString extraNotes = ''.obs;

  @override
  onInit() async {
    super.onInit();
    print("HALLO");

    update();

    await getTripPlan();

    // isLoading = false;
    update();
  }

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

  void setTripName(String value) => name.value = value;
  void setTripDestination(String value) => destination.value = value;
  void setTripStartDate(String value) => startDate.value = value;
  void setTripEndDate(String value) => endDate.value = value;

  Future<void> addTrip() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    Random random = Random();
    int randomNumber = 10000000 + random.nextInt(90000000);
    Trip newTrip = Trip(
      id: randomNumber.toString(),
      name: name.value,
      destination: destination.value,
      startDate: startDate.value,
      endDate: endDate.value,
      details: TripDetails(
        travelMethod: travelMethod.value,
        accommodation: accommodation.value,
        budget: budget.value,
        numberOfPeople: numberOfPeople.value,
        extraNotes: extraNotes.value,
      ),
    );

    print("Adding Trip: $newTrip");

    try {
      DocumentReference<Map<String, dynamic>> docRef =
          await FirestoreServic.instance.addNewPlan(newTrip);
      // newTrip.id = int.parse(docRef.id);

      // Update the trip list and trigger UI update
      tripList.add(newTrip);
      resetTripData();
      update();
    } catch (e) {
      print("Error adding trip: $e");
    }
  }

  Future<void> getTripPlan() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      var value = await FirestoreServic.instance.getUserPlan(uid);

      List<QueryDocumentSnapshot<Map<String, dynamic>>> newValue = value.docs;

      print("Retrieved Trip Plans: ${newValue.length}");

      for (var document in newValue) {
        String documentId = document.id;
        Map<String, dynamic> data = document.data();

        String destination = data['destination'];
        String? name = data['tripName'];
        String? dateStart = data['startDate'];
        String? dateEnd = data['endDate'];

        Trip newTrip = Trip(
          destination: destination,
          name: name,
          startDate: dateStart,
          endDate: dateEnd,
        );

        tripList.add(newTrip);
      }

      print("Total Trip Plans: ${tripList.length}");

      update();
    } catch (e) {
      print("Error getting trip plans: $e");
    }
  }

  void editTrip(int id) {
    // Check if there is a trip with the specified id
    if (tripList.any((trip) => trip.id == id)) {
      // Implement logic to edit an existing trip
      Trip existingTrip = tripList.firstWhere((trip) => trip.id == id);
      existingTrip.name = name.value;
      existingTrip.destination = destination.value;
      existingTrip.startDate = startDate.value;
      existingTrip.endDate = endDate.value;
      existingTrip.details = TripDetails(
        travelMethod: travelMethod.value,
        accommodation: accommodation.value,
        budget: budget.value,
        numberOfPeople: numberOfPeople.value,
        extraNotes: extraNotes.value,
      );
    } else {
      // Handle the case where there is no trip with the specified id
      print('Trip with id $id not found.');
    }

    resetTripData();
    update(); // This ensures that GetBuilder is triggered to rebuild the UI
  }

  Future<void> deleteTrip(String tripId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    var value = await FirestoreServic.instance.deletePlan(uid, tripId);
    tripList.removeWhere((trip) => trip.id == tripId);
    update();
  }

  void saveDetails(String tripId) {
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
    name.value = '';
    destination.value = '';
    startDate.value = '';
    endDate.value = '';
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

  void saveTripDetails(String tripId, TripDetails details) {
    // Find the trip in the list
    Trip? tripToUpdate = tripList.firstWhereOrNull((trip) => trip.id == tripId);

    if (tripToUpdate != null) {
      // Update the details of the found trip
      tripToUpdate.details = details;

      // Trigger a rebuild to reflect the changes in the UI
      update();
    }
  }
}
