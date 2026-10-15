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
  grabPay,
  shopeePay,
  tonik,
  cimb,
  coins,
  appleCash,
  googleWallet,
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
      case CardBrand.grabPay:
        return 'GrabPay';
      case CardBrand.shopeePay:
        return 'ShopeePay';
      case CardBrand.tonik:
        return 'Tonik Bank';
      case CardBrand.cimb:
        return 'CIMB Bank';
      case CardBrand.coins:
        return 'Coins.ph';
      case CardBrand.appleCash:
        return 'Apple Cash';
      case CardBrand.googleWallet:
        return 'Google Wallet';
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

      case CardBrand.grabPay:
        // Grab Emerald Green
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00B14F),
            Color(0xFF00893C),
            Color(0xFF005826),
          ],
        );

      case CardBrand.shopeePay:
        // Shopee Coral Orange-Red
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEE4D2D),
            Color(0xFFD03B1E),
            Color(0xFF9E1F07),
          ],
        );

      case CardBrand.tonik:
        // Tonik Electric Purple
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7928CA),
            Color(0xFF5B1DA3),
            Color(0xFF2C0A56),
          ],
        );

      case CardBrand.cimb:
        // CIMB Bold Bank Red
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFED1C24),
            Color(0xFFB30E14),
            Color(0xFF5E0307),
          ],
        );

      case CardBrand.coins:
        // Coins.ph Tech Cobalt
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0066FF),
            Color(0xFF0044B3),
            Color(0xFF002A73),
          ],
        );

      case CardBrand.appleCash:
        // Apple Cash Frosted Titanium / White
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8ECEF),
            Color(0xFFCED4DA),
            Color(0xFFADB5BD),
          ],
        );

      case CardBrand.googleWallet:
        // Google Wallet Dark Obsidian
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF20232A),
            Color(0xFF16181D),
            Color(0xFF0C0D10),
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

  /// Builds a dynamic personalized gradient from a custom account color.
  static LinearGradient customGradient(Color baseColor) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(baseColor, Colors.white, 0.12) ?? baseColor,
        baseColor,
        Color.lerp(baseColor, Colors.black, 0.55) ?? Colors.black,
      ],
    );
  }

  Color get textColor {
    switch (this) {
      case CardBrand.wise:
        return const Color(0xFF163300); // Dark Forest Green on Neon Lime
      case CardBrand.appleCash:
        return const Color(0xFF1C1C1E); // Dark charcoal on silver titanium
      default:
        return Colors.white;
    }
  }

  Color get subtextColor {
    switch (this) {
      case CardBrand.wise:
        return const Color(0xFF2E590A);
      case CardBrand.appleCash:
        return const Color(0xFF636366);
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
      case CardBrand.cimb:
      case CardBrand.tonik:
        return CardNetwork.mastercard;
      case CardBrand.gcash:
      case CardBrand.maya:
      case CardBrand.bpi:
      case CardBrand.unionBank:
      case CardBrand.goTyme:
      case CardBrand.grabPay:
      case CardBrand.shopeePay:
        return CardNetwork.visa;
      case CardBrand.appleCash:
      case CardBrand.googleWallet:
      case CardBrand.coins:
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
      case CardBrand.grabPay:
      case CardBrand.shopeePay:
        return 'E-WALLET';
      case CardBrand.wise:
      case CardBrand.paypal:
        return 'GLOBAL';
      case CardBrand.tonik:
      case CardBrand.cimb:
      case CardBrand.goTyme:
        return 'DIGITAL';
      case CardBrand.coins:
        return 'CRYPTO';
      case CardBrand.appleCash:
      case CardBrand.googleWallet:
        return 'VIRTUAL';
      default:
        return 'DEBIT';
    }
  }

  /// Automatically detects the physical or digital card brand based on account name or institution.
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
    if (combined.contains('grab') || combined.contains('grabpay')) {
      return CardBrand.grabPay;
    }
    if (combined.contains('shopee') || combined.contains('shopeepay')) {
      return CardBrand.shopeePay;
    }
    if (combined.contains('tonik')) {
      return CardBrand.tonik;
    }
    if (combined.contains('cimb')) {
      return CardBrand.cimb;
    }
    if (combined.contains('coins')) {
      return CardBrand.coins;
    }
    if (combined.contains('apple') || combined.contains('apple cash') || combined.contains('apple pay')) {
      return CardBrand.appleCash;
    }
    if (combined.contains('google') || combined.contains('gpay') || combined.contains('google wallet') || combined.contains('google pay')) {
      return CardBrand.googleWallet;
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
