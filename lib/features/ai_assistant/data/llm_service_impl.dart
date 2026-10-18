import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_llama/flutter_llama.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/llm_service.dart';

/// Concrete implementation of [LlmService] running on-chip via flutter_llama (Task 9.5).
class LlmServiceImpl implements LlmService {
  final FlutterLlama _llama = FlutterLlama.instance;
  bool _isLoaded = false;
  String? _loadedModelPath;

  @override
  bool get isLoaded => _isLoaded;

  @override
  Future<bool> loadModel(String modelPath) async {
    try {
      if (_isLoaded && _loadedModelPath == modelPath) {
        return true;
      }
      final config = LlamaConfig(
        modelPath: modelPath,
        nThreads: 4,
        nGpuLayers: -1,
        contextSize: 2048,
        batchSize: 512,
        useGpu: true,
      );
      _isLoaded = await _llama.loadModel(config);
      if (_isLoaded) {
        _loadedModelPath = modelPath;
      }
      return _isLoaded;
    } catch (e) {
      debugPrint('Error loading GGUF model: $e');
      _isLoaded = false;
      return false;
    }
  }

  @override
  Future<void> unloadModel() async {
    try {
      _isLoaded = false;
      _loadedModelPath = null;
    } catch (_) {}
  }

  @override
  Future<String?> generateStructuredJson({
    required String userPrompt,
    required List<String> categories,
    required List<String> accounts,
    required String todayDate,
  }) async {
    if (!_isLoaded) return null;

    final systemPrompt = '''
You are Hermano, an on-device personal financial assistant.
Extract the financial transaction from the user's message.
Available Categories: [${categories.join(', ')}]
Available Accounts: [${accounts.join(', ')}]
Today's Date: $todayDate

Respond ONLY with valid JSON and NO markdown or explanations:
{
  "type": "expense",
  "amount": 250.0,
  "category": "Food & Dining",
  "account": "GCash Wallet",
  "to_account": null,
  "date": "$todayDate",
  "title": "Starbucks Coffee",
  "note": "caramel macchiato"
}

If you cannot parse the input as a transaction, respond with:
{"error": "unclear"}
''';

    final fullPrompt = '$systemPrompt\n\nUser: $userPrompt\nAssistant:';

    try {
      final params = GenerationParams(
        prompt: fullPrompt,
        temperature: 0.1,
        maxTokens: 256,
      );

      final response = await _llama.generate(params);
      return response.text.trim();
    } catch (e) {
      debugPrint('LLM generation error: $e');
      return null;
    }
  }

  @override
  Future<String?> generateSpendingSummary({
    required String promptContext,
  }) async {
    if (!_isLoaded) return null;

    final prompt = '''
You are Hermano, a calm personal financial assistant.
Summarize the following spending data in 2-3 friendly, helpful sentences highlighting where the money went and one actionable tip:

$promptContext

Assistant:
''';

    try {
      final params = GenerationParams(
        prompt: prompt,
        temperature: 0.7,
        maxTokens: 300,
      );

      final response = await _llama.generate(params);
      return response.text.trim();
    } catch (e) {
      debugPrint('LLM summary error: $e');
      return null;
    }
  }
}
