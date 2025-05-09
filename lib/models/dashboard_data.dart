class DashboardData {
  final double calorieConsumed;
  final double calorieRemaining;
  final double protein;
  final double fat;
  final double carb;

  DashboardData({
    required this.calorieConsumed,
    required this.calorieRemaining,
    required this.protein,
    required this.fat,
    required this.carb,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      calorieConsumed: double.parse(json['calories_consumed']),
      calorieRemaining: double.parse(json['calories_remaining']),
      protein: double.parse(json['protein_consumed']),
      fat: double.parse(json['fat_consumed']),
      carb: double.parse(json['carbs_consumed']),
    );
  }
}
