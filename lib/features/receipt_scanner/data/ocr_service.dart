import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/llm_service.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/nlp_parser.dart';
import 'package:hermanos_ledgr/features/receipt_scanner/domain/receipt_parser.dart';
import 'package:hermanos_ledgr/features/receipt_scanner/domain/receipt_scan_result.dart';

/// Service interfacing with on-device Google ML Kit OCR and hybrid fallback (Task 10.2).
class OcrService {
  TextRecognizer? _recognizer;

  TextRecognizer get _textRecognizer {
    _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _recognizer!;
  }

  /// Processes an image from [imagePath], extracts text using ML Kit,
  /// and resolves receipt data via Tier 1 heuristic parsing with optional Tier 2 LLM fallback.
  Future<ReceiptScanResult> processReceiptImage({
    required String imagePath,
    LlmService? optionalLlmService,
    List<String> availableCategories = const [],
    List<String> availableAccounts = const [],
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return const ReceiptScanResult(
          confidence: 0.0,
          warningNote: 'Receipt image file not found.',
        );
      }

      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final rawText = recognizedText.text;

      // 1. Tier 1 Fast Regex / Heuristic Parse (< 5ms)
      var result = ReceiptParser.parse(
        rawText: rawText,
        imagePath: imagePath,
      );

      // 2. Optional Tier 2 LLM Fallback (Task 10.2 Cascaded Hybrid)
      // Only triggered if Tier 1 confidence is low (< 0.70) AND an active LLM is available
      if (result.confidence < 0.70 &&
          optionalLlmService != null &&
          optionalLlmService.isLoaded) {
        try {
          final nowStr = DateTime.now().toIso8601String().split('T').first;
          final categories = availableCategories.isNotEmpty
              ? availableCategories
              : CategoryDefaults.defaultCategories.map((c) => c.name).toList();

          final llmResponse = await optionalLlmService.generateStructuredJson(
            userPrompt: 'Extract transaction from this receipt text:\n$rawText',
            categories: categories,
            accounts: availableAccounts,
            todayDate: nowStr,
          );

          if (llmResponse != null) {
            final parsedTx = NlpParser.parseLlmJson(
              rawLlmOutput: llmResponse,
              accounts: [],
              categories: CategoryDefaults.defaultCategories,
            );

            if (parsedTx != null && parsedTx.amount > 0) {
              result = result.copyWith(
                amount: parsedTx.amount,
                merchant: parsedTx.title.isNotEmpty ? parsedTx.title : result.merchant,
                categoryId: parsedTx.categoryId,
                confidence: 0.85,
                usedLlmFallback: true,
              );
            }
          }
        } catch (e) {
          debugPrint('Tier 2 OCR LLM fallback error: $e');
        }
      }

      return result;
    } catch (e) {
      debugPrint('ML Kit OCR error: $e');
      return ReceiptScanResult(
        imagePath: imagePath,
        confidence: 0.0,
        warningNote: 'Failed to read receipt: $e',
      );
    }
  }

  /// Disposes ML Kit text recognizer resources.
  void dispose() {
    _recognizer?.close();
    _recognizer = null;
  }
}
