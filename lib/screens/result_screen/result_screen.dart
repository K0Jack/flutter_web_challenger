import 'package:flutter/material.dart';
import 'package:flutter_food_gpt_web/models/food_item.dart';
import 'package:flutter_food_gpt_web/providers/app_state.dart';
import 'package:provider/provider.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Results'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final summary = appState.nutritionSummary;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Nutrition',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildNutritionRow('Total Weight', '${summary.totalGrams.toStringAsFixed(0)}g'),
                        _buildNutritionRow('Calories', '${summary.totalKcal.toStringAsFixed(0)} kcal'),
                        _buildNutritionRow('Protein', '${summary.totalProtein.toStringAsFixed(1)}g'),
                        _buildNutritionRow('Carbs', '${summary.totalCarbs.toStringAsFixed(1)}g'),
                        _buildNutritionRow('Fat', '${summary.totalFat.toStringAsFixed(1)}g'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Food Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                // Food items list
                Expanded(
                  child: ListView.builder(
                    itemCount: appState.foodItems.length,
                    itemBuilder: (context, index) {
                      final item = appState.foodItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${item.grams.toStringAsFixed(0)}g • ${item.kcal.toStringAsFixed(0)} kcal'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  // Editable portion
                                  Row(
                                    children: [
                                      const Text('Portion: '),
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: item.grams.toStringAsFixed(0),
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            suffix: Text('g'),
                                            isDense: true,
                                          ),
                                          onFieldSubmitted: (value) {
                                            final newGrams = double.tryParse(value) ?? item.grams;
                                            _updatePortion(context, index, item, newGrams);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _buildNutritionRow('Protein', '${item.protein.toStringAsFixed(1)}g'),
                                  _buildNutritionRow('Carbs', '${item.carbs.toStringAsFixed(1)}g'),
                                  _buildNutritionRow('Fat', '${item.fat.toStringAsFixed(1)}g'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _updatePortion(BuildContext context, int index, FoodItem originalItem, double newGrams) {
    if (newGrams <= 0) return;

    final ratio = newGrams / originalItem.grams;
    final updatedItem = originalItem.copyWith(
      grams: newGrams,
      kcal: originalItem.kcal * ratio,
      protein: originalItem.protein * ratio,
      carbs: originalItem.carbs * ratio,
      fat: originalItem.fat * ratio,
    );

    context.read<AppState>().updateFoodItem(index, updatedItem);
  }
}