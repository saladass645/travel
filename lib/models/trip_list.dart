class TripChecklist {
  late String tripId;
  late String item;
  List<TripChecklist> checklistItems = [];

  TripChecklist({
    required this.tripId,
    required this.item,
    required this.checklistItems,
  });

  Map<String, dynamic> toMap() {
    return {
      'item': item,
      'checklistItems':
          checklistItems.map((subItem) => subItem.toMap()).toList(),
    };
  }

  factory TripChecklist.fromMap(Map<String, dynamic> map) {
    return TripChecklist(
      tripId: map['tripId'],
      item: map['item'],
      checklistItems: (map['checklistItems'] as List<dynamic>? ?? [])
          .map<TripChecklist>(
            (subItem) => TripChecklist.fromMap(subItem),
          )
          .toList(),
    );
  }
}
