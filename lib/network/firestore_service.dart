import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_app/helpers/catch_storage.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/card_model.dart';
import 'package:travel_app/models/trip_details.dart';
import 'package:travel_app/models/trip_list.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/models/user_model.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _currentUid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('FirestoreService called without an authenticated user.');
    }
    return uid;
  }

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
      }
      return docs;
    } catch (e) {
      debugPrint('error removing plans $e');
      return null;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserPlan(String uId) async {
    return await _db.collection("users").doc(uId).collection("plans").get();
  }

  Future<DocumentReference<Map<String, dynamic>>> addNewPlan(Trip model) async {
    // Extract details from the trip model
    // ignore: unused_local_variable
    Map<String, dynamic>? detailsMap = model.details?.toMap();

    // Merge details with other trip properties
    Map<String, dynamic> tripMap = {
      ...model.toMap(),
    };

    return await _db
        .collection("users")
        .doc(_currentUid)
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
      // Get the document reference based on the document ID and user ID
      final documentReference = await _db
          .collection("users")
          .doc(uid)
          .collection("plans")
          .where("id", isEqualTo: tripId)
          .get()
          .then((querySnapshot) {
        // Assuming there is only one document with the specified tripId
        return querySnapshot.docs.first.reference;
      });

      // Use the document reference to set the data
      await documentReference
          .set({"details": details.toMap()}, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating trip details: $e");
      throw e; // Propagate the error up to the caller if needed
    }
  }

  Future<void> saveTripChecklist(
      String uid, String tripId, TripChecklist checklist) async {
    try {
      await _db
          .collection("users")
          .doc(uid)
          .collection("plans")
          .doc(tripId)
          .update({
        'tripId': checklist.tripId,
        'checklistItems': FieldValue.arrayUnion([
          {
            'item': checklist.item,
          },
        ]),
      });
    } catch (e) {
      debugPrint("Error saving trip checklist: $e");
      throw e;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getChecklists(String uid) async {
    try {
      return await _db.collection("users").doc(uid).collection("plans").get();
    } catch (e) {
      debugPrint("Error getting checklists: $e");
      throw e;
    }
  }

  Future<void> deleteTripChecklistItem(
      String uid, String tripId, String checklistItemName) async {
    try {
      await _db
          .collection("users")
          .doc(uid)
          .collection("plans")
          .doc(tripId)
          .update({
        'checklistItems': FieldValue.arrayRemove([
          {
            'item': checklistItemName,
          },
        ]),
      });
    } catch (e) {
      debugPrint("Error deleting trip checklist item: $e");
      throw e;
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
        .doc(_currentUid)
        .collection("cards")
        .add(model.toMap);
  }

  Future<void> updateUser(UserModel model) async {
    return await _db
        .collection("users")
        .doc(_currentUid)
        .set(model.toMap);
  }
}
