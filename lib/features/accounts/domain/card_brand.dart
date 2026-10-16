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
  metrobank,
  securityBank,
  rcbc,
  chinaBank,
  landBank,
  psBank,
  unoBank,
  unionDigital,
  aub,
  pbcom,
  eastWest,
  stripe,
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
      case CardBrand.metrobank:
        return 'Metrobank';
      case CardBrand.securityBank:
        return 'Security Bank';
      case CardBrand.rcbc:
        return 'RCBC';
      case CardBrand.chinaBank:
        return 'China Bank';
      case CardBrand.landBank:
        return 'LandBank';
      case CardBrand.psBank:
        return 'PSBank';
      case CardBrand.unoBank:
        return 'UNO Digital Bank';
      case CardBrand.unionDigital:
        return 'UnionDigital Bank';
      case CardBrand.aub:
        return 'AUB';
      case CardBrand.pbcom:
        return 'PBCOM';
      case CardBrand.eastWest:
        return 'EastWest Bank';
      case CardBrand.stripe:
        return 'Stripe';
      case CardBrand.custom:
        return 'Custom';
    }
  }

  /// Path to pre-generated SVG card skin, if available.
  String? get svgAssetPath {
    switch (this) {
      case CardBrand.mariBank:
        return 'assets/cards/maribank.svg';
      case CardBrand.gcash:
        return 'assets/cards/gcash.svg';
      case CardBrand.maya:
        return 'assets/cards/maya.svg';
      case CardBrand.bdo:
        return 'assets/cards/bdo.svg';
      case CardBrand.bpi:
        return 'assets/cards/bpi.svg';
      case CardBrand.unionBank:
        return 'assets/cards/unionbank.svg';
      case CardBrand.goTyme:
        return 'assets/cards/gotyme.svg';
      case CardBrand.wise:
        return 'assets/cards/wise.svg';
      case CardBrand.paypal:
        return 'assets/cards/paypal.svg';
      case CardBrand.venmo:
        return 'assets/cards/venmo.svg';
      case CardBrand.grabPay:
        return 'assets/cards/grabpay.svg';
      case CardBrand.shopeePay:
        return 'assets/cards/shopeepay.svg';
      case CardBrand.tonik:
        return 'assets/cards/tonik.svg';
      case CardBrand.cimb:
        return 'assets/cards/cimb.svg';
      case CardBrand.coins:
        return 'assets/cards/coinsph.svg';
      case CardBrand.appleCash:
        return 'assets/cards/applecash.svg';
      case CardBrand.googleWallet:
        return 'assets/cards/googlewallet.svg';
      case CardBrand.cash:
        return 'assets/cards/cash.svg';
      case CardBrand.metrobank:
        return 'assets/cards/metrobank.svg';
      case CardBrand.securityBank:
        return 'assets/cards/securitybank.svg';
      case CardBrand.rcbc:
        return 'assets/cards/rcbc.svg';
      case CardBrand.chinaBank:
        return 'assets/cards/chinabank.svg';
      case CardBrand.landBank:
        return 'assets/cards/landbank.svg';
      case CardBrand.psBank:
        return 'assets/cards/psbank.svg';
      case CardBrand.unoBank:
        return 'assets/cards/unobank.svg';
      case CardBrand.unionDigital:
        return 'assets/cards/uniondigital.svg';
      case CardBrand.aub:
        return 'assets/cards/aub.svg';
      case CardBrand.pbcom:
        return 'assets/cards/pbcom.svg';
      case CardBrand.eastWest:
        return 'assets/cards/eastwestrural.svg';
      case CardBrand.stripe:
        return 'assets/cards/stripe.svg';
      case CardBrand.custom:
        return null;
    }
  }

  LinearGradient get gradient {
    switch (this) {
      case CardBrand.mariBank:
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
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF005A36),
            Color(0xFF004428),
            Color(0xFF00301C),
          ],
        );

      case CardBrand.metrobank:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0E4DA4),
            Color(0xFF0A2D63),
            Color(0xFF061B3D),
          ],
        );

      case CardBrand.securityBank:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B3F8F),
            Color(0xFF082A60),
            Color(0xFF051B40),
          ],
        );

      case CardBrand.rcbc:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF12439B),
            Color(0xFF0A2766),
            Color(0xFF051740),
          ],
        );

      case CardBrand.chinaBank:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFC8102E),
            Color(0xFF7E0A1D),
            Color(0xFF4D0512),
          ],
        );

      case CardBrand.landBank:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B7A3B),
            Color(0xFF064D25),
            Color(0xFF033017),
          ],
        );

      case CardBrand.psBank:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F6CBD),
            Color(0xFF0A3F73),
            Color(0xFF062647),
          ],
        );

      case CardBrand.unoBank:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4B2A9B),
            Color(0xFF2A1566),
            Color(0xFF180A40),
          ],
        );

      case CardBrand.unionDigital:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF101B3D),
            Color(0xFF1A2E66),
            Color(0xFF0A1024),
          ],
        );

      case CardBrand.aub:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8C1C2C),
            Color(0xFF4F0E18),
            Color(0xFF30080E),
          ],
        );

      case CardBrand.pbcom:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF14306B),
            Color(0xFF0A1B40),
            Color(0xFF050E24),
          ],
        );

      case CardBrand.eastWest:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7A2C95),
            Color(0xFF451558),
            Color(0xFF280A33),
          ],
        );

      case CardBrand.stripe:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF635BFF),
            Color(0xFF3B2FD1),
            Color(0xFF241C8A),
          ],
        );

      case CardBrand.custom:
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
      case CardBrand.metrobank:
      case CardBrand.securityBank:
      case CardBrand.rcbc:
      case CardBrand.chinaBank:
      case CardBrand.landBank:
      case CardBrand.psBank:
      case CardBrand.unoBank:
      case CardBrand.aub:
      case CardBrand.pbcom:
      case CardBrand.eastWest:
        return CardNetwork.mastercard;
      case CardBrand.gcash:
      case CardBrand.maya:
      case CardBrand.bpi:
      case CardBrand.unionBank:
      case CardBrand.goTyme:
      case CardBrand.grabPay:
      case CardBrand.shopeePay:
      case CardBrand.unionDigital:
        return CardNetwork.visa;
      case CardBrand.appleCash:
      case CardBrand.googleWallet:
      case CardBrand.coins:
      case CardBrand.cash:
      case CardBrand.stripe:
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
      case CardBrand.stripe:
        return 'GLOBAL';
      case CardBrand.tonik:
      case CardBrand.cimb:
      case CardBrand.goTyme:
      case CardBrand.unoBank:
      case CardBrand.unionDigital:
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
    if (combined.contains('metrobank')) {
      return CardBrand.metrobank;
    }
    if (combined.contains('security') || combined.contains('securitybank')) {
      return CardBrand.securityBank;
    }
    if (combined.contains('rcbc')) {
      return CardBrand.rcbc;
    }
    if (combined.contains('chinabank') || combined.contains('china bank')) {
      return CardBrand.chinaBank;
    }
    if (combined.contains('landbank') || combined.contains('land bank')) {
      return CardBrand.landBank;
    }
    if (combined.contains('psbank') || combined.contains('ps bank')) {
      return CardBrand.psBank;
    }
    if (combined.contains('uno') || combined.contains('unobank')) {
      return CardBrand.unoBank;
    }
    if (combined.contains('uniondigital')) {
      return CardBrand.unionDigital;
    }
    if (combined.contains('aub')) {
      return CardBrand.aub;
    }
    if (combined.contains('pbcom')) {
      return CardBrand.pbcom;
    }
    if (combined.contains('eastwest')) {
      return CardBrand.eastWest;
    }
    if (combined.contains('stripe')) {
      return CardBrand.stripe;
    }
    if (combined.contains('cash') || combined.contains('wallet') || combined.contains('physical cash')) {
      return CardBrand.cash;
    }

    return CardBrand.custom;
  }
}
