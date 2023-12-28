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

  // Add a named constructor for creating an instance from JSON
  factory TripDetails.fromJson(Map<String, dynamic> json) {
    return TripDetails(
      travelMethod: json['travelMethod'],
      accommodation: json['accommodation'],
      budget: json['budget']?.toDouble(),
      numberOfPeople: json['numberOfPeople'],
      extraNotes: json['extraNotes'],
    );
  }
}
