import 'package:flutter/material.dart';

enum CardNetwork {
  mastercard,
  visa,
  none,
}

enum CardBrand {
  mariBank,
  gcash,
  maya,
  bdo,
  bpi,
  unionBank,
  goTyme,
  wise,
  paypal,
  venmo,
  cash,
  custom;

  String get displayName {
    switch (this) {
      case CardBrand.mariBank:
        return 'MariBank';
      case CardBrand.gcash:
        return 'GCash';
      case CardBrand.maya:
        return 'Maya';
      case CardBrand.bdo:
        return 'BDO Unibank';
      case CardBrand.bpi:
        return 'BPI';
      case CardBrand.unionBank:
        return 'UnionBank';
      case CardBrand.goTyme:
        return 'GoTyme Bank';
      case CardBrand.wise:
        return 'Wise';
      case CardBrand.paypal:
        return 'PayPal';
      case CardBrand.venmo:
        return 'Venmo';
      case CardBrand.cash:
        return 'Cash';
      case CardBrand.custom:
        return 'Custom';
    }
  }

  LinearGradient get gradient {
    switch (this) {
      case CardBrand.mariBank:
        // Vibrant Sea / MariBank Orange
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6D00),
            Color(0xFFFF5200),
            Color(0xFFE64A00),
          ],
        );

      case CardBrand.gcash:
        // Deep GCash Cobalt / Electric Blue
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0066FF),
            Color(0xFF0052D4),
            Color(0xFF003399),
          ],
        );

      case CardBrand.maya:
        // Stealth Matte Obsidian Black with subtle sheen
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E222D),
            Color(0xFF12151C),
            Color(0xFF0B0D12),
          ],
        );

      case CardBrand.bdo:
        // Classic BDO Royal Navy Blue
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF003E80),
            Color(0xFF002F65),
            Color(0xFF001F45),
          ],
        );

      case CardBrand.bpi:
        // Rich BPI Burgundy / Crimson Red
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9E1B22),
            Color(0xFF7A1016),
            Color(0xFF55080C),
          ],
        );

      case CardBrand.unionBank:
        // Tech Charcoal with Electric Orange corner
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C2F36),
            Color(0xFF1C1E24),
            Color(0xFF101216),
          ],
        );

      case CardBrand.goTyme:
        // Dual-tone GoTyme Midnight and Electric Cyan
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F1E36),
            Color(0xFF0C2A44),
            Color(0xFF004D66),
          ],
        );

      case CardBrand.wise:
        // Iconic Acid Bright Neon Lime / Fast Green
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9FE870),
            Color(0xFF8CE058),
            Color(0xFF79D443),
          ],
        );

      case CardBrand.paypal:
        // Iconic PayPal Dual-Blue
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0079C1),
            Color(0xFF00457C),
            Color(0xFF00264A),
          ],
        );

      case CardBrand.venmo:
        // Venmo Sky Blue
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF008CFF),
            Color(0xFF0075D8),
            Color(0xFF005EB0),
          ],
        );

      case CardBrand.cash:
        // Luxury Deep Emerald Banknote
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF005A36),
            Color(0xFF004428),
            Color(0xFF00301C),
          ],
        );

      case CardBrand.custom:
        // Sleek Stash Deep Space Obsidian
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF262C38),
            Color(0xFF1A1F2B),
            Color(0xFF12151E),
          ],
        );
    }
  }

  Color get textColor {
    switch (this) {
      case CardBrand.wise:
        return const Color(0xFF163300); // Dark Forest Green on Neon Lime
      default:
        return Colors.white;
    }
  }

  Color get subtextColor {
    switch (this) {
      case CardBrand.wise:
        return const Color(0xFF2E590A);
      case CardBrand.maya:
        return const Color(0xFF00E676); // Luminous Maya neon green
      default:
        return Colors.white.withValues(alpha: 0.75);
    }
  }

  CardNetwork get defaultNetwork {
    switch (this) {
      case CardBrand.mariBank:
      case CardBrand.bdo:
      case CardBrand.wise:
      case CardBrand.paypal:
      case CardBrand.venmo:
        return CardNetwork.mastercard;
      case CardBrand.gcash:
      case CardBrand.maya:
      case CardBrand.bpi:
      case CardBrand.unionBank:
      case CardBrand.goTyme:
        return CardNetwork.visa;
      case CardBrand.cash:
      case CardBrand.custom:
        return CardNetwork.none;
    }
  }

  String get defaultTag {
    switch (this) {
      case CardBrand.cash:
        return 'CASH';
      case CardBrand.gcash:
      case CardBrand.maya:
      case CardBrand.venmo:
        return 'E-WALLET';
      case CardBrand.wise:
      case CardBrand.paypal:
        return 'GLOBAL';
      default:
        return 'DEBIT';
    }
  }

  /// Automatically detects the physical card brand based on account name or institution.
  static CardBrand detect(String name, [String? institution]) {
    final combined = '${name.toLowerCase()} ${institution?.toLowerCase() ?? ""}';

    if (combined.contains('mari') || combined.contains('seabank') || combined.contains('maribank')) {
      return CardBrand.mariBank;
    }
    if (combined.contains('gcash')) {
      return CardBrand.gcash;
    }
    if (combined.contains('maya') || combined.contains('paymaya')) {
      return CardBrand.maya;
    }
    if (combined.contains('bdo') || combined.contains('bdo unibank')) {
      return CardBrand.bdo;
    }
    if (combined.contains('bpi') || combined.contains('islands')) {
      return CardBrand.bpi;
    }
    if (combined.contains('unionbank') || combined.contains('union bank') || combined.contains('ubp')) {
      return CardBrand.unionBank;
    }
    if (combined.contains('gotyme') || combined.contains('tyme')) {
      return CardBrand.goTyme;
    }
    if (combined.contains('wise') || combined.contains('transferwise')) {
      return CardBrand.wise;
    }
    if (combined.contains('paypal')) {
      return CardBrand.paypal;
    }
    if (combined.contains('venmo')) {
      return CardBrand.venmo;
    }
    if (combined.contains('cash') || combined.contains('wallet') || combined.contains('physical cash')) {
      return CardBrand.cash;
    }

    return CardBrand.custom;
  }
}
