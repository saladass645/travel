import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/data/continents.dart';
import 'package:travel_app/helpers/catch_storage.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/card_model.dart';
import 'package:travel_app/models/tour_model.dart';
import 'package:travel_app/models/trip_details.dart';
import 'package:travel_app/models/trip_extras.dart';
import 'package:travel_app/models/trip_list.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/models/user_model.dart';
import 'package:travel_app/network/places_service.dart';

class DatabaseService {
  DatabaseService._();
  static final instance = DatabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  String get _currentUid {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('DatabaseService called without an authenticated user.');
    }
    return uid;
  }

  String get _lang => CatchStorage.get(k_langKey) ?? 'en';

  // ---------------------------------------------------------------- users

  Map<String, dynamic> _userToRow(UserModel model) {
    return {
      if (model.uId != null) 'id': model.uId,
      if (model.name != null) 'name': model.name,
      if (model.email != null) 'email': model.email,
      if (model.image != null) 'image': model.image,
      if (model.location != null) 'location': model.location,
      if (model.address != null) 'address': model.address,
      if (model.phoneNumber != null) 'phone_number': model.phoneNumber,
      if (model.dateOfRegister != null) 'date_of_register': model.dateOfRegister,
    };
  }

  Map<String, dynamic> _rowToUserJson(Map<String, dynamic> row) {
    return {
      'uId': row['id'],
      'name': row['name'],
      'email': row['email'],
      'image': row['image'],
      'location': row['location'],
      'address': row['address'],
      'phoneNumber': row['phone_number'],
      'dateOfRegister': row['date_of_register'],
    };
  }

  Future<void> saveUser(UserModel model) async {
    await _client.from('users').upsert(_userToRow(model));
  }

  Future<Map<String, dynamic>?> getUser(String uId) async {
    final row =
        await _client.from('users').select().eq('id', uId).maybeSingle();
    if (row == null) return null;
    return _rowToUserJson(row);
  }

  Future<void> updateUser(UserModel model) async {
    final row = _userToRow(model)..remove('id');
    await _client.from('users').update(row).eq('id', _currentUid);
  }

  // ---------------------------------------------------------------- plans

  Map<String, dynamic> _planToRow(Trip model) {
    final details = model.details;
    return {
      'user_id': _currentUid,
      'name': model.name,
      'destination': model.destination,
      'start_date': model.startDate,
      'end_date': model.endDate,
      if (details != null) ...{
        'travel_method': details.travelMethod,
        'accommodation': details.accommodation,
        'budget': details.budget,
        'number_of_people': details.numberOfPeople,
        'extra_notes': details.extraNotes,
      },
    };
  }

  Trip _rowToTrip(Map<String, dynamic> row) {
    return Trip(
      id: row['id'] as String?,
      name: row['name'] as String?,
      destination: row['destination'] as String?,
      startDate: row['start_date'] as String?,
      endDate: row['end_date'] as String?,
      details: TripDetails(
        travelMethod: row['travel_method'] as String?,
        accommodation: row['accommodation'] as String?,
        budget: (row['budget'] as num?)?.toDouble(),
        numberOfPeople: (row['number_of_people'] as num?)?.toInt(),
        extraNotes: row['extra_notes'] as String?,
      ),
    );
  }

  Future<String> addNewPlan(Trip model) async {
    final inserted = await _client
        .from('plans')
        .insert(_planToRow(model))
        .select('id')
        .single();
    return inserted['id'] as String;
  }

  Future<List<Trip>> getUserPlan(String uId) async {
    final rows = await _client
        .from('plans')
        .select()
        .eq('user_id', uId)
        .order('created_at', ascending: false);
    return rows.map<Trip>((r) => _rowToTrip(r)).toList();
  }

  Future<Trip?> getTripDetails(String uid, String tripId) async {
    final row = await _client
        .from('plans')
        .select()
        .eq('id', tripId)
        .maybeSingle();
    if (row == null) return null;
    return _rowToTrip(row);
  }

  Future<void> updateTripDetails(
      String uid, String tripId, TripDetails details) async {
    try {
      await _client.from('plans').update({
        'travel_method': details.travelMethod,
        'accommodation': details.accommodation,
        'budget': details.budget,
        'number_of_people': details.numberOfPeople,
        'extra_notes': details.extraNotes,
      }).eq('id', tripId);
    } catch (e) {
      debugPrint('Error updating trip details: $e');
      rethrow;
    }
  }

  Future<void> deletePlan(String uId, String tripId) async {
    try {
      await _client.from('plans').delete().eq('id', tripId);
    } catch (e) {
      debugPrint('Error removing plan: $e');
    }
  }

  // ---------------------------------------------------------------- checklist

  Future<void> saveTripChecklist(
      String uid, String tripId, TripChecklist checklist) async {
    try {
      await _client.from('plan_checklist_items').insert({
        'plan_id': tripId,
        'item': checklist.item,
      });
    } catch (e) {
      debugPrint('Error saving trip checklist: $e');
      rethrow;
    }
  }

  /// Returns a list of `{ tripId, item }` maps for all of the user's plans,
  /// matching the legacy shape the UI consumes.
  Future<List<Map<String, dynamic>>> getChecklists(String uid) async {
    try {
      final rows = await _client
          .from('plan_checklist_items')
          .select('item, plan_id, plans!inner(user_id)')
          .eq('plans.user_id', uid);
      return rows
          .map<Map<String, dynamic>>(
              (r) => {'item': r['item'], 'tripId': r['plan_id']})
          .toList();
    } catch (e) {
      debugPrint('Error getting checklists: $e');
      rethrow;
    }
  }

  Future<void> deleteTripChecklistItem(
      String uid, String tripId, String checklistItemName) async {
    try {
      await _client
          .from('plan_checklist_items')
          .delete()
          .eq('plan_id', tripId)
          .eq('item', checklistItemName);
    } catch (e) {
      debugPrint('Error deleting trip checklist item: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------- catalog
  //
  // Catalog data is no longer stored in Supabase. Continents and categories
  // are hard-coded in [kContinents]/[kCategories]; tours come from
  // [PlacesService] (OpenTripMap). The public method signatures stay the
  // same so existing controllers do not need to change.

  Future<List<String>> getContinentNames() async {
    return kContinents.map((c) => c.displayName(_lang)).toList();
  }

  Future<List<Map<String, dynamic>>> getPopularCategories() async {
    return kCategories
        .map((c) => <String, dynamic>{
              'name': c.displayName(_lang),
              'image': c.imageUrl,
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> getTours() async {
    return PlacesService.instance.fetchAllTours();
  }

  // ---------------------------------------------------------------- saved places

  String _tourKey(TourModel t) => t.id ?? t.title ?? '';

  Map<String, dynamic> _tourToJson(TourModel t) => {
        'id': t.id,
        'title': t.title,
        'continent': t.continent,
        'image': t.image,
        'images': t.images,
        'overview': t.overview,
        'distance': t.distance,
        'weather_condition': t.weatherCondition,
        'rating': t.rating,
        'number_of_reviews': t.numberOfReviews,
        'started_price': t.startedPrice,
        'temperature': t.temperature,
        'duration_day': t.durationDay,
        'category': t.category,
        'extra_price': t.extraPrice,
        'details': t.details,
        'reviews': t.reviews,
        'costs': t.costs,
      };

  Future<List<SavedPlace>> getSavedPlaces() async {
    final rows = await _client
        .from('saved_places')
        .select('tour_data, created_at')
        .eq('user_id', _currentUid)
        .order('created_at', ascending: false);
    return rows.map<SavedPlace>((r) {
      final data = (r['tour_data'] as Map).cast<String, dynamic>();
      return SavedPlace(
        tour: TourModel.fromJson(data),
        savedAt: DateTime.tryParse(r['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }

  Future<void> saveTourToWishlist(TourModel tour) async {
    await _client.from('saved_places').upsert({
      'user_id': _currentUid,
      'tour_key': _tourKey(tour),
      'tour_data': _tourToJson(tour),
    }, onConflict: 'user_id,tour_key');
  }

  Future<void> removeTourFromWishlist(TourModel tour) async {
    await _client
        .from('saved_places')
        .delete()
        .eq('user_id', _currentUid)
        .eq('tour_key', _tourKey(tour));
  }

  // ---------------------------------------------------------------- trip collection

  Future<Map<String, List<SavedPlace>>> getAllTripCollections() async {
    final rows = await _client
        .from('trip_collection')
        .select('plan_id, tour_data, created_at, plans!inner(user_id)')
        .eq('plans.user_id', _currentUid);
    final out = <String, List<SavedPlace>>{};
    for (final r in rows) {
      final tripId = r['plan_id'] as String;
      final data = (r['tour_data'] as Map).cast<String, dynamic>();
      final place = SavedPlace(
        tour: TourModel.fromJson(data),
        savedAt: DateTime.tryParse(r['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
      (out[tripId] ??= []).add(place);
    }
    return out;
  }

  Future<void> addTourToTripCollection(String tripId, TourModel tour) async {
    await _client.from('trip_collection').upsert({
      'plan_id': tripId,
      'tour_key': _tourKey(tour),
      'tour_data': _tourToJson(tour),
    }, onConflict: 'plan_id,tour_key');
  }

  Future<void> removeTourFromTripCollection(
      String tripId, TourModel tour) async {
    await _client
        .from('trip_collection')
        .delete()
        .eq('plan_id', tripId)
        .eq('tour_key', _tourKey(tour));
  }

  // ---------------------------------------------------------------- day plan

  Future<Map<String, List<DayPlanItem>>> getAllDayPlans() async {
    final rows = await _client
        .from('trip_day_plan')
        .select('id, plan_id, day, time, title, location, note, plans!inner(user_id)')
        .eq('plans.user_id', _currentUid);
    final out = <String, List<DayPlanItem>>{};
    for (final r in rows) {
      final tripId = r['plan_id'] as String;
      final item = DayPlanItem(
        id: r['id'] as String?,
        tripId: tripId,
        day: (r['day'] as num).toInt(),
        time: r['time'] as String,
        title: r['title'] as String,
        location: r['location'] as String?,
        note: r['note'] as String?,
      );
      (out[tripId] ??= []).add(item);
    }
    return out;
  }

  Future<String> addDayPlanItem(DayPlanItem item) async {
    final row = await _client.from('trip_day_plan').insert({
      'plan_id': item.tripId,
      'day': item.day,
      'time': item.time,
      'title': item.title,
      'location': item.location,
      'note': item.note,
    }).select('id').single();
    return row['id'] as String;
  }

  Future<void> removeDayPlanItem(String id) async {
    await _client.from('trip_day_plan').delete().eq('id', id);
  }

  // ---------------------------------------------------------------- expenses

  Future<Map<String, List<ExpenseItem>>> getAllExpenses() async {
    final rows = await _client
        .from('trip_expenses')
        .select(
            'id, plan_id, label, amount, category, spent_at, plans!inner(user_id)')
        .eq('plans.user_id', _currentUid);
    final out = <String, List<ExpenseItem>>{};
    for (final r in rows) {
      final tripId = r['plan_id'] as String;
      final item = ExpenseItem(
        id: r['id'] as String?,
        tripId: tripId,
        label: r['label'] as String,
        amount: (r['amount'] as num).toDouble(),
        category: r['category'] as String,
        date: DateTime.tryParse(r['spent_at'] as String? ?? '') ??
            DateTime.now(),
      );
      (out[tripId] ??= []).add(item);
    }
    return out;
  }

  Future<String> addExpense(ExpenseItem item) async {
    final row = await _client.from('trip_expenses').insert({
      'plan_id': item.tripId,
      'label': item.label,
      'amount': item.amount,
      'category': item.category,
      'spent_at': item.date.toIso8601String(),
    }).select('id').single();
    return row['id'] as String;
  }

  Future<void> removeExpense(String id) async {
    await _client.from('trip_expenses').delete().eq('id', id);
  }

  // ---------------------------------------------------------------- memories

  Future<Map<String, List<MemoryItem>>> getAllMemories() async {
    final rows = await _client
        .from('trip_memories')
        .select(
            'id, plan_id, image_url, caption, created_at, plans!inner(user_id)')
        .eq('plans.user_id', _currentUid);
    final out = <String, List<MemoryItem>>{};
    for (final r in rows) {
      final tripId = r['plan_id'] as String;
      final item = MemoryItem(
        id: r['id'] as String?,
        tripId: tripId,
        imagePath: r['image_url'] as String,
        caption: r['caption'] as String?,
        createdAt: DateTime.tryParse(r['created_at'] as String? ?? '') ??
            DateTime.now(),
        isAsset: false,
      );
      (out[tripId] ??= []).add(item);
    }
    return out;
  }

  Future<String> uploadMemoryImage(String localPath) async {
    final ext = localPath.split('.').last.toLowerCase();
    final path =
        '$_currentUid/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage
        .from('memories')
        .upload(path, File(localPath));
    return _client.storage.from('memories').getPublicUrl(path);
  }

  Future<String> addMemory({
    required String tripId,
    required String imageUrl,
    String? caption,
  }) async {
    final row = await _client.from('trip_memories').insert({
      'plan_id': tripId,
      'image_url': imageUrl,
      'caption': caption,
    }).select('id').single();
    return row['id'] as String;
  }

  Future<void> removeMemory(String id) async {
    await _client.from('trip_memories').delete().eq('id', id);
  }

  // ---------------------------------------------------------------- invites

  Future<Map<String, List<String>>> getAllInvites() async {
    final rows = await _client
        .from('trip_invites')
        .select('plan_id, email, plans!inner(user_id)')
        .eq('plans.user_id', _currentUid);
    final out = <String, List<String>>{};
    for (final r in rows) {
      final tripId = r['plan_id'] as String;
      (out[tripId] ??= []).add(r['email'] as String);
    }
    return out;
  }

  Future<void> addInvite(String tripId, String email) async {
    await _client.from('trip_invites').upsert({
      'plan_id': tripId,
      'email': email,
    }, onConflict: 'plan_id,email');
  }

  Future<void> removeInvite(String tripId, String email) async {
    await _client
        .from('trip_invites')
        .delete()
        .eq('plan_id', tripId)
        .eq('email', email);
  }

  // ---------------------------------------------------------------- onboarding

  Future<void> saveUserOnboarding({
    required List<String> interests,
    required String travelStyle,
    required String preferredBudget,
  }) async {
    await _client.from('users').update({
      'interests': interests,
      'travel_style': travelStyle,
      'preferred_budget': preferredBudget,
      'onboarding_done': true,
    }).eq('id', _currentUid);
  }

  Future<bool> isOnboardingDone() async {
    final row = await _client
        .from('users')
        .select('onboarding_done')
        .eq('id', _currentUid)
        .maybeSingle();
    return row?['onboarding_done'] == true;
  }

  // ---------------------------------------------------------------- cards

  Future<void> addNewCard(CardModel model) async {
    await _client.from('cards').insert({
      'user_id': _currentUid,
      'card_number': model.CardNumber,
      'card_holder_name': model.CardHolerName,
      'cvc': model.CVC,
      'is_default_card': model.isDefaultCard,
      'expiration_date': model.expirationDate.toIso8601String().split('T').first,
    });
  }
}
