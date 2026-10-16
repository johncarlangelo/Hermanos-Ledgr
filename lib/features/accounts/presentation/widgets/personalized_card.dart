import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/accounts/domain/account_model.dart';
import 'package:hermanos_ledgr/features/accounts/domain/card_brand.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/widgets/card_network_logo.dart';
import 'package:hermanos_ledgr/features/accounts/presentation/widgets/emv_chip_widget.dart';

class PersonalizedCard extends StatelessWidget {
  final AccountModel account;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final bool isSelected;

  const PersonalizedCard({
    super.key,
    required this.account,
    this.onTap,
    this.width = 224,
    this.height = 138,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final brand = CardBrand.detect(account.name, account.institution);
    final svgPath = brand.svgAssetPath;
    final isMaya = brand == CardBrand.maya;
    final isAppleCash = brand == CardBrand.appleCash;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          if (isSelected)
            BoxShadow(
              color: StashColors.tealAccent.withValues(alpha: 0.5),
              blurRadius: 12,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: svgPath == null
                  ? (brand == CardBrand.custom
                      ? CardBrand.customGradient(account.color)
                      : brand.gradient)
                  : null,
              border: Border.all(
                color: isMaya
                    ? const Color(0xFF00E676).withValues(alpha: 0.4)
                    : isAppleCash
                        ? Colors.black.withValues(alpha: 0.12)
                        : isSelected
                            ? StashColors.tealAccent
                            : Colors.white.withValues(alpha: 0.12),
                width: isMaya ? 1.2 : isSelected ? 1.5 : 0.8,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: svgPath != null
                  ? _buildSvgCard(brand, svgPath)
                  : _buildProgrammaticCard(brand),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSvgCard(CardBrand brand, String svgPath) {
    final isWise = brand == CardBrand.wise;
    final isAppleCash = brand == CardBrand.appleCash;
    final textColor = isWise
        ? const Color(0xFF163300)
        : isAppleCash
            ? const Color(0xFF1C1C1E)
            : Colors.white;
    final subtextColor = isWise
        ? const Color(0xFF2E590A)
        : isAppleCash
            ? const Color(0xFF636366)
            : Colors.white.withValues(alpha: 0.85);

    return Stack(
      children: [
        // 1. Vector SVG Card Face (Wordmark, chip, patterns, contactless, network)
        Positioned.fill(
          child: SvgPicture.asset(
            svgPath,
            fit: BoxFit.cover,
          ),
        ),

        // 2. Dynamic Live Account Overlay (Account name, live tabular balance, last 4 digits)
        Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.name,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: subtextColor,
                  letterSpacing: 0.3,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: isAppleCash || isWise ? 0.15 : 0.7),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      CurrencyFormatter.format(account.balance),
                      style: moneyStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.3,
                      ).copyWith(
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: isAppleCash || isWise ? 0.2 : 0.8),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '•••• ${account.id.length >= 4 ? account.id.substring(account.id.length - 4) : "8821"}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: subtextColor,
                      letterSpacing: 0.8,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: isAppleCash || isWise ? 0.15 : 0.7),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgrammaticCard(CardBrand brand) {
    final isCash = brand == CardBrand.cash;
    final isWise = brand == CardBrand.wise;
    final isAppleCash = brand == CardBrand.appleCash;
    final isVirtualOnly = brand == CardBrand.appleCash || brand == CardBrand.googleWallet;

    return Stack(
      children: [
        // --- Brand-Specific Background Patterns & Watermarks ---
        _buildBrandBackground(brand),

        // --- Card Front Content ---
        Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Header: Brand Wordmark/Logo + Network / Contactless
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: _buildBrandHeader(brand),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ContactlessWaveIcon(
                        color: isWise
                            ? const Color(0xFF163300).withValues(alpha: 0.7)
                            : isAppleCash
                                ? const Color(0xFF1C1C1E).withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.75),
                        size: 15,
                      ),
                      const SizedBox(width: Spacing.xs),
                      CardNetworkLogo(
                        network: brand.defaultNetwork,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),

              // Middle: EMV Smart Chip vs Virtual NFC Badge vs Cash
              if (isCash) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'CASH WALLET',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: brand.subtextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (isVirtualOnly) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isAppleCash
                            ? Colors.black.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isAppleCash
                              ? Colors.black.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.nfc_rounded,
                            size: 12,
                            color: brand.textColor.withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'VIRTUAL',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: brand.textColor.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        brand.defaultTag,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: brand.subtextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    EmvChipWidget(
                      isGold: brand != CardBrand.wise && brand != CardBrand.venmo,
                      width: 26,
                      height: 18,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        brand.defaultTag,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: brand.subtextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Bottom: Account Name & Balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: brand.subtextColor,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          CurrencyFormatter.format(account.balance),
                          style: moneyStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: brand.textColor,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '•••• ${account.id.length >= 4 ? account.id.substring(account.id.length - 4) : "8821"}',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: brand.subtextColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBrandBackground(CardBrand brand) {
    switch (brand) {
      case CardBrand.mariBank:
        // Reference design: playful smile face doodle & wave watermarks
        return Positioned(
          right: -10,
          bottom: -15,
          child: Opacity(
            opacity: 0.18,
            child: const Icon(
              Icons.sentiment_satisfied_alt_rounded,
              size: 110,
              color: Colors.white,
            ),
          ),
        );

      case CardBrand.paypal:
        // Signature overlapping PP monogram watermark
        return const Positioned(
          right: 10,
          top: 15,
          child: Opacity(
            opacity: 0.15,
            child: Text(
              'P',
              style: TextStyle(
                fontSize: 110,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          ),
        );

      case CardBrand.bdo:
        // Golden accent ribbon across the card
        return Positioned(
          left: 0,
          right: 0,
          top: 48,
          child: Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFDB913),
                  Color(0xFFFFD54F),
                  Color(0xFFFDB913),
                ],
              ),
            ),
          ),
        );

      case CardBrand.maya:
        // Luminous high-tech glowing corner arc
        return Positioned(
          right: -20,
          top: -20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00E676).withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );

      case CardBrand.wise:
        // Diagonal fast tech stripe
        return Positioned(
          right: -30,
          bottom: -40,
          child: Transform.rotate(
            angle: -0.4,
            child: Container(
              width: 140,
              height: 45,
              color: const Color(0xFF163300).withValues(alpha: 0.08),
            ),
          ),
        );

      case CardBrand.grabPay:
        // Double concentric mobility ring watermark
        return Positioned(
          right: -25,
          bottom: -25,
          child: Opacity(
            opacity: 0.12,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 8),
              ),
            ),
          ),
        );

      case CardBrand.shopeePay:
        // Subtle shopping bag watermark
        return const Positioned(
          right: -10,
          bottom: -15,
          child: Opacity(
            opacity: 0.14,
            child: Icon(
              Icons.shopping_bag_rounded,
              size: 100,
              color: Colors.white,
            ),
          ),
        );

      case CardBrand.tonik:
        // Glowing neon corner glow
        return Positioned(
          right: -15,
          top: -15,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF007A).withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );

      case CardBrand.cimb:
        // Forward arrow chevron watermark
        return const Positioned(
          right: -10,
          bottom: -10,
          child: Opacity(
            opacity: 0.14,
            child: Icon(
              Icons.forward_rounded,
              size: 90,
              color: Colors.white,
            ),
          ),
        );

      case CardBrand.coins:
        // Token coin watermark
        return const Positioned(
          right: -10,
          bottom: -15,
          child: Opacity(
            opacity: 0.14,
            child: Icon(
              Icons.monetization_on_rounded,
              size: 100,
              color: Colors.white,
            ),
          ),
        );

      case CardBrand.appleCash:
        // Apple Cash frosted titanium subtle glow
        return Positioned(
          right: -25,
          bottom: -25,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF5AC8FA).withValues(alpha: 0.22),
                  const Color(0xFF4CD964).withValues(alpha: 0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );

      case CardBrand.googleWallet:
        // Google Wallet icon watermark
        return const Positioned(
          right: -15,
          bottom: -15,
          child: Opacity(
            opacity: 0.12,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 95,
              color: Colors.white,
            ),
          ),
        );

