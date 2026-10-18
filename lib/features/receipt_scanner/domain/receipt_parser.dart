import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/features/receipt_scanner/domain/receipt_scan_result.dart';

/// Pure Dart Tier 1 Receipt Parser (Task 10.2).
/// Fast (< 5ms), deterministic, zero external model dependencies.
class ReceiptParser {
  static const String accuracyNotice =
      'Note: OCR text detection may be inaccurate if the image is blurry, poorly lit, or the receipt is crumpled. Please review the details below before adding to your ledger.';

  /// Philippine and international merchant to category map
  static final Map<String, String> _merchantCategoryMap = {
    // Food & Dining
    'jollibee': 'food',
    'mcdo': 'food',
    'mcdonald': 'food',
    'kfc': 'food',
    'chowking': 'food',
    'mang inasal': 'food',
    'greenwich': 'food',
    'starbucks': 'food',
    'coffee bean': 'food',
    'cbtl': 'food',
    'dunkin': 'food',
    'tim hortons': 'food',
    'shakey': 'food',
    'pizza hut': 'food',
    'bonchon': 'food',
    'army navy': 'food',
    'subway': 'food',
    'restaurant': 'food',
    'cafe': 'food',
    'bakery': 'food',
    'bistro': 'food',
    'grill': 'food',
    'samgyup': 'food',
    'inasal': 'food',

    // Groceries
    'sm supermarket': 'groceries',
    'sm hypermarket': 'groceries',
    'savemore': 'groceries',
    'puregold': 'groceries',
    'robinsons supermarket': 'groceries',
    'robinsons easymart': 'groceries',
    'waltermart': 'groceries',
    'dali': 'groceries',
    'o!save': 'groceries',
    'landers': 'groceries',
    's&r': 'groceries',
    'snr': 'groceries',
    'supermarket': 'groceries',
    'grocery': 'groceries',
    'mart': 'groceries',
    '7-eleven': 'groceries',
    '7 eleven': 'groceries',
    'ministop': 'groceries',
    'uncle john': 'groceries',
    'lawson': 'groceries',
    'alfa mart': 'groceries',
    'alfamart': 'groceries',

    // Transport
    'petron': 'transport',
    'shell': 'transport',
    'caltex': 'transport',
    'seaoil': 'transport',
    'cleanfuel': 'transport',
    'unioil': 'transport',
    'phoenix': 'transport',
    'total energies': 'transport',
    'parking': 'transport',
    'toll': 'transport',
    'easytrip': 'transport',
    'autosweep': 'transport',

    // Health & Personal Care
    'mercury drug': 'health',
    'watsons': 'health',
    'generika': 'health',
    'southstar': 'health',
    'rose pharmacy': 'health',
    'the generics pharmacy': 'health',
    'tgp': 'health',
    'pharmacy': 'health',
    'drugstore': 'health',
    'clinic': 'health',
    'hospital': 'health',
    'lab': 'health',

    // Utilities
    'meralco': 'utilities',
    'maynilad': 'utilities',
    'manila water': 'utilities',
    'pldt': 'utilities',
    'globe': 'utilities',
    'smart': 'utilities',
    'converge': 'utilities',

    // Shopping
    'uniqlo': 'shopping',
    'zara': 'shopping',
    'h&m': 'shopping',
    'sm store': 'shopping',
    'department store': 'shopping',
    'ace hardware': 'shopping',
    'handyman': 'shopping',
    'true value': 'shopping',
    'miniso': 'shopping',
    'daiso': 'shopping',
    'national book store': 'shopping',
    'nbs': 'shopping',
  };

