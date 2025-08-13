import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_food_gpt_web/models/food_item.dart';
import 'package:flutter_food_gpt_web/shares/utils/constants.dart';
import 'package:flutter_food_gpt_web/shares/utils/logger.dart';
import 'package:http/http.dart' as http;

class GPTService {
  static Future<List<FoodItem>> analyzeFoodImage(Uint8List imageBytes) async {
    try {
      return await _analyzeWithGemini(imageBytes);
    } catch (e) {
      logger.e('Gemini API failed: $e');

      try {
        return await _analyzeWithOpenAI(imageBytes);
      } catch (e2) {
        logger.e('OpenAI API failed: $e2');

        return _mockAnalyzeFoodImage();
      }
    }
  }

  static Future<List<FoodItem>> _analyzeWithGemini(Uint8List imageBytes) async {
    if (geminiApiKey.isEmpty) {
      throw Exception('Please set your Gemini API key');
    }

    final base64Image = base64Encode(imageBytes);

    final response = await http.post(
      Uri.parse('$geminiBaseUrl?key=$geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': '''
Analyze this food image and identify all visible food items.
If the image does NOT contain any food, respond ONLY with:
{
  "foods": []
}

Format (if food detected):
{
  "foods": [
    {
      "name": "Food item name in English or Vietnamese",
      "grams": estimated_weight_in_grams,
      "kcal": estimated_calories,
      "protein": protein_in_grams,
      "carbs": carbohydrates_in_grams,
      "fat": fat_in_grams
    }
  ]
}

Guidelines:
- Estimate realistic portion sizes (50-500g per item)
- Use accurate nutritional values per 100g, then scale to portion size
- Include all visible food items (max 5 items)
- Ensure all numbers are realistic and properly calculated
''',
              },
              {
                'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image},
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.1,
          'topK': 32,
          'topP': 1,
          'maxOutputTokens': 1024,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      logger.i(data);

      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final content =
            data['candidates'][0]['content']['parts'][0]['text'] ?? '';

        final cleanedContent = content.trim();
        final startIndex = cleanedContent.indexOf('{');
        final endIndex = cleanedContent.lastIndexOf('}') + 1;

        if (startIndex != -1 && endIndex > startIndex) {
          final jsonString = cleanedContent.substring(startIndex, endIndex);
          final foodData = jsonDecode(jsonString);

          if (foodData['foods'] == null ||
              (foodData['foods'] as List).isEmpty) {
            logger.e('No food detect');
            return [];
          }

          return (foodData['foods'] as List)
              .map((item) => FoodItem.fromJson(item))
              .toList();
        }
      }

      throw Exception('Invalid response format from Gemini API');
    } else {
      final errorData = jsonDecode(response.body);
      logger.e(errorData);

      throw Exception(
        'Gemini API error: ${response.statusCode} - ${errorData['error']?['message'] ?? 'Unknown error'}',
      );
    }
  }

