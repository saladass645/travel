class TripDetails {
  String? travelMethod;
  String? accommodation;
  double? budget;
  int? numberOfPeople;
  String? extraNotes;

  TripDetails({
    this.travelMethod,
    this.accommodation,
    this.budget,
    this.numberOfPeople,
    this.extraNotes,
  });

  TripDetails.fromJson(Map<String, dynamic> data) {
    this.travelMethod = data["travelMethod"];
    this.accommodation = data["accommodation"];
    this.budget = data["budget"]?.toDouble(); // Convert to double
    this.numberOfPeople = data["numberOfPeople"]?.toInt(); // Convert to int
    this.extraNotes = data["extraNotes"];
  }

  Map<String, dynamic> toMap() {
    final map = {
      "travelMethod": travelMethod,
      "accommodation": accommodation,
      "budget": budget,
      "numberOfPeople": numberOfPeople,
      "extraNotes": extraNotes,
    };

    return map;
  }
}
