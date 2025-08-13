import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_food_gpt_web/providers/app_state.dart';
import 'package:flutter_food_gpt_web/screens/result_screen/result_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class FoodTrackingScreen extends StatelessWidget {
  const FoodTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Food Tracking',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Container(
                height: 500,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: appState.selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    appState.selectedImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
                    : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 64, color: Colors.grey),
                      Text('No image selected'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(context, ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(context, ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Help text for web users
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Camera access will prompt for permission automatically. Gallery access works without special permissions.',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Analyze button
              ElevatedButton(
                onPressed: appState.selectedImage != null && !appState.isLoading
                    ? () => _analyzeImage(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: appState.isLoading
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Analyzing...'),
                  ],
                )
                    : const Text('Analyze Food'),
              ),

              if (appState.selectedImage != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: appState.clearImage,
                  child: const Text('Clear Image'),
                ),
              ],

              // Error display
              if (appState.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          appState.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();

      // For web, we don't need to request permissions explicitly
      // The browser will handle permission dialogs automatically
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 2048,
        imageQuality: 85, // Compress for better performance
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (context.mounted) {
          context.read<AppState>().setSelectedImage(Uint8List.fromList(bytes));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image ${source == ImageSource.camera ? "captured" : "uploaded"} successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = 'Error picking image';

        if (e.toString().contains('camera')) {
          errorMessage = 'Camera access denied. Please allow camera permission in your browser.';
        } else if (e.toString().contains('gallery') || e.toString().contains('photo')) {
          errorMessage = 'File access denied. Please try uploading an image file.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Help',
              textColor: Colors.white,
              onPressed: () {
                _showPermissionHelp(context);
              },
            ),
          ),
        );
      }
    }
  }

  void _showPermissionHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera/File Access Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('If you\'re having trouble with camera or file access:'),
            SizedBox(height: 8),
            Text('🔹 For Camera: Click the camera icon in your browser\'s address bar and allow camera access'),
            SizedBox(height: 4),
            Text('🔹 For Gallery: Make sure you\'re selecting image files (JPG, PNG)'),
            SizedBox(height: 4),
            Text('🔹 Try refreshing the page if permissions were recently changed'),
            SizedBox(height: 4),
            Text('🔹 Use HTTPS or localhost for camera access'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _analyzeImage(BuildContext context) async {
    await context.read<AppState>().analyzeFoodImage(context);

    if (context.mounted) {
      final appState = context.read<AppState>();
      if (appState.foodItems.isNotEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ResultsScreen()),
        );
      }
    }
  }
}