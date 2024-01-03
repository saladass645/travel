class TripChecklist {
  late String tripId;
  late String item;
  List<TripChecklist> checklistItems = [];

  // Updated constructor to include the 'item' parameter
  TripChecklist(
      {required this.tripId, required this.item, required this.checklistItems});

  // Method to update the 'item'
  void updateItem(String newItem) {
    item = newItem;
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'item': item,
      'checklistItems': checklistItems.map((item) => item.toMap()).toList(),
    };
  }

  factory TripChecklist.fromMap(Map<String, dynamic> map) {
    return TripChecklist(
      tripId: map['tripId'],
      item: map['item'],
      checklistItems: List<TripChecklist>.from(
        (map['checklistItems'] as List<dynamic>).map(
          (item) => TripChecklist.fromMap(item),
        ),
      ),
    );
  }
}
