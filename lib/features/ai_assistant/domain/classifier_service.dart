import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/core/constants/category_defaults.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/classifier_intent.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/classifier_result.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/parsed_transaction.dart';
import 'package:hermanos_ledgr/features/transactions/domain/transaction_model.dart';

/// Tier 1 Fast Decision Model & Entity Extractor (Task 9.1).
/// Pure Dart, < 15ms execution, zero RAM overhead, zero mock data.
class ClassifierService {
  /// Known keyword-to-category associations for Philippine spending patterns
  static final Map<String, List<String>> _categoryKeywords = {
    'food': [
      'starbucks', 'jollibee', 'mcdo', 'kfc', 'chowking', 'mang inasal',
      'coffee', 'lunch', 'dinner', 'breakfast', 'merienda', 'samgyup',
      'food', 'restaurant', 'cafe', 'milktea', 'grabfood', 'foodpanda',
      'kain', 'kape', 'ulam', 'snack', 'fastfood', 'burger', 'pizza',
    ],
    'transport': [
      'grab', 'angkas', 'joyride', 'mrt', 'lrt', 'jeep', 'bus', 'taxi',
      'gas', 'petron', 'shell', 'caltex', 'parking', 'toll', 'rfid',
      'easytrip', 'autosweep', 'pamasahe', 'commute', 'fare', 'diesel',
    ],
    'groceries': [
      'puregold', 'sm supermarket', 'robinsons', 'waltermart', 'grocery',
      'groceries', 'palengke', 'dali', 'o!save', 'supermarket', 'bigas',
    ],
    'utilities': [
      'meralco', 'electric', 'maynilad', 'manila water', 'water',
      'pldt', 'globe', 'smart', 'converge', 'wifi', 'internet', 'bill',
      'kuryente', 'tubig', 'utility', 'bills',
    ],
    'shopping': [
      'shopee', 'lazada', 'tiktok shop', 'uniqlo', 'zara', 'clothes',
      'shoes', 'mall', 'shopping', 'bili', 'damit', 'sapatos',
    ],
    'entertainment': [
      'netflix', 'spotify', 'disney', 'cinema', 'steam', 'movie', 'game',
      'concert', 'arcade', 'playstation', 'nintendo',
    ],
    'health': [
      'mercury drug', 'watsons', 'generika', 'pharmacy', 'medicine',
      'gamot', 'doctor', 'hospital', 'clinic', 'gym', 'fitness',
      'anytime fitness', 'checkup',
    ],
    'education': [
      'tuition', 'school', 'books', 'supplies', 'course', 'training',
    ],
    'salary': [
      'salary', 'sallary', 'sahod', 'sweldo', 'payroll', 'paycheck', 'cutoff',
    ],
    'freelance': [
      'client', 'freelance', 'project', 'gig', 'upwork', 'fiverr',
    ],
    'investments': [
      'dividend', 'stocks', 'crypto', 'interest', 'bonds', 'mp2',
    ],
  };

