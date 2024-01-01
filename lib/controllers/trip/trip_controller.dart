// ignore_for_file: unused_local_variable

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/models/trip_details.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/network/firestore_service.dart';

class TripController extends GetxController {
  final RxList<Trip> tripList = <Trip>[].obs;
  RxString name = ''.obs;
  RxString destination = ''.obs;
  RxString startDate = ''.obs;
  RxString endDate = ''.obs;
  RxString travelMethod = ''.obs;
  RxString accommodation = ''.obs;
  RxDouble budget = 0.0.obs;
  RxInt numberOfPeople = 0.obs;
  RxString extraNotes = ''.obs;

  @override
  onInit() async {
    super.onInit();
    update();

    await getTripPlan();
    update();
  }

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
    );

    print("Adding Trip: $newTrip");

    try {
      DocumentReference<Map<String, dynamic>> docRef =
          await FirestoreServic.instance.addNewPlan(newTrip);
      // Save details to Firestore
      await saveTripDetailsToFirestore(docRef.id, TripDetails());
      tripList.add(newTrip);
      resetTripData();
      update();
    } catch (e) {
      print("Error adding trip: $e");
    }
  }

  Future<void> saveTripDetailsToFirestore(
      String tripId, TripDetails details) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirestoreServic.instance.addTripDetails(uid, tripId, details);
  }

  Future<void> getTripPlan() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      var value = await FirestoreServic.instance.getUserPlan(uid);

      List<QueryDocumentSnapshot<Map<String, dynamic>>> newValue = value.docs;

      for (var document in newValue) {
        Map<String, dynamic> data = document.data();

        String destination = data['destination'];
        String? name = data['tripName'];
        String? dateStart = data['startDate'];
        String? dateEnd = data['endDate'];

        // Retrieve details data
        Map<String, dynamic>? detailsMap = data['details'];
        TripDetails details = detailsMap != null
            ? TripDetails.fromJson(detailsMap)
            : TripDetails(); // Use default values if detailsMap is null

        Trip newTrip = Trip(
          id: document.id,
          destination: destination,
          name: name,
          startDate: dateStart,
          endDate: dateEnd,
          details: details, // Set details here
        );

        tripList.add(newTrip);
      }

      update();
    } catch (e) {
      print("Error getting trip plans: $e");
    }
  }

  void saveDetails(String tripId, TripDetails details) async {
    try {
      await FirestoreServic.instance.addTripDetails(
          FirebaseAuth.instance.currentUser!.uid, tripId, details);
    } catch (e) {
      print("Error updating trip details: $e");
    }

    travelMethodController.clear();
    accommodationController.clear();
    budgetController.clear();
    numberOfPeopleController.clear();
    extraNotesController.clear();
    update();
  }

  Future<void> deleteTrip(String tripId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    var value = await FirestoreServic.instance.deletePlan(uid, tripId);
    tripList.removeWhere((trip) => trip.id == tripId);
    update();
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

    travelMethodController.clear();
    accommodationController.clear();
    budgetController.clear();
    numberOfPeopleController.clear();
    extraNotesController.clear();
  }

  void saveTripDetails(String tripId, TripDetails details) {
    Trip? tripToUpdate = tripList.firstWhereOrNull((trip) => trip.id == tripId);

    if (tripToUpdate != null) {
      tripToUpdate.details = details;
      update();
    }
  }
}
