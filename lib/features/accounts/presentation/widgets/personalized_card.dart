import 'package:flutter/material.dart';
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
    final isCash = brand == CardBrand.cash;
    final isWise = brand == CardBrand.wise;
    final isMaya = brand == CardBrand.maya;

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
              gradient: brand.gradient,
              border: Border.all(
                color: isMaya
                    ? const Color(0xFF00E676).withValues(alpha: 0.4)
                    : isSelected
                        ? StashColors.tealAccent
                        : Colors.white.withValues(alpha: 0.12),
                width: isMaya ? 1.2 : isSelected ? 1.5 : 0.8,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
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
                            _buildBrandHeader(brand),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ContactlessWaveIcon(
                                  color: isWise
                                      ? const Color(0xFF163300).withValues(alpha: 0.7)
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

                        // Middle: EMV Smart Chip (except pure physical cash)
                        if (!isCash) ...[
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
                        ] else ...[
                          // Cash emblem
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
              ),
            ),
          ),
        ),
      ),
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
            child: Icon(
              Icons.sentiment_satisfied_alt_rounded,
              size: 110,
              color: Colors.white,
            ),
          ),
        );

      case CardBrand.paypal:
        // Signature overlapping PP monogram watermark
        return Positioned(
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
        return Text(
          account.name.toUpperCase(),
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
