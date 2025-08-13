class FoodItem {
  final String name;
  final double grams;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;

  FoodItem({
    required this.name,
    required this.grams,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] ?? '',
      grams: (json['grams'] ?? 0).toDouble(),
      kcal: (json['kcal'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
    );
  }

  FoodItem copyWith({
    String? name,
    double? grams,
    double? kcal,
    double? protein,
    double? carbs,
    double? fat,
  }) {
    return FoodItem(
      name: name ?? this.name,
      grams: grams ?? this.grams,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }
}