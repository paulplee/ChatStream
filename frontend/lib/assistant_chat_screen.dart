import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'assistant_chat_provider.dart';
import 'message_bubble.dart';

class AssistantChatScreen extends StatefulWidget {
  @override
  _AssistantChatScreenState createState() => _AssistantChatScreenState();
}

class _AssistantChatScreenState extends State<AssistantChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AssistantChatProvider>(context, listen: false).connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assistant Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<AssistantChatProvider>(
              builder: (context, chatProvider, child) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    return MessageBubble(
                      text: message.text,
                      isUserMessage: message.isUserMessage,
                      timestamp: message.timestamp,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(String text) {
    if (text.isNotEmpty) {
      _textController.clear();
      Provider.of<AssistantChatProvider>(context, listen: false)
          .sendMessage(text);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    Provider.of<AssistantChatProvider>(context, listen: false).disconnect();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