  /// Parses raw OCR text into structured [ReceiptScanResult].
  static ReceiptScanResult parse({
    required String rawText,
    String? imagePath,
  }) {
    if (rawText.trim().isEmpty) {
      return ReceiptScanResult(
        rawText: rawText,
        imagePath: imagePath,
        confidence: 0.0,
        warningNote: accuracyNotice,
      );
    }

    final rawLines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (rawLines.isEmpty) {
      return ReceiptScanResult(
        rawText: rawText,
        imagePath: imagePath,
        confidence: 0.0,
        warningNote: accuracyNotice,
      );
    }

    // 1. Extract Amount
    final (extractedAmount, amountConfidence) = _extractTotalAmount(rawLines);

    // 2. Extract Merchant Name
    final (merchantName, merchantConfidence) = _extractMerchant(rawLines);

    // 3. Extract Date
    final (extractedDate, dateConfidence) = _extractDate(rawLines);

    // 4. Resolve Category from Merchant / Content
    final (catId, catName) = _resolveCategory(merchantName, rawLines);

    // 5. Calculate Aggregate Confidence
    double totalConfidence = (amountConfidence * 0.55) +
        (merchantConfidence * 0.30) +
        (dateConfidence * 0.15);
    if (totalConfidence > 1.0) totalConfidence = 1.0;

    return ReceiptScanResult(
      amount: extractedAmount,
      merchant: merchantName,
      date: extractedDate ?? DateTime.now(),
      categoryId: catId,
      categoryName: catName,
      confidence: double.parse(totalConfidence.toStringAsFixed(2)),
      imagePath: imagePath,
      rawText: rawText,
      warningNote: accuracyNotice,
    );
  }

  /// Scans lines for the grand total amount.
  static (double?, double) _extractTotalAmount(List<String> lines) {
    double? detectedAmount;
    double confidence = 0.0;

    // Scan backwards from bottom to top since totals appear at the end
    final amountRegex = RegExp(
      r'(?:₱|P|PHP)?\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{2})|[0-9]+(?:\.[0-9]{2}))',
      caseSensitive: false,
    );

    // Exclude noise lines like cash tendered, sukli/change, VAT breakdown
    final excludePattern = RegExp(
      r'\b(cash|tendered|change|sukli|vat|tax|discount|points|subtotal|sub-total|items?|qty)\b',
      caseSensitive: false,
    );

    // Strong keywords for final total
    final totalPattern = RegExp(
      r'\b(total|grand\s*total|amount\s*due|net\s*due|balance\s*due|total\s*amount|total\s*php)\b',
      caseSensitive: false,
    );

    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i];

