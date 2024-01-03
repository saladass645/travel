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

  // Named constructor to create TripDetails from a Map
  TripDetails.fromMap(Map<String, dynamic>? detailsMap) {
    if (detailsMap != null) {
      travelMethod = detailsMap["travelMethod"];
      accommodation = detailsMap["accommodation"];
      budget = detailsMap["budget"]?.toDouble();
      numberOfPeople = detailsMap["numberOfPeople"]?.toInt();
      extraNotes = detailsMap["extraNotes"];
    }
  }

  // Override toString for better logging
  @override
  String toString() {
    return 'TripDetails{'
        'travelMethod: $travelMethod, '
        'accommodation: $accommodation, '
        'budget: $budget, '
        'numberOfPeople: $numberOfPeople, '
        'extraNotes: $extraNotes}';
  }

  // Convert TripDetails to a Map
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
