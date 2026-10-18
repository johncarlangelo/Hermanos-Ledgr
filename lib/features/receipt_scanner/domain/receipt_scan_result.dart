class ReceiptScanResult {
  final double? amount;
  final String? merchant;
  final DateTime? date;
  final String? categoryId;
  final String? categoryName;
  final double confidence;
  final String? imagePath;
  final String rawText;
  final bool usedLlmFallback;
  final String? warningNote;

  const ReceiptScanResult({
    this.amount,
    this.merchant,
    this.date,
    this.categoryId,
    this.categoryName,
    this.confidence = 0.0,
    this.imagePath,
    this.rawText = '',
    this.usedLlmFallback = false,
    this.warningNote,
  });

  ReceiptScanResult copyWith({
    double? amount,
    String? merchant,
    DateTime? date,
    String? categoryId,
    String? categoryName,
    double? confidence,
    String? imagePath,
    String? rawText,
    bool? usedLlmFallback,
    String? warningNote,
  }) {
    return ReceiptScanResult(
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      confidence: confidence ?? this.confidence,
      imagePath: imagePath ?? this.imagePath,
      rawText: rawText ?? this.rawText,
      usedLlmFallback: usedLlmFallback ?? this.usedLlmFallback,
      warningNote: warningNote ?? this.warningNote,
    );
  }
}
