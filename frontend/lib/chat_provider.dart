import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'message.dart';
import 'dart:developer' as developer;

class ChatProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  List<Message> get messages => _messages;

  late WebSocketChannel _channel;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  ChatProvider() {
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8000/chat'),
      );
      _isConnected = true;
      developer.log('WebSocket connected successfully');

      _channel.stream.listen(
        (message) {
          developer.log('Received message: $message');
          if (message.startsWith('User: ')) {
            // This is an echo of the user's message, we can ignore it
            return;
          }

          if (message == '\n') {
            // End of the response, add a new line
            _addToLastMessage('\n');
          } else {
            // Add the new word to the last message
            _addToLastMessage(message);
          }
          notifyListeners();
        },
        onError: (error) {
          developer.log('WebSocket error: $error');
          _isConnected = false;
          notifyListeners();
        },
        onDone: () {
          developer.log('WebSocket connection closed');
          _isConnected = false;
          notifyListeners();
        },
      );
    } catch (e) {
      developer.log('Error connecting to WebSocket: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  void _addToLastMessage(String text) {
    if (_messages.isNotEmpty && !_messages.last.isUserMessage) {
      // If the last message is from the AI, append to it
      _messages.last.appendText(text);
    } else {
      // If the last message is from the user or there are no messages, create a new AI message
      _messages.add(Message(text: text, isUserMessage: false));
    }
  }

  void sendMessage(String text) {
    if (text.isNotEmpty) {
      if (_isConnected) {
        _messages.add(Message(text: text, isUserMessage: true));
        _channel.sink.add(text);
        developer.log('Sent message: $text');
        notifyListeners();
      } else {
        developer.log('Cannot send message: WebSocket is not connected');
        // You might want to show an error message to the user here
      }
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