  /// Evaluates the input message using real registered accounts and categories.
  ClassifierResult classify({
    required String rawInput,
    required List<AccountModel> accounts,
    List<CategoryItem> categories = const [],
    DateTime? now,
  }) {
    final input = rawInput.trim();
    if (input.isEmpty) {
      return ClassifierResult(
        intent: ClassifierIntent.unclearOrGibberish,
        confidence: 0.0,
        conversationalReply: "Please enter a message or transaction to log.",
      );
    }

    final lower = input.toLowerCase();
    final effectiveNow = now ?? DateTime.now();

    // 1. Check for Greeting or Help
    if (_isGreetingOrHelp(lower)) {
      return ClassifierResult(
        intent: ClassifierIntent.greetingOrHelp,
        confidence: 1.0,
        conversationalReply:
            "Hello! I'm Hermano, your private on-device financial assistant.\n\n"
            "You can log transactions naturally, like:\n"
            "• 'Coffee 150 GCash'\n"
            "• 'Salary 50k BDO kahapon'\n"
            "• 'Meralco 3500 via Maya'\n\n"
            "Or ask me questions like 'How much did I spend this month?' or 'What is my total balance?'",
        suggestedPromptChips: const [
          'Coffee 150 GCash',
          'Salary 45k BDO',
          'Total balance?',
          'How much did I spend?',
        ],
      );
    }

    // 2. Check for Balance / Net Worth Inquiries
    if (_isBalanceInquiry(lower)) {
      return ClassifierResult(
        intent: ClassifierIntent.queryBalance,
        confidence: 0.95,
      );
    }

    // 3. Check for Spending / Expenses Inquiries
    if (_isSpendingInquiry(lower)) {
      return ClassifierResult(
        intent: ClassifierIntent.querySpending,
        confidence: 0.95,
      );
    }

    // 4. Check for Multi-item Complex Split (to delegate to Tier 2 LLM)
    if (_isComplexOrSplit(lower)) {
      return ClassifierResult(
        intent: ClassifierIntent.complexOrSplit,
        confidence: 0.70,
        conversationalReply:
            "This looks like a multi-item transaction or complex request. Delegating to Tier 2 LLM...",
      );
    }

    // 5. Check for Multi-Transaction Batch (sub-15ms direct batch extraction)
    final multiResult = _tryClassifyMultiple(
      rawInput: input,
      accounts: accounts,
      categories: categories,
      effectiveNow: effectiveNow,
    );
    if (multiResult != null) {
      return multiResult;
    }

    // 5. Extract Amount - STRICT CHECK (No default amounts!)
    final (extractedAmount, cleanedWithoutAmount) = _extractAmount(lower);
    if (extractedAmount == null || extractedAmount <= 0) {
      // If there is no valid amount and not a recognized command, it's gibberish or unclear!
      return ClassifierResult(
        intent: ClassifierIntent.unclearOrGibberish,
        confidence: 0.0,
        conversationalReply:
            "I couldn't detect an amount or known expense in your message.\n\n"
            "Try phrasing it with an amount, for example:\n"
            "• 'Lunch 220 GCash'\n"
            "• 'Gas 1.5k BDO'\n"
            "• 'Groceries 2500 Maya'",
        suggestedPromptChips: [
          'Coffee 140',
          'Groceries 1.5k',
          'Grab 350',
        ],
      );
    }

    // 6. Determine Transaction Type
    final txType = _determineTransactionType(lower);

    // 7. Resolve Category
    final allCategories = categories.isNotEmpty
        ? categories
        : CategoryDefaults.defaultCategories;
    final matchedCategory = _matchCategory(lower, txType, allCategories);

    // 8. Resolve Account(s)
    final (matchedAccount, matchedToAccount) = _matchAccount(lower, accounts, txType);

    // 9. Resolve Date
    final txDate = _resolveDate(lower, effectiveNow);

    // 10. Extract a clean Title
    final title = _generateTitle(input, cleanedWithoutAmount, matchedCategory, txType);

    // 11. Calculate Confidence & Missing Fields
    final missingFields = <String>[];
    double confidence = 0.50; // Base score for having a valid positive amount

    if (matchedCategory != null) {
      confidence += 0.25;
    } else {
      missingFields.add('category');
    }

    if (matchedAccount != null) {
      confidence += 0.20;
    } else {
      missingFields.add('account');
    }

    if (_hasDateCue(lower)) {
      confidence += 0.05;
    }

    // Default account if none specified
    final defaultAccount = matchedAccount ??
        (accounts.isNotEmpty
            ? accounts.first
            : AccountModel(
                id: 'acc_default',
                name: 'Main Wallet',
                type: AccountType.cash,
                balance: 0.0,
                icon: Icons.account_balance_wallet_rounded,
                color: const Color(0xFF00897B),
              ));

    // Default category if none recognized
    final defaultCat = matchedCategory ??
        (txType == TransactionType.income
            ? allCategories.firstWhere((c) => c.id == 'salary', orElse: () => allCategories.first)
            : allCategories.firstWhere((c) => c.id == 'food', orElse: () => allCategories.first));

    final parsedTx = ParsedTransaction(
      title: title,
      amount: extractedAmount,
      type: txType,
      categoryId: defaultCat.id,
      categoryName: defaultCat.name,
      categoryIcon: defaultCat.icon,
      categoryColor: defaultCat.color,
      accountId: defaultAccount.id,
      accountName: defaultAccount.name,
      toAccountId: matchedToAccount?.id,
      toAccountName: matchedToAccount?.name,
      date: txDate,
      confidence: confidence.clamp(0.0, 1.0),
      missingFields: missingFields,
    );

    return ClassifierResult(
      intent: ClassifierIntent.logTransaction,
      confidence: confidence.clamp(0.0, 1.0),
      transaction: parsedTx,
      conversationalReply: confidence >= 0.85
          ? "Parsed your transaction ready for confirmation:"
          : "I extracted this, but please verify the details:",
    );
  }

