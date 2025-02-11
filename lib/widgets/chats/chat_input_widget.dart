import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class ChatInputWidget extends StatefulWidget {
  final void Function(String, bool) onSendMessage;
  const ChatInputWidget({super.key, required this.onSendMessage});

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final _messageController = TextEditingController();
  final _focusNode = FocusNode();
  bool _emojiPickerVisible = false;

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    widget.onSendMessage(text, true);
    _messageController.clear();
    setState(() {});
  }

  void _toggleEmojiPicker() {
    // Dismiss keyboard first
    FocusScope.of(context).unfocus();

    setState(() {
      _emojiPickerVisible = !_emojiPickerVisible;
    });

    if (_emojiPickerVisible) {
      // Show emoji picker as bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildEmojiPicker(),
      ).then((_) {
        // Handle when picker is dismissed
        setState(() => _emojiPickerVisible = false);
      });
    }
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      child: Column(
        children: [
          Expanded(
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                _messageController.text += emoji.emoji;
                _messageController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _messageController.text.length),
                );
                // Keep focus but don't show keyboard immediately
                _focusNode.unfocus();
                Future.delayed(Duration(milliseconds: 100), () {
                  _focusNode.requestFocus();
                });
              },
              config: Config(
                emojiViewConfig: EmojiViewConfig(
                  columns: 7,
                  emojiSizeMax: 32,
                  replaceEmojiOnLimitExceed: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                skinToneConfig: SkinToneConfig(
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
                categoryViewConfig: CategoryViewConfig(
                  initCategory: Category.RECENT,
                  iconColor: Colors.grey,
                  iconColorSelected: Theme.of(context).colorScheme.primary,
                  backspaceColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    // Your existing input field code
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        // autofocus: true,
                        minLines: 1,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          prefixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.attach_file),
                                onPressed: () {
                                  // Handle attachment
                                },
                              ),
                            ],
                          ),
                          hintText: 'Type a message',
                          hintStyle: TextStyle(),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              style: BorderStyle.none,
                              width: 0.0,
                            ),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.emoji_emotions_outlined),
                                onPressed: _toggleEmojiPicker,
                              ),
                              IconButton(
                                icon: Icon(Icons.camera_alt),
                                onPressed: () {
                                  // Handle camera
                                },
                              ),
                            ],
                          ),
                        ),

                        onChanged: (text) => setState(() {}),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),

                    // Send Button
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child:
                          _messageController.text.isNotEmpty
                              ? Container(
                                margin: const EdgeInsets.only(left: 4),
                                decoration: BoxDecoration(
                                  shape:
                                      BoxShape.circle, // Circular send button
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: () {
                                    final text = _messageController.text.trim();
                                    if (text.isNotEmpty) {
                                      widget.onSendMessage(text, true);
                                      _messageController.clear();
                                      setState(() {});
                                    }
                                  },
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // This empty container ensures proper spacing when emoji picker is open
          SizedBox(
            height:
                _emojiPickerVisible
                    ? MediaQuery.of(context).size.height * 0.35
                    : 0,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
