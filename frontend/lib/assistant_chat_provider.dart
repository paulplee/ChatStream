import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'message.dart';

class AssistantChatProvider with ChangeNotifier {
  final List<Message> _messages = [];
  List<Message> get messages => _messages;

  late WebSocketChannel _channel;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void connect() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8000/asst'),
    );
    _isConnected = true;
    _channel.stream.listen(_onMessage, onDone: _onDone, onError: _onError);
    notifyListeners();
  }

  void disconnect() {
    _channel.sink.close();
    _isConnected = false;
    notifyListeners();
  }

  void sendMessage(String content) {
    if (_isConnected) {
      _channel.sink.add(content);
      _messages.add(Message(text: content, isUserMessage: true));
      notifyListeners();
    }
  }

  void _onMessage(dynamic message) {
    if (message is String) {
      if (_messages.isNotEmpty && !_messages.last.isUserMessage) {
        _messages.last.appendText(message);
      } else {
        _messages.add(Message(text: message, isUserMessage: false));
      }
      notifyListeners();
    }
  }

  void _onDone() {
    _isConnected = false;
    notifyListeners();
  }

  void _onError(error) {
    // print('WebSocket error: $error');
    _isConnected = false;
    notifyListeners();
  }
}
