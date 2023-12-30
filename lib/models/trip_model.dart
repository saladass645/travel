import 'package:travel_app/models/trip_details.dart';

class Trip {
  int? id; // Change the type to int
  String? name;
  String? destination;
  String? startDate;
  String? endDate;
  TripDetails? details; // Added TripDetails field
  bool? favorite; // Added favorite field

  Trip({
    this.id,
    this.name,
    this.destination,
    this.startDate,
    this.endDate,
    this.details,
    this.favorite,
  });

  Trip.fromJson(Map<String, dynamic> data) {
    this.id =
        data["id"] ?? 0; // Change the default value to 0 or adjust as needed
    this.name = data["name"] ?? "tripName";
    this.destination = data["destination"] ?? "destination";
    this.startDate = data["startDate"] ?? "";
    this.endDate = data["endDate"] ?? "";
    this.favorite = data["favorite"] ??
        false; // Change the default value to false or adjust as needed
    if (data.containsKey("details")) {
      this.details = TripDetails.fromJson(data["details"]);
    }
  }

  Map<String, dynamic> get toMap {
    return {
      "title": this.name,
      "destination": this.destination,
      "dateStart": this.startDate,
      "dateEnd": this.endDate,
    };
  }
}
