class Message {
  String text;
  final bool isUserMessage;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUserMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  void appendText(String newText) {
    text += newText;
  }
}
