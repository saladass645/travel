class TripChecklist {
  List<TripChecklist> checklistItems = [];

  // Updated constructor to include the 'item' parameter
  TripChecklist({required this.checklistItems});

  Map<String, dynamic> toMap() {
    return {
      'checklistItems': checklistItems.map((item) => item.toMap()).toList(),
    };
  }

  factory TripChecklist.fromMap(Map<String, dynamic> map) {
    return TripChecklist(
      checklistItems: List<TripChecklist>.from(
        (map['checklistItems'] as List<dynamic>).map(
          (item) => TripChecklist.fromMap(item),
        ),
      ),
    );
  }
}
