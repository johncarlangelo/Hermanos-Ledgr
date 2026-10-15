import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/features/accounts/domain/card_brand.dart';

class CardNetworkLogo extends StatelessWidget {
  final CardNetwork network;
  final double size;

  const CardNetworkLogo({
    super.key,
    required this.network,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    switch (network) {
      case CardNetwork.mastercard:
        return SizedBox(
          width: size * 1.5,
          height: size,
          child: Stack(
            children: [
              // Red circle (left)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: size,
                  height: size,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEB001B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Yellow/Orange circle (right with blend)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );

      case CardNetwork.visa:
        return Text(
          'VISA',
          style: TextStyle(
            fontSize: size * 0.65,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        );

      case CardNetwork.none:
        return const SizedBox.shrink();
    }
  }
}

class ContactlessWaveIcon extends StatelessWidget {
  final Color color;
  final double size;

  const ContactlessWaveIcon({
    super.key,
    this.color = Colors.white70,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.contactless_rounded,
      size: size,
      color: color,
    );
  }
}
