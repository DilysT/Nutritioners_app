class DiaryData {
  final double caloriesConsumed;
  final double caloriesRemaining;
  final double proteinConsumed;
  final double proteinRemaining;
  final double fatConsumed;
  final double fatRemaining;
  final double carbsConsumed;
  final double carbsRemaining;

  DiaryData({
    required this.caloriesConsumed,
    required this.caloriesRemaining,
    required this.proteinConsumed,
    required this.proteinRemaining,
    required this.fatConsumed,
    required this.fatRemaining,
    required this.carbsConsumed,
    required this.carbsRemaining,
  });

  factory DiaryData.fromJson(Map<String, dynamic> json) {
    return DiaryData(
      caloriesConsumed: double.tryParse(json['calories_consumed'].toString()) ?? 0.0,
      caloriesRemaining: double.tryParse(json['calories_remaining'].toString()) ?? 0.0,
      proteinConsumed: double.tryParse(json['protein_consumed'].toString()) ?? 0.0,
      proteinRemaining: double.tryParse(json['protein_remaining'].toString()) ?? 0.0,
      fatConsumed: double.tryParse(json['fat_consumed'].toString()) ?? 0.0,
      fatRemaining: double.tryParse(json['fat_remaining'].toString()) ?? 0.0,
      carbsConsumed: double.tryParse(json['carbs_consumed'].toString()) ?? 0.0,
      carbsRemaining: double.tryParse(json['carbs_remaining'].toString()) ?? 0.0,
    );
  }
}

