import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/helpers/catch_storage.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/models/card_model.dart';
import 'package:travel_app/models/trip_details.dart';
import 'package:travel_app/models/trip_list.dart';
import 'package:travel_app/models/trip_model.dart';
import 'package:travel_app/models/user_model.dart';

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

  /// Continent names for the current language, in sort order.
  Future<List<String>> getContinentNames() async {
    final rows = await _client
        .from('continents')
        .select('name, sort_order')
        .eq('lang', _lang)
        .order('sort_order', ascending: true);
    return rows.map<String>((r) => r['name'] as String).toList();
  }

  /// Popular categories for the current language.
  Future<List<Map<String, dynamic>>> getPopularCategories() async {
    final rows = await _client
        .from('categories')
        .select('name, image, sort_order')
        .eq('lang', _lang)
        .order('sort_order', ascending: true);
    return rows.map((r) => Map<String, dynamic>.from(r)).toList();
  }

  /// Tours for the current language. Maps Postgres snake_case to the
  /// JSON keys [TourModel.fromJson] expects.
  Future<List<Map<String, dynamic>>> getTours() async {
    final rows = await _client.from('tours').select().eq('lang', _lang);
    return rows.map<Map<String, dynamic>>((m) {
      return {
        'id': m['id'],
        'title': m['title'],
        'continent': m['continent'],
        'image': m['image'],
        'images': (m['images'] as List?)?.cast<String>() ?? const <String>[],
        'overview': m['overview'],
        'distance': m['distance'],
        'weather_condition': m['weather_condition'],
        'rating': m['rating'],
        'number_of_reviews': m['number_of_reviews'],
        'started_price': m['started_price'],
        'temperature': m['temperature'],
        'duration_day': m['duration_day'],
        'category': m['category'],
        'extra_price': m['extra_price'],
        'details': m['details'],
        'reviews': m['reviews'],
        'costs': m['costs'],
      };
    }).toList();
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