      case CardBrand.cash:
        // Banknote guilloche rings watermark
        return Positioned(
          right: -15,
          bottom: -20,
          child: Opacity(
            opacity: 0.12,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBrandHeader(CardBrand brand) {
    switch (brand) {
      case CardBrand.mariBank:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.waves_rounded,
                size: 12,
                color: Color(0xFFFF5200),
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'MariBank',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
          ],
        );

      case CardBrand.gcash:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0052D4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'gcash',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ],
        );

      case CardBrand.maya:
        return const Text(
          'maya',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF00E676),
            letterSpacing: -0.5,
          ),
        );

      case CardBrand.bdo:
        return const Text(
          'BDO',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFDB913),
            letterSpacing: 0.5,
          ),
        );

      case CardBrand.bpi:
        return const Text(
          'BPI',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        );

      case CardBrand.unionBank:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFFF37021),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'UnionBank',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ],
        );

      case CardBrand.goTyme:
        return const Text(
          'GoTyme',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            color: Color(0xFF00E5FF),
            letterSpacing: -0.3,
          ),
        );

      case CardBrand.wise:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fast_forward_rounded, size: 14, color: Color(0xFF163300)),
            SizedBox(width: 2),
            Text(
              'wise',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF163300),
                letterSpacing: -0.5,
              ),
            ),
          ],
        );

      case CardBrand.paypal:
        return const Text(
          'PayPal',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        );

      case CardBrand.venmo:
        return const Text(
          'venmo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        );

      case CardBrand.grabPay:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 15,
              height: 15,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.navigation_rounded, size: 10, color: Color(0xFF00B14F)),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'GrabPay',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ],
        );

      case CardBrand.shopeePay:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'ShopeePay',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ],
        );

      case CardBrand.tonik:
        return const Text(
          'tonik',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFF007A),
            letterSpacing: -0.5,
          ),
        );

      case CardBrand.cimb:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text(
                'CIMB',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFED1C24),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'BANK',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );

      case CardBrand.coins:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Center(
                child: Text(
                  'C',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'coins.ph',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ],
        );

      case CardBrand.appleCash:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.apple, size: 16, color: Color(0xFF1C1C1E)),
            SizedBox(width: 2),
            Text(
              'Cash',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
                letterSpacing: -0.3,
              ),
            ),
          ],
        );

      case CardBrand.googleWallet:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet_rounded, size: 14, color: Color(0xFF4285F4)),
            const SizedBox(width: 4),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                children: [
                  TextSpan(text: 'G', style: TextStyle(color: Color(0xFF4285F4))),
                  TextSpan(text: 'o', style: TextStyle(color: Color(0xFFEA4335))),
                  TextSpan(text: 'o', style: TextStyle(color: Color(0xFFFBBC05))),
                  TextSpan(text: 'g', style: TextStyle(color: Color(0xFF4285F4))),
                  TextSpan(text: 'l', style: TextStyle(color: Color(0xFF34A853))),
                  TextSpan(text: 'e ', style: TextStyle(color: Color(0xFFEA4335))),
                  TextSpan(text: 'Wallet', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        );

      case CardBrand.cash:
        return const Text(
          'PHYSICAL CASH',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        );

      case CardBrand.custom:
      default:
        return Text(
          account.name.isNotEmpty ? account.name.toUpperCase() : brand.displayName.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
    }
  }
}
