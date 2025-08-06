// import 'dart:developer' as devTools;

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mental_health_support/models/gemini_config.dart';
import 'package:mental_health_support/models/message.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: GeminiConfig.model,
      apiKey: GeminiConfig.apiKey,
      generationConfig: GenerationConfig(
        temperature: GeminiConfig.generationConfig['temperature'],
        topK: GeminiConfig.generationConfig['topK'],
        topP: GeminiConfig.generationConfig['topP'],
        maxOutputTokens: GeminiConfig.generationConfig['maxOutputTokens'],
      ),
      systemInstruction: Content('system', [
        TextPart(GeminiConfig.systemInstructions),
      ]),
      safetySettings: GeminiConfig.parseSafetySettings(),
    );
  }

  Future<String> getAIResponse(String userInput, List<Message> history) async {
    try {
      final prompt = _buildPrompt(userInput, history);
      final response = await _model.generateContent([Content.text(prompt)]);
      // for (final candidate in response.candidates) {
      //   candidate.log();
      // }
      return response.text ?? "I'm sorry, I couldn't process that request.";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  String _buildPrompt(String userInput, List<Message> history) {
    return '''    
    [CONVERSATION HISTORY]
    ${_formatHistory(history)}
    
    [NEW MESSAGE]
    User: $userInput
    Assistant: 
    ''';
  }

  String _formatHistory(List<Message> history) => history
      .map((m) => "${m.isUser ? 'User' : 'Assistant'}: ${m.content}")
      .join('\n');
}


