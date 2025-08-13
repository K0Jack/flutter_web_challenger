import 'package:intl/intl.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isAdmin;
  final DateTime timestamp;
  final String senderName;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isAdmin,
    required this.timestamp,
    required this.senderName,
  });

  String get formattedTime => DateFormat('HH:mm').format(timestamp);
}