  /// Attempts to classify multiple transactions from a single sentence (Tier 1 sub-15ms parser).
  ClassifierResult? classifyMultiple({
    required String rawInput,
    required List<AccountModel> accounts,
    List<CategoryItem> categories = const [],
    DateTime? now,
  }) {
    return _tryClassifyMultiple(
      rawInput: rawInput,
      accounts: accounts,
      categories: categories,
      effectiveNow: now ?? DateTime.now(),
    );
  }

  // --- Private Helpers ---

  static ClassifierResult? _tryClassifyMultiple({
    required String rawInput,
    required List<AccountModel> accounts,
    required List<CategoryItem> categories,
    required DateTime effectiveNow,
  }) {
    // 1. Sanitize thousands separators (e.g., 1,000 -> 1000) so commas inside numbers
    // are not mistakenly treated as clause delimiters.
    final sanitized = rawInput.replaceAllMapped(
      RegExp(r'(\d+),(\d{3})'),
      (m) => '${m[1]}${m[2]}',
    );

    // 2. Split on sentence boundaries: commas, semicolons, newlines, and conjunctions
    final clauses = sanitized
        .split(RegExp(
            r'(?:\r?\n)+|;\s*|,\s*(?:and\s+|at\s+saka\s+|tapos\s+|plus\s+|&\s*)?|\s+(?:and|at\s+saka|tapos|plus|&)\s+',
            caseSensitive: false))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (clauses.length < 2) return null;

    final parsedTxs = <ParsedTransaction>[];
    double totalConfidence = 0.0;
    AccountModel? lastResolvedAccount;

    final allCategories = categories.isNotEmpty
        ? categories
        : CategoryDefaults.defaultCategories;

    for (final clause in clauses) {
      final clauseLower = clause.toLowerCase();
      final (extractedAmount, cleanedWithoutAmount) = _extractAmount(clauseLower);
      if (extractedAmount == null || extractedAmount <= 0) continue;

      final txType = _determineTransactionType(clauseLower);
      final matchedCategory = _matchCategory(clauseLower, txType, allCategories);
      final (matchedAccount, matchedToAccount) = _matchAccount(clauseLower, accounts, txType);

      if (matchedAccount != null) {
        lastResolvedAccount = matchedAccount;
      }

      final defaultAccount = matchedAccount ??
          lastResolvedAccount ??
          (accounts.isNotEmpty
              ? accounts.first
              : AccountModel(
                  id: 'acc_default',
                  name: 'Main Wallet',
                  type: AccountType.cash,
                  balance: 0.0,
                  icon: Icons.account_balance_wallet_rounded,
                  color: const Color(0xFF00897B),
                ));

      final defaultCat = matchedCategory ??
          (txType == TransactionType.income
              ? allCategories.firstWhere((c) => c.id == 'salary', orElse: () => allCategories.first)
              : allCategories.firstWhere((c) => c.id == 'food', orElse: () => allCategories.first));

      final title = _generateTitle(clause, cleanedWithoutAmount, matchedCategory, txType);
      final txDate = _resolveDate(clauseLower, effectiveNow);

      double clauseConfidence = 0.50;
      if (matchedCategory != null) clauseConfidence += 0.25;
      if (matchedAccount != null) clauseConfidence += 0.20;
      if (_hasDateCue(clauseLower)) clauseConfidence += 0.05;

      parsedTxs.add(ParsedTransaction(
        title: title,
        amount: extractedAmount,
        type: txType,
        categoryId: defaultCat.id,
        categoryName: defaultCat.name,
        categoryIcon: defaultCat.icon,
        categoryColor: defaultCat.color,
        accountId: defaultAccount.id,
        accountName: defaultAccount.name,
        toAccountId: matchedToAccount?.id,
        toAccountName: matchedToAccount?.name,
        date: txDate,
        confidence: clauseConfidence.clamp(0.0, 1.0),
      ));

      totalConfidence += clauseConfidence;
    }

    if (parsedTxs.length >= 2) {
      final avgConfidence = (totalConfidence / parsedTxs.length).clamp(0.0, 1.0);
      return ClassifierResult(
        intent: ClassifierIntent.logTransaction,
        confidence: avgConfidence,
        transactions: parsedTxs,
        conversationalReply:
            "Parsed ${parsedTxs.length} transactions ready for confirmation:",
      );
    }

    return null;
  }

