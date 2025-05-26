class MealItem {
  final int foodId; // Thêm trường này
  final String name;
  final int kcal;
  final int portion;
  final int size;

  MealItem({
    required this.foodId,
    required this.name,
    required this.kcal,
    required this.portion,
    required this.size,
  });
}
