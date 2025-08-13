import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_food_gpt_web/models/chat_message.dart';
import 'package:flutter_food_gpt_web/models/food_item.dart';
import 'package:flutter_food_gpt_web/models/nutrition_summary.dart';
import 'package:flutter_food_gpt_web/services/gpt_service.dart';

class AppState extends ChangeNotifier {
  // Food tracking state
  Uint8List? _selectedImage;
  List<FoodItem> _foodItems = [];
  bool _isLoading = false;
  String? _error;

  // Chat state
  List<ChatMessage> _messages = [];
  bool _isAdmin = false;

  // Getters
  Uint8List? get selectedImage => _selectedImage;

  List<FoodItem> get foodItems => _foodItems;

  bool get isLoading => _isLoading;

  String? get error => _error;

  List<ChatMessage> get messages => _messages;

  bool get isAdmin => _isAdmin;

  NutritionSummary get nutritionSummary =>
      NutritionSummary.fromFoodItems(_foodItems);

  // Food tracking methods
  void setSelectedImage(Uint8List image) {
    _selectedImage = image;
    _error = null;
    notifyListeners();
  }

  void clearImage() {
    _selectedImage = null;
    _foodItems = [];
    _error = null;
    notifyListeners();
  }

  Future<void> analyzeFoodImage(BuildContext context) async {
    if (_selectedImage == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await GPTService.analyzeFoodImage(_selectedImage!);
      if (result.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Can not detect this image, please try again!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
      _foodItems = result;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFoodItem(int index, FoodItem newItem) {
    if (index >= 0 && index < _foodItems.length) {
      _foodItems[index] = newItem;
      notifyListeners();
    }
  }

  // Chat methods
  void toggleUserRole() {
    _isAdmin = !_isAdmin;
    notifyListeners();
  }

  void sendMessage(String content) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isAdmin: _isAdmin,
      timestamp: DateTime.now(),
      senderName: _isAdmin ? 'Admin' : 'User',
    );

    _messages.add(message);
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
