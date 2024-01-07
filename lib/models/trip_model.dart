import 'package:travel_app/models/trip_details.dart';

class Trip {
  String? id;
  String? name;
  String? destination;
  String? startDate;
  String? endDate;
  TripDetails? details; // Include the details property in Trip

  Trip({
    this.id,
    this.name,
    this.destination,
    this.startDate,
    this.endDate,
    this.details, // Initialize details property in the constructor
  });

  Trip.fromJson(Map<String, dynamic> data) {
    this.id = data["id"] ?? "";
    this.name = data["tripName"] ?? "tripName";
    this.destination = data["destination"] ?? "destination";
    this.startDate = data["startDate"] ?? "";
    this.endDate = data["endDate"] ?? "";
  }

  get accommodation => null;

  get travelMethod => null;

  get budget => null;

  get numberOfPeople => null;

  get extraNotes => null;

  Map<String, dynamic> toMap() {
    final map = {
      "id": id,
      "tripName": name,
      "destination": destination,
      "startDate": startDate,
      "endDate": endDate,
      "details": details?.toMap(), // Convert details to Map
    };

    return map;
  }
}
