// Dashboard Hub screen with staggered animations.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/neumorphic_box.dart';
import '../../core/widgets/animations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Text(
              'Hermanos Ledgr',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.settings_rounded, color: AppColors.primary)),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Balance Card
                ScaleIn(
                  delayMs: 100,
                  child: NeumorphicContainer(
                    state: NeumorphicState.extruded,
                    borderRadius: 12,
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                    child: Column(
                      children: [
                        Text('Current Balance', style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant,
                        )),
                        const SizedBox(height: 8),
                        Text('₱12,450.00', style: GoogleFonts.plusJakartaSans(
                          fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textCharcoal,
                          letterSpacing: -0.96,
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Spend & Earnings Row
                FadeSlideIn(
                  delayMs: 250,
                  child: Row(
                    children: [
                      Expanded(
                        child: NeumorphicSunkenContainer(
                          borderRadius: 12,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.arrow_downward_rounded, color: AppColors.error, size: 20),
                              const SizedBox(height: 8),
                              Text('Weekly Spend', style: GoogleFonts.plusJakartaSans(
                                fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant,
                              )),
                              const SizedBox(height: 4),
                              Text('₱420', style: GoogleFonts.plusJakartaSans(
                                fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textCharcoal,
                              )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: NeumorphicSunkenContainer(
                          borderRadius: 12,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.arrow_upward_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(height: 8),
                              Text('Monthly Earnings', style: GoogleFonts.plusJakartaSans(
                                fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant,
                              )),
                              const SizedBox(height: 4),
                              Text('₱5,200', style: GoogleFonts.plusJakartaSans(
                                fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textCharcoal,
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Recent Activity Header
                FadeSlideIn(
                  delayMs: 400,
                  child: Text('Recent Activity', style: GoogleFonts.plusJakartaSans(
                    fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textCharcoal,
                  )),
                ),
                const SizedBox(height: 12),

                // Transaction Cards — staggered
                ...List.generate(_mockTransactions.length, (i) {
                  final tx = _mockTransactions[i];
                  return FadeSlideIn(
                    delayMs: 500 + (i * 100),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NeumorphicContainer(
                        state: NeumorphicState.extruded,
                        borderRadius: 12,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(tx.icon, color: AppColors.primary, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(tx.title, style: GoogleFonts.plusJakartaSans(
                                fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textCharcoal,
                              )),
                            ),
                            Text(tx.amount, style: GoogleFonts.plusJakartaSans(
                              fontSize: 15, fontWeight: FontWeight.w700,
                              color: tx.isIncome ? AppColors.primary : AppColors.textCharcoal,
                            )),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockTransaction {
  final IconData icon;
  final String title;
  final String amount;
  final bool isIncome;
  const _MockTransaction(this.icon, this.title, this.amount, this.isIncome);
}

const _mockTransactions = [
  _MockTransaction(Icons.account_balance_wallet_rounded, 'Income via GCash', '+₱2,500.00', true),
  _MockTransaction(Icons.account_balance_rounded, 'Income via MariBank', '+₱1,200.00', true),
  _MockTransaction(Icons.shopping_cart_rounded, 'Grocery Shopping', '-₱85.50', false),
  _MockTransaction(Icons.home_rounded, 'Monthly Rent', '-₱1,200.00', false),
];
