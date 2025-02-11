import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final Color textColor;
  final Color linkColor;
  final DateTime createdAt;
  final bool isUser;
  final bool isTemp;

  const MessageBubble({
    super.key,
    required this.createdAt,
    required this.message,
    required this.isTemp,
    required this.isUser,
    required this.textColor,
    required this.linkColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isUser
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSecondaryContainer,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
              bottomRight: isUser ? Radius.zero : const Radius.circular(12),
            ),
          ),
          child: MarkdownBody(
            data: message,
            styleSheet: MarkdownStyleSheet(
              a: TextStyle(
                color: linkColor,
                decoration: TextDecoration.underline,
              ),
              p: TextStyle(color: textColor, fontSize: 16, height: 1.4),
              strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              em: TextStyle(color: textColor, fontStyle: FontStyle.italic),
              code: TextStyle(
                backgroundColor: Colors.grey[200],
                fontFamily: 'RobotoMono',
                color: Colors.black,
                fontSize: 14,
              ),
              blockquote: TextStyle(
                color: textColor,
                fontStyle: FontStyle.italic,
              ),
              listIndent: 20.0,
              blockSpacing: 8.0,
            ),
            selectable: true,
            softLineBreak: true,
            shrinkWrap: true,
            onTapLink: (text, href, title) async {
              if (href != null) {
                final uri = Uri.tryParse(href);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
          ),
        ),
      ),
      subtitle: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            DateFormat('hh:mm a').format(createdAt),
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}