      // If line contains total keyword
      if (totalPattern.hasMatch(line) && !excludePattern.hasMatch(line)) {
        final match = amountRegex.firstMatch(line);
        if (match != null) {
          final cleanNum = match.group(1)!.replaceAll(',', '');
          final val = double.tryParse(cleanNum);
          if (val != null && val > 0) {
            return (val, 0.95);
          }
        }

        // Sometimes the number is on the adjacent line below or above
        if (i + 1 < lines.length) {
          final nextMatch = amountRegex.firstMatch(lines[i + 1]);
          if (nextMatch != null) {
            final cleanNum = nextMatch.group(1)!.replaceAll(',', '');
            final val = double.tryParse(cleanNum);
            if (val != null && val > 0) {
              return (val, 0.90);
            }
          }
        }
      }
    }

    // Fallback: search for any line with currency symbol or high decimal number in lower half
    final halfIndex = (lines.length / 2).floor();
    for (int i = lines.length - 1; i >= halfIndex; i--) {
      final line = lines[i];
      if (excludePattern.hasMatch(line)) continue;

      final match = amountRegex.firstMatch(line);
      if (match != null) {
        final cleanNum = match.group(1)!.replaceAll(',', '');
        final val = double.tryParse(cleanNum);
        if (val != null && val > 0) {
          detectedAmount = val;
          confidence = 0.60;
          break;
        }
      }
    }

    return (detectedAmount, confidence);
  }

  /// Extracts the merchant name from the header lines.
  static (String?, double) _extractMerchant(List<String> lines) {
    final noisePattern = RegExp(
      r'\b(welcome|official\s*receipt|sales\s*invoice|tin|vat\s*reg|tel|phone|contact|date|time|cashier|pos|or#|si#|terminal|store\s*#|branch)\b',
      caseSensitive: false,
    );

    // Examine first 5 lines for merchant name
    final searchLimit = lines.length > 5 ? 5 : lines.length;
    for (int i = 0; i < searchLimit; i++) {
      final line = lines[i].trim();
      if (line.length < 3) continue;
      if (noisePattern.hasMatch(line)) continue;
      if (RegExp(r'^[0-9\W]+$').hasMatch(line)) continue; // numbers or symbols only

      // Clean up punctuation noise
      final clean = line
          .replaceAll(RegExp(r'[^\w\s\-\&\.\,]'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (clean.length >= 3) {
        return (clean, 0.85);
      }
    }

    return (null, 0.0);
  }

  /// Extracts transaction date from lines.
  static (DateTime?, double) _extractDate(List<String> lines) {
    // MM/DD/YYYY or DD/MM/YYYY or YYYY-MM-DD
    final numericDateRegex = RegExp(
      r'\b(\d{1,4})[/-](\d{1,2})[/-](\d{2,4})\b',
    );

    // Month Name DD, YYYY (e.g. Aug 15, 2026 or 15-Aug-2026)
    final textDateRegex = RegExp(
      r'\b(?:(\d{1,2})[-\s])?(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\.?[-\s]+(\d{1,2})(?:,?\s*(\d{2,4}))?\b',
      caseSensitive: false,
    );

    for (final line in lines) {
      final numMatch = numericDateRegex.firstMatch(line);
      if (numMatch != null) {
        final p1 = int.tryParse(numMatch.group(1)!);
        final p2 = int.tryParse(numMatch.group(2)!);
        final p3 = int.tryParse(numMatch.group(3)!);

        if (p1 != null && p2 != null && p3 != null) {
          DateTime? date;
          // Case 1: YYYY-MM-DD
          if (p1 > 1000 && p2 <= 12 && p3 <= 31) {
            date = DateTime(p1, p2, p3);
          }
          // Case 2: MM/DD/YYYY
          else if (p3 > 1000 && p1 <= 12 && p2 <= 31) {
            date = DateTime(p3, p1, p2);
          }
          // Case 3: DD/MM/YYYY
          else if (p3 > 1000 && p2 <= 12 && p1 <= 31) {
            date = DateTime(p3, p2, p1);
          }

          if (date != null) {
            return (date, 0.90);
          }
        }
      }

      final textMatch = textDateRegex.firstMatch(line);
      if (textMatch != null) {
        final monthStr = textMatch.group(2)!.toLowerCase();
        final day = int.tryParse(textMatch.group(1) ?? textMatch.group(3) ?? '');
        final year = int.tryParse(textMatch.group(4) ?? '') ?? DateTime.now().year;

        const months = {
          'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
          'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
        };

        final month = months[monthStr];
        if (month != null && day != null && day <= 31) {
          return (DateTime(year, month, day), 0.95);
        }
      }
    }

    return (null, 0.0);
  }

  /// Maps merchant or content keywords to a category ID and display name.
  static (String, String) _resolveCategory(String? merchant, List<String> lines) {
    final merchantLower = merchant?.toLowerCase() ?? '';
    final searchTarget = '$merchantLower ${lines.take(6).join(' ')}'.toLowerCase();

    // Sort keywords so more specific/longer phrases match first
    final sortedEntries = _merchantCategoryMap.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

    // 1. Direct merchant matching
    if (merchantLower.isNotEmpty) {
      for (final entry in sortedEntries) {
        if (merchantLower.contains(entry.key)) {
          final catId = entry.value;
          final matchedItem = CategoryDefaults.defaultCategories.firstWhere(
            (c) => c.id == catId,
            orElse: () => CategoryDefaults.defaultCategories.first,
          );
          return (matchedItem.id, matchedItem.name);
        }
      }
    }

    // 2. Search target lines matching
    for (final entry in sortedEntries) {
      if (searchTarget.contains(entry.key)) {
        final catId = entry.value;
        final matchedItem = CategoryDefaults.defaultCategories.firstWhere(
          (c) => c.id == catId,
          orElse: () => CategoryDefaults.defaultCategories.first,
        );
        return (matchedItem.id, matchedItem.name);
      }
    }

    // Default to Food & Dining (the most common receipt type) or Shopping
    final defaultCat = CategoryDefaults.defaultCategories.first;
    return (defaultCat.id, defaultCat.name);
  }
}
