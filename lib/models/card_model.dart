class CardModel {
  final int CardNumber;
  final String CardHolerName;
  final DateTime expirationDate;
  final String CVC;
  final bool isDefaultCard;

  CardModel({
    required this.CardNumber,
    required this.CardHolerName,
    required this.expirationDate,
    required this.CVC,
    required this.isDefaultCard,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      CardNumber: json['CardNumber'],
      CardHolerName: json['CardHolerName'],
      expirationDate: json['expirationDate'] is DateTime
          ? json['expirationDate'] as DateTime
          : DateTime.parse(json['expirationDate'] as String),
      CVC: json['CVC'],
      isDefaultCard: json['isDefaultCard'],
    );
  }

  Map<String, dynamic> get toMap {
    return {
      'CardNumber': CardNumber,
      'CardHolerName': CardHolerName,
      'expirationDate': expirationDate.toIso8601String(),
      'CVC': CVC,
      'isDefaultCard': isDefaultCard,
    };
  }
}