  static bool _isGreetingOrHelp(String lower) {
    final greetings = [
      'hi', 'hello', 'hey', 'kumusta', 'kamusta', 'help', 'tulong',
      'who are you', 'sino ka', 'ano kaya mo', 'what can you do', 'good morning',
      'good afternoon', 'good evening',
    ];
    return greetings.contains(lower) ||
        lower == 'hi hermano' ||
        lower == 'hello hermano';
  }

  static bool _isBalanceInquiry(String lower) {
    return lower.contains('balance') ||
        lower.contains('net worth') ||
        lower.contains('how much do i have') ||
        lower.contains('magkano pera ko') ||
        lower.contains('pera ko') ||
        lower.contains('total money') ||
        lower.contains('total cash');
  }

  static bool _isSpendingInquiry(String lower) {
    return lower.contains('how much') &&
            (lower.contains('spent') ||
                lower.contains('spend') ||
                lower.contains('expenses') ||
                lower.contains('nagastos') ||
                lower.contains('gastos')) ||
        lower.contains('total spent') ||
        lower.contains('total expense') ||
        lower.contains('monthly spending') ||
        lower.contains('summary of spending');
  }

  static bool _isComplexOrSplit(String lower) {
    // Detect expressions like "150 on coffee and 300 on groceries"
    final hasMultipleAmounts = RegExp(r'\d+(\.\d+)?[kK]?').allMatches(lower).length >= 2;
    final hasConjunction = lower.contains(' and ') ||
        lower.contains(' tapos ') ||
        lower.contains(' at saka ') ||
        lower.contains(' plus ') ||
        lower.contains(' split ');
    return hasMultipleAmounts && hasConjunction;
  }

  /// Extracts amount including `50k`, `1.5k`, `₱1,250.50`, `P300`, etc.
  static (double?, String) _extractAmount(String lower) {
    // Regex matches currency prefixes and number with optional k multiplier
    // Examples: "₱1,500", "p500", "50k", "1.5k", "250.00", "300"
    final pattern = RegExp(
      r'(?:[₱pP]|(?:php|PHP)\s*)?\s*(\d{1,3}(?:,\d{3})*(?:\.\d+)?|\d+(?:\.\d+)?)\s*([kK])?',
    );

    final match = pattern.firstMatch(lower);
    if (match == null) return (null, lower);

    final rawNumStr = match.group(1)?.replaceAll(',', '');
    if (rawNumStr == null) return (null, lower);

    double? parsed = double.tryParse(rawNumStr);
    if (parsed == null || parsed <= 0) return (null, lower);

    // Apply 'k' multiplier (e.g. 50k -> 50,000)
    final isK = match.group(2) != null || lower.contains('${rawNumStr}k') || lower.contains('$rawNumStr k');
    if (isK && parsed < 1000) {
      parsed *= 1000.0;
    }

    final cleaned = lower.replaceFirst(match.group(0)!, '').trim();
    return (parsed, cleaned);
  }

