import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/models/tour_model.dart';
import 'package:travel_app/models/trip_details.dart';
import 'package:travel_app/models/trip_extras.dart';
import 'package:travel_app/models/trip_list.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/network/database_service.dart';

class TripController extends GetxController {
  final RxList<Trip> tripList = <Trip>[].obs;
  final RxList<TripChecklist> checklistList = <TripChecklist>[].obs;
  final RxList<Map<dynamic, dynamic>> checklistName =
      <Map<dynamic, dynamic>>[].obs;

  // ------------------------------------------------- in-memory extras
  // Persistence layer for these comes in Phase 2 (Supabase tables).

  final RxList<SavedPlace> savedPlaces = <SavedPlace>[].obs;
  final RxMap<String, List<SavedPlace>> tripCollections =
      <String, List<SavedPlace>>{}.obs;
  final RxMap<String, List<DayPlanItem>> dayPlans =
      <String, List<DayPlanItem>>{}.obs;
  final RxMap<String, List<ExpenseItem>> expenses =
      <String, List<ExpenseItem>>{}.obs;
  final RxMap<String, List<MemoryItem>> memories =
      <String, List<MemoryItem>>{}.obs;
  final RxMap<String, List<String>> invites = <String, List<String>>{}.obs;

  // ------------------------------------------------- derived trip lists

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw.split(' ').first);
    } catch (_) {
      return null;
    }
  }

  List<Trip> get ongoingTrips {
    final today = DateTime.now();
    return tripList.where((t) {
      final end = _parseDate(t.endDate);
      return end == null || !end.isBefore(DateTime(today.year, today.month, today.day));
    }).toList();
  }

  List<Trip> get pastTrips {
    final today = DateTime.now();
    return tripList.where((t) {
      final end = _parseDate(t.endDate);
      return end != null && end.isBefore(DateTime(today.year, today.month, today.day));
    }).toList();
  }

  int tripDayCount(Trip trip) {
    final s = _parseDate(trip.startDate);
    final e = _parseDate(trip.endDate);
    if (s == null || e == null) return 1;
    final diff = e.difference(s).inDays + 1;
    return diff > 0 ? diff : 1;
  }

  String formatDateRange(Trip trip) {
    final s = _parseDate(trip.startDate);
    final e = _parseDate(trip.endDate);
    if (s == null || e == null) {
      return '${trip.startDate ?? ''} - ${trip.endDate ?? ''}';
    }
    final f = DateFormat('MMM d');
    return '${f.format(s)} - ${f.format(e)}, ${e.year}';
  }

  // ----- wishlist -----

  bool isSaved(TourModel tour) =>
      savedPlaces.any((s) => _tourKey(s.tour) == _tourKey(tour));

  String _tourKey(TourModel t) => t.id ?? t.title ?? '';

  Future<void> toggleSaved(TourModel tour) async {
    final key = _tourKey(tour);
    final idx = savedPlaces.indexWhere((s) => _tourKey(s.tour) == key);
    final wasSaved = idx >= 0;
    if (wasSaved) {
      savedPlaces.removeAt(idx);
    } else {
      savedPlaces.add(SavedPlace(tour: tour, savedAt: DateTime.now()));
    }
    savedPlaces.refresh();
    update();
    try {
      if (wasSaved) {
        await DatabaseService.instance.removeTourFromWishlist(tour);
      } else {
        await DatabaseService.instance.saveTourToWishlist(tour);
      }
    } catch (e) {
      debugPrint('toggleSaved failed: $e');
    }
  }

  // ----- collection (saved per trip) -----

  List<SavedPlace> collectionFor(String tripId) =>
      tripCollections[tripId] ?? <SavedPlace>[];

  Future<void> addToTripCollection(String tripId, TourModel tour) async {
    final list = tripCollections[tripId] ?? <SavedPlace>[];
    if (list.any((s) => _tourKey(s.tour) == _tourKey(tour))) return;
    list.add(SavedPlace(tour: tour, savedAt: DateTime.now()));
    tripCollections[tripId] = list;
    tripCollections.refresh();
    update();
    try {
      await DatabaseService.instance.addTourToTripCollection(tripId, tour);
    } catch (e) {
      debugPrint('addToTripCollection failed: $e');
    }
  }

  Future<void> removeFromTripCollection(String tripId, TourModel tour) async {
    final list = tripCollections[tripId];
    if (list == null) return;
    list.removeWhere((s) => _tourKey(s.tour) == _tourKey(tour));
    tripCollections[tripId] = list;
    tripCollections.refresh();
    update();
    try {
      await DatabaseService.instance.removeTourFromTripCollection(tripId, tour);
    } catch (e) {
      debugPrint('removeFromTripCollection failed: $e');
    }
  }

  // ----- day plan -----

  List<DayPlanItem> dayPlanFor(String tripId, int day) =>
      (dayPlans[tripId] ?? <DayPlanItem>[])
          .where((i) => i.day == day)
          .toList()
        ..sort((a, b) => a.time.compareTo(b.time));

  Future<void> addDayPlanItem(DayPlanItem item) async {
    final list = dayPlans[item.tripId] ?? <DayPlanItem>[];
    list.add(item);
    dayPlans[item.tripId] = list;
    dayPlans.refresh();
    update();
    try {
      item.id = await DatabaseService.instance.addDayPlanItem(item);
      dayPlans.refresh();
      update();
    } catch (e) {
      debugPrint('addDayPlanItem failed: $e');
    }
  }

  Future<void> removeDayPlanItem(DayPlanItem item) async {
    final list = dayPlans[item.tripId];
    if (list == null) return;
    list.remove(item);
    dayPlans[item.tripId] = list;
    dayPlans.refresh();
    update();
    if (item.id == null) return;
    try {
      await DatabaseService.instance.removeDayPlanItem(item.id!);
    } catch (e) {
      debugPrint('removeDayPlanItem failed: $e');
    }
  }

  // ----- expenses -----

  List<ExpenseItem> expensesFor(String tripId) =>
      expenses[tripId] ?? <ExpenseItem>[];

  double totalExpenses(String tripId) =>
      expensesFor(tripId).fold(0.0, (sum, e) => sum + e.amount);

  Future<void> addExpense(ExpenseItem item) async {
    final list = expenses[item.tripId] ?? <ExpenseItem>[];
    list.add(item);
    expenses[item.tripId] = list;
    expenses.refresh();
    update();
    try {
      item.id = await DatabaseService.instance.addExpense(item);
      expenses.refresh();
      update();
    } catch (e) {
      debugPrint('addExpense failed: $e');
    }
  }

  Future<void> removeExpense(ExpenseItem item) async {
    final list = expenses[item.tripId];
    if (list == null) return;
    list.remove(item);
    expenses[item.tripId] = list;
    expenses.refresh();
    update();
    if (item.id == null) return;
    try {
      await DatabaseService.instance.removeExpense(item.id!);
    } catch (e) {
      debugPrint('removeExpense failed: $e');
    }
  }

  // ----- memories -----

  List<MemoryItem> memoriesFor(String tripId) =>
      memories[tripId] ?? <MemoryItem>[];

  Future<void> addMemory(MemoryItem item) async {
    final list = memories[item.tripId] ?? <MemoryItem>[];
    list.add(item);
    memories[item.tripId] = list;
    memories.refresh();
    update();
    try {
      final url =
          await DatabaseService.instance.uploadMemoryImage(item.imagePath);
      item.imagePath = url;
      item.id = await DatabaseService.instance.addMemory(
        tripId: item.tripId,
        imageUrl: url,
        caption: item.caption,
      );
      memories.refresh();
      update();
    } catch (e) {
      debugPrint('addMemory failed: $e');
    }
  }

  Future<void> removeMemory(MemoryItem item) async {
    final list = memories[item.tripId];
    if (list == null) return;
    list.remove(item);
    memories[item.tripId] = list;
    memories.refresh();
    update();
    if (item.id == null) return;
    try {
      await DatabaseService.instance.removeMemory(item.id!);
    } catch (e) {
      debugPrint('removeMemory failed: $e');
    }
  }

  // ----- invites -----

  List<String> invitesFor(String tripId) => invites[tripId] ?? <String>[];

  Future<void> addInvite(String tripId, String email) async {
    final list = invites[tripId] ?? <String>[];
    if (list.contains(email)) return;
    list.add(email);
    invites[tripId] = list;
    invites.refresh();
    update();
    try {
      await DatabaseService.instance.addInvite(tripId, email);
    } catch (e) {
      debugPrint('addInvite failed: $e');
    }
  }

  Future<void> removeInvite(String tripId, String email) async {
    final list = invites[tripId];
    if (list == null) return;
    list.remove(email);
    invites[tripId] = list;
    invites.refresh();
    update();
    try {
      await DatabaseService.instance.removeInvite(tripId, email);
    } catch (e) {
      debugPrint('removeInvite failed: $e');
    }
  }

  Future<void> _loadExtras() async {
    try {
      final results = await Future.wait([
        DatabaseService.instance.getSavedPlaces(),
        DatabaseService.instance.getAllTripCollections(),
        DatabaseService.instance.getAllDayPlans(),
        DatabaseService.instance.getAllExpenses(),
        DatabaseService.instance.getAllMemories(),
        DatabaseService.instance.getAllInvites(),
      ]);
      savedPlaces.assignAll(results[0] as List<SavedPlace>);
      tripCollections.assignAll(
          (results[1] as Map<String, List<SavedPlace>>));
      dayPlans.assignAll((results[2] as Map<String, List<DayPlanItem>>));
      expenses.assignAll((results[3] as Map<String, List<ExpenseItem>>));
      memories.assignAll((results[4] as Map<String, List<MemoryItem>>));
      invites.assignAll((results[5] as Map<String, List<String>>));
      update();
    } catch (e) {
      debugPrint('loadExtras failed: $e');
    }
  }

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
    await _loadExtras();
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
