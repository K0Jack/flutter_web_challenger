import 'food_item.dart';

class NutritionSummary {
  final double totalKcal;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalGrams;

  NutritionSummary({
    required this.totalKcal,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalGrams,
  });

  factory NutritionSummary.fromFoodItems(List<FoodItem> items) {
    double kcal = 0, protein = 0, carbs = 0, fat = 0, grams = 0;

    for (var item in items) {
      kcal += item.kcal;
      protein += item.protein;
      carbs += item.carbs;
      fat += item.fat;
      grams += item.grams;
    }

    return NutritionSummary(
      totalKcal: kcal,
      totalProtein: protein,
      totalCarbs: carbs,
      totalFat: fat,
      totalGrams: grams,
    );
  }
}