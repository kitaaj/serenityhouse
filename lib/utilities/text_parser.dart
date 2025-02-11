import 'package:flutter/material.dart';

List<TextSpan> parseFormattedText(String text) {
  final List<TextSpan> spans = [];
  final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
  final RegExp italicRegex = RegExp(r'_(.*?)_');
  final RegExp codeRegex = RegExp(r'`(.*?)`');

  String remainingText = text;

  while (remainingText.isNotEmpty) {
    Match? firstMatch;
    TextStyle? style;

    // Check for bold first
    firstMatch = boldRegex.firstMatch(remainingText);
    if (firstMatch != null) {
      style = const TextStyle(fontWeight: FontWeight.bold);
    } else {
      // Check for italic
      firstMatch = italicRegex.firstMatch(remainingText);
      if (firstMatch != null) {
        style = const TextStyle(fontStyle: FontStyle.italic);
      } else {
        // Check for code
        firstMatch = codeRegex.firstMatch(remainingText);
        if (firstMatch != null) {
          style = TextStyle(
            backgroundColor: Colors.grey[200],
            fontFamily: 'monospace',
          );
        }
      }
    }

    if (firstMatch != null && style != null) {
      // Add text before the match
      if (firstMatch.start > 0) {
        spans.add(TextSpan(text: remainingText.substring(0, firstMatch.start)));
      }

      // Add styled text
      spans.add(TextSpan(text: firstMatch.group(1), style: style));

      // Update remaining text
      remainingText = remainingText.substring(firstMatch.end);
    } else {
      // Add remaining text
      spans.add(TextSpan(text: remainingText));
      break;
    }
  }

  return spans;
}
