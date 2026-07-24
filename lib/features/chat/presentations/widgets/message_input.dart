import 'package:flutter/material.dart';

import 'package:ai_assistant/features/chat/presentations/widgets/validate_text.dart';

class MessageInput extends StatefulWidget {
  final ValueChanged<String> onSend;

  const MessageInput({super.key, required this.onSend});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  late final TextEditingController _messageController;
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                ),
                validator: ValidateText.validateText,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSend(_messageController.text);
                  _messageController.clear();
                }
              },
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
