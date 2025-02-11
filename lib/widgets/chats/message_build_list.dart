import 'package:flutter/material.dart';
import 'package:linkify/linkify.dart';
import 'package:mental_health_support/models/message.dart';
import 'package:mental_health_support/widgets/chats/message_bubble.dart';

class MessageBuildList extends StatelessWidget {
  final List<Message> messages;
  final ScrollController scrollController;

  const MessageBuildList({
    required this.messages,
    required this.scrollController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Sort messages by timestamp before displaying
    final sortedMessages = List<Message>.from(messages)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (sortedMessages.isEmpty) {
      return const Center(child: Text('Start the conversation!'));
    }

    return ListView.builder(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final DateTime createdAt = messages[index].createdAt;
        final isUser = message.isUser;
        final isTemp = messages[index].id.startsWith('temp_');
        final textColor =
            isUser
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onPrimary;
        final linkColor =
            isUser ? Colors.white.withValues(alpha: 0.8) : Colors.blue;
        final processedText = _autoLinkify(message.content);

        return MessageBubble(
          createdAt: createdAt,
          message: processedText,
          isTemp: isTemp,
          isUser: isUser,
          textColor: textColor,
          linkColor: linkColor,
        );
      },
    );
  }

  String _autoLinkify(String text) {
    final linkified =
        linkify(text, options: const LinkifyOptions(humanize: false)).map((
          element,
        ) {
          if (element is UrlElement) {
            return '[${element.text}](${element.url})';
          }
          return element.text;
        }).join();

    return linkified;
  }
}