  static TransactionType _determineTransactionType(String lower) {
    if (lower.contains('transfer') ||
        lower.contains('lipat') ||
        lower.contains('move to') ||
        lower.contains('padala sa')) {
      return TransactionType.transfer;
    }

    if (lower.contains('salary') ||
        lower.contains('sallary') ||
        lower.contains('sahod') ||
        lower.contains('sweldo') ||
        lower.contains('income') ||
        lower.contains('client') ||
        lower.contains('bonus') ||
        lower.contains('payout') ||
        lower.contains('received') ||
        lower.contains('tanggap') ||
        lower.contains('dividend') ||
        lower.contains('interest')) {
      return TransactionType.income;
    }

    return TransactionType.expense;
  }

  static CategoryItem? _matchCategory(
    String lower,
    TransactionType type,
    List<CategoryItem> categories,
  ) {
    // 1. Direct keyword mapping
    for (final entry in _categoryKeywords.entries) {
      final catId = entry.key;
      for (final kw in entry.value) {
        if (lower.contains(kw)) {
          final found = categories.cast<CategoryItem?>().firstWhere(
                (c) => c?.id == catId,
                orElse: () => null,
              );
          if (found != null) return found;
        }
      }
    }

    // 2. Direct category name match
    for (final cat in categories) {
      if (lower.contains(cat.name.toLowerCase()) || lower.contains(cat.id.toLowerCase())) {
        return cat;
      }
    }

    // Default based on type
    if (type == TransactionType.income) {
      return categories.cast<CategoryItem?>().firstWhere(
            (c) => c?.id == 'salary',
            orElse: () => null,
          );
    }

    return null;
  }

  static (AccountModel?, AccountModel?) _matchAccount(
    String lower,
    List<AccountModel> accounts,
    TransactionType type,
  ) {
    AccountModel? source;
    AccountModel? destination;

    for (final acc in accounts) {
      final nameLower = acc.name.toLowerCase();
      final instLower = acc.institution?.toLowerCase() ?? '';

      if (lower.contains(nameLower) ||
          (instLower.isNotEmpty && lower.contains(instLower))) {
        if (source == null) {
          source = acc;
        } else if (type == TransactionType.transfer && destination == null) {
          destination = acc;
        }
      }
    }

    return (source, destination);
  }

  static bool _hasDateCue(String lower) {
    return lower.contains('kahapon') ||
        lower.contains('yesterday') ||
        lower.contains('kanina') ||
        lower.contains('today') ||
        lower.contains('ngayon');
  }

  static DateTime _resolveDate(String lower, DateTime now) {
    if (lower.contains('kahapon') || lower.contains('yesterday')) {
      return now.subtract(const Duration(days: 1));
    }
    // Defaults to today
    return now;
  }

  static String _generateTitle(
    String originalInput,
    String cleaned,
    CategoryItem? matchedCategory,
    TransactionType type,
  ) {
    final lower = originalInput.toLowerCase();

    // Priority to specific merchant names
    final merchants = [
      'Starbucks', 'Jollibee', 'McDonalds', 'McDo', 'KFC', 'Chowking',
      'Grab', 'Angkas', 'Joyride', 'Petron', 'Shell', 'Caltex',
      'Puregold', 'SM Supermarket', 'Robinsons', 'Waltermart',
      'Meralco', 'Maynilad', 'PLDT', 'Globe', 'Smart', 'Converge',
      'Netflix', 'Spotify', 'Shopee', 'Lazada', 'Uniqlo',
      'Mercury Drug', 'Watsons', 'Dali',
    ];

    for (final m in merchants) {
      if (lower.contains(m.toLowerCase())) {
        return m;
      }
    }

    // Otherwise clean up words like "via", "to", "sa", "kahapon"
    String words = cleaned
        .replaceAll(RegExp(r'\b(via|from|to|sa|kay|kahapon|yesterday|kanina|today|paid|spent|bought|bili)\b'), '')
        .trim();

    if (words.isNotEmpty) {
      final title = words[0].toUpperCase() + words.substring(1);
      return title.length > 28 ? title.substring(0, 28) : title;
    }

    if (matchedCategory != null) {
      return matchedCategory.name;
    }

    return type == TransactionType.income ? 'Income' : 'Expense';
  }
}
