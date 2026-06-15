import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/models/trip_details.dart';
import 'package:travel_app/models/trip_list.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/network/firestore_service.dart';

class TripController extends GetxController {
  final RxList<Trip> tripList = <Trip>[].obs;
  final RxList<TripChecklist> checklistList = <TripChecklist>[].obs;
  final RxList<Map<dynamic, dynamic>> checklistName =
      <Map<dynamic, dynamic>>[].obs;

  RxString name = ''.obs;
  RxString destination = ''.obs;
  RxString startDate = ''.obs;
  RxString endDate = ''.obs;
  RxString travelMethod = ''.obs;
  RxString accommodation = ''.obs;
  RxDouble budget = 0.0.obs;
  RxInt numberOfPeople = 0.obs;
  RxString extraNotes = ''.obs;
  String get uid {
    final value = FirebaseAuth.instance.currentUser?.uid;
    if (value == null) {
      throw StateError('TripController used without an authenticated user.');
    }
    return value;
  }

  @override
  onInit() async {
    super.onInit();
    update();
    await getTripPlan();
    await getChecklists();
    update();
  }

  final TextEditingController travelMethodController = TextEditingController();
  final TextEditingController accommodationController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController numberOfPeopleController =
      TextEditingController();
  final TextEditingController extraNotesController = TextEditingController();
  final TextEditingController checklistItemController = TextEditingController();

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
    Random random = Random();
    int randomNumber = 10000000 + random.nextInt(90000000);
    Trip newTrip = Trip(
      id: randomNumber.toString(),
      name: name.value,
      destination: destination.value,
      startDate: startDate.value,
      endDate: endDate.value,
    );

    debugPrint("Adding Trip: $newTrip");

    try {
      DocumentReference<Map<String, dynamic>> docRef =
          await FirestoreService.instance.addNewPlan(newTrip);
      // Save details to Firestore
      await saveTripDetailsToFirestore(docRef.id, TripDetails());
      tripList.add(newTrip);
      resetTripData();
      update();
    } catch (e) {
      debugPrint("Error adding trip: $e");
    }
  }

  Future<void> saveTripDetailsToFirestore(
      String tripId, TripDetails details) async {
    await FirestoreService.instance.getTripDetails(uid, tripId);
  }

  Future<void> getTripPlan() async {
    try {
      var value = await FirestoreService.instance.getUserPlan(uid);

      List<QueryDocumentSnapshot<Map<String, dynamic>>> newValue = value.docs;

      for (var document in newValue) {
        Map<String, dynamic> data = document.data();

        String destination = data['destination'];
        String? name = data['tripName'];
        String? dateStart = data['startDate'];
        String? dateEnd = data['endDate'];

        // Access details directly from the main document
        Map<String, dynamic>? detailsMap = data['details'];
        TripDetails details = TripDetails.fromMap(detailsMap);

        Trip newTrip = Trip(
          id: document.id,
          destination: destination,
          name: name,
          startDate: dateStart,
          endDate: dateEnd,
          details: details,
        );

        tripList.add(newTrip);
      }

      update();
    } catch (e) {
      debugPrint("Error getting trip plans: $e");
    }
  }

  Future<void> getTripDetails(String uid, String tripId) async {
    try {
      var snapshot = await FirestoreService.instance.getTripDetails(uid, tripId);

      if (snapshot.exists) {
        TripDetails details = TripDetails.fromMap(snapshot.data()!);
        // Update the tripList with the fetched details
        tripList.removeWhere((trip) => trip.id == tripId);
        tripList.add(Trip(id: tripId, details: details));
        loadDetails(details);
      } else {
        debugPrint("Trip details not found for $tripId");
      }
    } catch (e) {
      debugPrint("Error getting trip details: $e");
    }
  }

  void saveDetails(String tripId, TripDetails details) async {
    try {
      // Update trip details in Firestore
      await FirestoreService.instance.updateTripDetails(
          uid, tripId, details);

      travelMethodController.clear();
      accommodationController.clear();
      budgetController.clear();
      numberOfPeopleController.clear();
      extraNotesController.clear();
    } catch (e) {
      debugPrint("Error updating trip details: $e");
    }
  }

  Future<void> updateTripDetails(String tripId, TripDetails details) async {
    try {
      // Update trip details in Firestore
      await FirestoreService.instance.updateTripDetails(
          uid, tripId, details);

      // Update local trip list
      Trip? tripToUpdate =
          tripList.firstWhereOrNull((trip) => trip.id == tripId);

      if (tripToUpdate != null) {
        tripToUpdate.details = details;
        update();
      }

      travelMethodController.clear();
      accommodationController.clear();
      budgetController.clear();
      numberOfPeopleController.clear();
      extraNotesController.clear();
    } catch (e) {
      debugPrint("Error updating trip details: $e");
    }
  }

  void loadDetails(TripDetails? details) {
    travelMethodController.text = details?.travelMethod ?? '';
    accommodationController.text = details?.accommodation ?? '';
    budgetController.text = details?.budget?.toString() ?? '';
    numberOfPeopleController.text = details?.numberOfPeople?.toString() ?? '';
    extraNotesController.text = details?.extraNotes ?? '';
  }

  Future<void> deleteTrip(String tripId) async {
    await FirestoreService.instance.deletePlan(uid, tripId);
    tripList.removeWhere((trip) => trip.id == tripId);
    update();
  }

  Future<void> saveChecklist(String tripId, TripChecklist checklist) async {
    try {
      await FirestoreService.instance.saveTripChecklist(uid, tripId, checklist);
      checklistList.add(checklist);
      update();
    } catch (e) {
      debugPrint("Error saving checklist: $e");
    }
  }

  Future<void> getChecklists() async {
    try {
      var value = await FirestoreService.instance.getChecklists(uid);

      List<QueryDocumentSnapshot<Map<String, dynamic>>> newValue = value.docs;

      checklistName.clear(); // Clear existing list before populating

      for (var document in newValue) {
        Map<String, dynamic> data = document.data();

        for (var checklistItem in data["checklistItems"]) {
          checklistName.add({
            "item": checklistItem["item"],
            "tripId": data["tripId"],
          });
        }
      }

      update();
    } catch (e) {
      debugPrint("Error getting checklists: $e");
    }
  }

  Future<void> addChecklist(String tripId, String item) async {
    try {
      TripChecklist checklist = TripChecklist(
        tripId: tripId,
        item: item,
        checklistItems: [],
      );

      await FirestoreService.instance.saveTripChecklist(uid, tripId, checklist);
      await getChecklists();
      update();
    } catch (e) {
      debugPrint("Error adding checklist item: $e");
    }
  }

  Future<void> deleteChecklist(String tripId, String checklistItemName) async {
    try {
      debugPrint("Deleting checklist item with ID: $checklistItemName");
      await FirestoreService.instance
          .deleteTripChecklistItem(uid, tripId, checklistItemName);
      checklistName.removeWhere((checklist) =>
          checklist["tripId"] == tripId &&
          checklist["item"] == checklistItemName);
      update();
      debugPrint("Checklist item deleted successfully");
    } catch (e) {
      debugPrint("Error deleting checklist item: $e");
    }
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
