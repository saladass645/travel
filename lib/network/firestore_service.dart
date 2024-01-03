import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/helpers/catch_storage.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/card_model.dart';
import 'package:travel_app/models/trip_details.dart';
import 'package:travel_app/models/trip_list.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/models/user_model.dart';

class FirestoreServic {
  FirestoreServic._();
  static final instance = FirestoreServic._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> saveUser(UserModel model) async {
    await _db.collection("users").doc(model.uId).set(model.toMap);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uId) async {
    return await _db.collection("users").doc(uId).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>?> deletePlan(
      String uId, String tripId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> docs = await _db
          .collection("users")
          .doc(uId)
          .collection("plans")
          .where("id", isEqualTo: tripId)
          .get();
      for (QueryDocumentSnapshot doc in docs.docs) {
        await doc.reference.delete();
        print("successful");
      }
      return docs;
    } catch (e) {
      print("error removing plans $e");
      return null;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserPlan(String uId) async {
    return await _db.collection("users").doc(uId).collection("plans").get();
  }

  Future<DocumentReference<Map<String, dynamic>>> addNewPlan(Trip model) async {
    // Extract details from the trip model
    Map<String, dynamic>? detailsMap = model.details?.toMap();

    // Merge details with other trip properties
    Map<String, dynamic> tripMap = {
      ...model.toMap(),
      "details": detailsMap,
    };

    return await _db
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("plans")
        .add(tripMap);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getTripDetails(
      String uid, String tripId) async {
    return await _db
        .collection("users")
        .doc(uid)
        .collection("plans")
        .doc(tripId)
        .get();
  }

  Future<void> updateTripDetails(
      String uid, String tripId, TripDetails details) async {
    try {
      await _db
          .collection("users")
          .doc(uid)
          .collection("plans")
          .doc(tripId)
          .set({"details": details.toMap()}, SetOptions(merge: true));
    } catch (e) {
      print("Error updating trip details: $e");
      throw e; // Propagate the error up to the caller if needed
    }
  }

  Future<void> saveTripChecklist(
      String uid, String tripId, TripChecklist checklist) async {
    try {
      await _db
          .collection("users")
          .doc(uid)
          .collection("checklists")
          .doc(tripId)
          .set(checklist.toMap());
    } catch (e) {
      print("Error saving trip checklist: $e");
      throw e; // Propagate the error up to the caller if needed
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getTripChecklists(
      String uid) async {
    try {
      return await _db
          .collection("users")
          .doc(uid)
          .collection("checklists")
          .get();
    } catch (e) {
      print("Error getting trip checklists: $e");
      rethrow; // Propagate the error up to the caller if needed
    }
  }

  Future<void> deleteTripChecklist(String tripId, String checklistId) async {
    try {
      await _db
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .collection("plans")
          .doc(tripId)
          .collection("checklists")
          .doc(checklistId)
          .delete();
    } catch (e) {
      print("Error deleting checklist item: $e");
      throw e; // Propagate the error up to the caller if needed
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getContinents() async {
    String lang = CatchStorage.get(k_langKey) ?? "en";
    return await _db.collection(lang).doc("continents").get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getPopularCategories() async {
    String lang = CatchStorage.get(k_langKey) ?? "en";
    return await _db.collection(lang).doc("Popular_Categories").get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getTours() async {
    String lang = CatchStorage.get(k_langKey) ?? "en";
    return await _db.collection(lang).doc("Tours").collection("all").get();
  }

  Future<DocumentReference<Map<String, dynamic>>> addNewCard(
      CardModel model) async {
    return await _db
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("cards")
        .add(model.toMap);
  }

  Future<void> updateUser(UserModel model) async {
    return await _db
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .set(model.toMap);
  }
}
