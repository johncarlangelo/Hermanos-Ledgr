/// Interface for Tier 2 on-device LLM inference wrapper (Task 9.5).
abstract class LlmService {
  /// Loads the GGUF model from the specified local file path.
  Future<bool> loadModel(String modelPath);

  /// Unloads the model from memory to free RAM.
  Future<void> unloadModel();

  /// Whether the model is currently loaded in memory and ready for inference.
  bool get isLoaded;

  /// Generates a structured JSON string matching the system prompt template.
  Future<String?> generateStructuredJson({
    required String userPrompt,
    required List<String> categories,
    required List<String> accounts,
    required String todayDate,
  });

  /// Generates a natural language spending summary for the user.
  Future<String?> generateSpendingSummary({
    required String promptContext,
  });
}
