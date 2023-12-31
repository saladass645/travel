import 'package:travel_app/models/trip_details.dart';

class Trip {
  String? id;
  String? name;
  String? destination;
  String? startDate;
  String? endDate;
  TripDetails? details;

  Trip({
    this.id,
    this.name,
    this.destination,
    this.startDate,
    this.endDate,
    this.details,
  });

  Trip.fromJson(Map<String, dynamic> data) {
    this.id = data["id"] ?? "";
    this.name = data["tripName"] ?? "tripName";
    this.destination = data["destination"] ?? "destination";
    this.startDate = data["startDate"] ?? "";
    this.endDate = data["endDate"] ?? "";
    if (data.containsKey("details")) {
      this.details = TripDetails.fromJson(data["details"]);
    }
  }

  Map<String, dynamic> toMap() {
    final map = {
      "id": id,
      "tripName": name,
      "destination": destination,
      "startDate": startDate,
      "endDate": endDate,
    };

    if (details != null) {
      map["details"] = details!.toMap();
    }

    return map;
  }
}
