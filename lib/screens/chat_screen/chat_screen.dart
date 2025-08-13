import 'package:flutter/material.dart';
import 'package:flutter_food_gpt_web/providers/app_state.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(AppState appState) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      appState.sendMessage(message);
      _messageController.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Column(
          children: [
            // Header with role toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    appState.isAdmin
                        ? Colors.blue.shade50
                        : Colors.green.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chatting as: ${appState.isAdmin ? "Admin" : "User"}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: appState.toggleUserRole,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              appState.isAdmin ? Colors.blue : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          'Switch to ${appState.isAdmin ? "User" : "Admin"}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: appState.clearChat,
                        icon: const Icon(Icons.clear_all),
                        tooltip: 'Clear Chat',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child:
                  appState.messages.isEmpty
                      ? const Center(
                        child: Text(
                          'No messages yet. Start a conversation!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: appState.messages.length,
                        itemBuilder: (context, index) {
                          final message = appState.messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(appState),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _sendMessage(appState),
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          appState.isAdmin ? Colors.blue : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageBubble(message) {
    final isAdmin = message.isAdmin;

    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment:
              isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAdmin ? Colors.blue.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isAdmin ? Radius.zero : const Radius.circular(16),
                  bottomRight:
                      isAdmin ? const Radius.circular(16) : Radius.zero,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.senderName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color:
                          isAdmin
                              ? Colors.blue.shade700
                              : Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(message.content),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.formattedTime,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
