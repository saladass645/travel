import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/models/trip_details.dart';
import 'package:travel_app/models/trip_list.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/network/database_service.dart';

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
    final value = Supabase.instance.client.auth.currentUser?.id;
    if (value == null) {
      throw StateError('TripController used without an authenticated user.');
    }
    return value;
  }

  @override
  void onInit() async {
    super.onInit();
    if (Supabase.instance.client.auth.currentUser == null) return;
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
    final newTrip = Trip(
      name: name.value,
      destination: destination.value,
      startDate: startDate.value,
      endDate: endDate.value,
    );

    debugPrint('Adding Trip: ${newTrip.name}');

    try {
      final tripId = await DatabaseService.instance.addNewPlan(newTrip);
      newTrip.id = tripId;
      tripList.add(newTrip);
      resetTripData();
      update();
    } catch (e) {
      debugPrint('Error adding trip: $e');
    }
  }

  Future<void> getTripPlan() async {
    try {
      final trips = await DatabaseService.instance.getUserPlan(uid);
      tripList.assignAll(trips);
      update();
    } catch (e) {
      debugPrint('Error getting trip plans: $e');
    }
  }

  Future<void> getTripDetails(String uid, String tripId) async {
    try {
      final trip =
          await DatabaseService.instance.getTripDetails(uid, tripId);
      if (trip == null) {
        debugPrint('Trip details not found for $tripId');
        return;
      }
      final details = trip.details;
      tripList.removeWhere((t) => t.id == tripId);
      tripList.add(Trip(id: tripId, details: details));
      if (details != null) loadDetails(details);
    } catch (e) {
      debugPrint('Error getting trip details: $e');
    }
  }

  void saveDetails(String tripId, TripDetails details) async {
    try {
      await DatabaseService.instance.updateTripDetails(uid, tripId, details);
      travelMethodController.clear();
      accommodationController.clear();
      budgetController.clear();
      numberOfPeopleController.clear();
      extraNotesController.clear();
    } catch (e) {
      debugPrint('Error updating trip details: $e');
    }
  }

  Future<void> updateTripDetails(String tripId, TripDetails details) async {
    try {
      await DatabaseService.instance.updateTripDetails(uid, tripId, details);

      final tripToUpdate =
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
      debugPrint('Error updating trip details: $e');
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
    await DatabaseService.instance.deletePlan(uid, tripId);
    tripList.removeWhere((trip) => trip.id == tripId);
    update();
  }

  Future<void> saveChecklist(String tripId, TripChecklist checklist) async {
    try {
      await DatabaseService.instance
          .saveTripChecklist(uid, tripId, checklist);
      checklistList.add(checklist);
      update();
    } catch (e) {
      debugPrint('Error saving checklist: $e');
    }
  }

  Future<void> getChecklists() async {
    try {
      final items = await DatabaseService.instance.getChecklists(uid);
      checklistName.assignAll(items.cast<Map<dynamic, dynamic>>());
      update();
    } catch (e) {
      debugPrint('Error getting checklists: $e');
    }
  }

  Future<void> addChecklist(String tripId, String item) async {
    try {
      final checklist =
          TripChecklist(tripId: tripId, item: item, checklistItems: []);
      await DatabaseService.instance
          .saveTripChecklist(uid, tripId, checklist);
      await getChecklists();
      update();
    } catch (e) {
      debugPrint('Error adding checklist item: $e');
    }
  }

  Future<void> deleteChecklist(String tripId, String checklistItemName) async {
    try {
      await DatabaseService.instance
          .deleteTripChecklistItem(uid, tripId, checklistItemName);
      checklistName.removeWhere((c) =>
          c['tripId'] == tripId && c['item'] == checklistItemName);
      update();
    } catch (e) {
      debugPrint('Error deleting checklist item: $e');
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
    final tripToUpdate =
        tripList.firstWhereOrNull((trip) => trip.id == tripId);
    if (tripToUpdate != null) {
      tripToUpdate.details = details;
      update();
    }
  }
}