  static Future<List<FoodItem>> _analyzeWithOpenAI(Uint8List imageBytes) async {
    if (openaiApiKey == 'YOUR_OPENAI_API_KEY_HERE') {
      throw Exception('Please set your OpenAI API key');
    }

    final base64Image = base64Encode(imageBytes);

    final response = await http.post(
      Uri.parse(openaiBaseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openaiApiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text':
                    '''Analyze this food image and return a JSON response with detected food items. Format: 
                {
                  "foods": [
                    {
                      "name": "item_name",
                      "grams": estimated_weight,
                      "kcal": calories,
                      "protein": protein_g,
                      "carbs": carbs_g,
                      "fat": fat_g
                    }
                  ]
                }''',
              },
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
              },
            ],
          },
        ],
        'max_tokens': 1000,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];

      final startIndex = content.indexOf('{');
      final endIndex = content.lastIndexOf('}') + 1;
      final jsonString = content.substring(startIndex, endIndex);
      final foodData = jsonDecode(jsonString);

      return (foodData['foods'] as List)
          .map((item) => FoodItem.fromJson(item))
          .toList();
    } else {
      throw Exception('OpenAI API error: ${response.statusCode}');
    }
  }

  static Future<List<FoodItem>> _mockAnalyzeFoodImage() async {
    await Future.delayed(const Duration(seconds: 2));

    final List<Map<String, dynamic>> foodDatabase = [
      {
        'name': 'Cơm trắng',
        'kcal_per_100g': 130,
        'protein': 2.7,
        'carbs': 28,
        'fat': 0.3,
      },
      {
        'name': 'Phở bò',
        'kcal_per_100g': 85,
        'protein': 6.2,
        'carbs': 9.8,
        'fat': 2.1,
      },
      {
        'name': 'Bánh mì',
        'kcal_per_100g': 250,
        'protein': 8.5,
        'carbs': 48,
        'fat': 3.2,
      },
      {
        'name': 'Thịt heo nướng',
        'kcal_per_100g': 280,
        'protein': 25,
        'carbs': 0,
        'fat': 20,
      },
      {
        'name': 'Gà luộc',
        'kcal_per_100g': 165,
        'protein': 31,
        'carbs': 0,
        'fat': 3.6,
      },
      {
        'name': 'Cá hồi nướng',
        'kcal_per_100g': 208,
        'protein': 25.4,
        'carbs': 0,
        'fat': 12.4,
      },
      {
        'name': 'Rau muống xào',
        'kcal_per_100g': 25,
        'protein': 2.9,
        'carbs': 3.1,
        'fat': 0.3,
      },
      {
        'name': 'Canh chua cá',
        'kcal_per_100g': 45,
        'protein': 8.5,
        'carbs': 2.1,
        'fat': 0.8,
      },
      {
        'name': 'Chả cá thăng long',
        'kcal_per_100g': 190,
        'protein': 18,
        'carbs': 3,
        'fat': 11,
      },
      {
        'name': 'Nem nướng',
        'kcal_per_100g': 250,
        'protein': 15,
        'carbs': 8,
        'fat': 17,
      },

      {
        'name': 'Grilled Chicken Breast',
        'kcal_per_100g': 165,
        'protein': 31,
        'carbs': 0,
        'fat': 3.6,
      },
      {
        'name': 'Brown Rice',
        'kcal_per_100g': 111,
        'protein': 2.6,
        'carbs': 23,
        'fat': 0.9,
      },
      {
        'name': 'Steamed Broccoli',
        'kcal_per_100g': 34,
        'protein': 2.8,
        'carbs': 7,
        'fat': 0.4,
      },
      {
        'name': 'Salmon Fillet',
        'kcal_per_100g': 208,
        'protein': 25.4,
        'carbs': 0,
        'fat': 12.4,
      },
      {
        'name': 'Sweet Potato',
        'kcal_per_100g': 86,
        'protein': 1.6,
        'carbs': 20,
        'fat': 0.1,
      },
      {
        'name': 'Avocado',
        'kcal_per_100g': 160,
        'protein': 2,
        'carbs': 9,
        'fat': 15,
      },
      {
        'name': 'Greek Yogurt',
        'kcal_per_100g': 59,
        'protein': 10,
        'carbs': 3.6,
        'fat': 0.4,
      },
      {
        'name': 'Quinoa',
        'kcal_per_100g': 120,
        'protein': 4.4,
        'carbs': 22,
        'fat': 1.9,
      },
      {
        'name': 'Green Salad',
        'kcal_per_100g': 15,
        'protein': 1.5,
        'carbs': 3,
        'fat': 0.2,
      },
      {
        'name': 'Beef Steak',
        'kcal_per_100g': 250,
        'protein': 26,
        'carbs': 0,
        'fat': 17,
      },
      {
        'name': 'Pasta',
        'kcal_per_100g': 131,
        'protein': 5,
        'carbs': 25,
        'fat': 1.1,
      },
      {
        'name': 'Fried Egg',
        'kcal_per_100g': 155,
        'protein': 13,
        'carbs': 1.1,
        'fat': 11,
      },
      {
        'name': 'Banana',
        'kcal_per_100g': 89,
        'protein': 1.1,
        'carbs': 23,
        'fat': 0.3,
      },
      {
        'name': 'Apple',
        'kcal_per_100g': 52,
        'protein': 0.3,
        'carbs': 14,
        'fat': 0.2,
      },
      {
        'name': 'Cheese',
        'kcal_per_100g': 400,
        'protein': 25,
        'carbs': 1.3,
        'fat': 33,
      },
    ];

    final random = DateTime.now().millisecondsSinceEpoch;
    final itemCount = 2 + (random % 4); // 2-5 items
    final selectedFoods = <Map<String, dynamic>>[];

    for (int i = 0; i < itemCount; i++) {
      final index = (random + i * 17) % foodDatabase.length;
      selectedFoods.add(foodDatabase[index]);
    }

    return selectedFoods.asMap().entries.map((entry) {
      final food = entry.value;
      final portionSeed = (random + entry.key * 23) % 1000;

      double portion = 50.0 + (portionSeed % 251);

      portion = (portion / 10).round() * 10.0;

      final multiplier = portion / 100.0;

      return FoodItem(
        name: food['name'],
        grams: portion,
        kcal: (food['kcal_per_100g'] * multiplier),
        protein: (food['protein'] * multiplier),
        carbs: (food['carbs'] * multiplier),
        fat: (food['fat'] * multiplier),
      );
    }).toList();
  }
}
