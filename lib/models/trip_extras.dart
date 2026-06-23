import 'package:travel_app/models/tour_model.dart';

class DayPlanItem {
  String? id;
  String tripId;
  int day;
  String time;
  String title;
  String? location;
  String? note;

  DayPlanItem({
    this.id,
    required this.tripId,
    required this.day,
    required this.time,
    required this.title,
    this.location,
    this.note,
  });
}

class ExpenseItem {
  String? id;
  String tripId;
  String label;
  double amount;
  String category;
  DateTime date;

  ExpenseItem({
    this.id,
    required this.tripId,
    required this.label,
    required this.amount,
    required this.category,
    required this.date,
  });
}

class MemoryItem {
  String? id;
  String tripId;
  String imagePath;
  String? caption;
  DateTime createdAt;
  bool isAsset;

  MemoryItem({
    this.id,
    required this.tripId,
    required this.imagePath,
    this.caption,
    required this.createdAt,
    this.isAsset = false,
  });
}

class SavedPlace {
  TourModel tour;
  DateTime savedAt;

  SavedPlace({required this.tour, required this.savedAt});
}
