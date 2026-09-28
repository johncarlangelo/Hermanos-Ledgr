// Transaction History screen with staggered animations.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/neumorphic_box.dart';
import '../../core/widgets/animations.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true, backgroundColor: AppColors.background, elevation: 0,
            title: Text('Transaction History', style: GoogleFonts.plusJakartaSans(
              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textCharcoal,
            )),
            centerTitle: true,
            actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.settings_rounded, color: AppColors.primary))],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Search Bar
                FadeSlideIn(delayMs: 100, child: NeumorphicSunkenContainer(
                  borderRadius: 28, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(children: [
                    const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search transactions...', border: InputBorder.none,
                        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.onSurfaceVariant),
                        contentPadding: EdgeInsets.zero, isDense: true,
                      ),
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textCharcoal),
                    )),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.tune_rounded, color: AppColors.onSurfaceVariant, size: 20),
                      padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                  ]),
                )),
                const SizedBox(height: 24),

                FadeSlideIn(delayMs: 200, child: _label('TODAY')),
                const SizedBox(height: 8),
                ..._buildCards(300, [
                  _Tx(Icons.local_cafe_rounded, 'Starbucks Reserve', 'Coffee • 8:30 AM', '', false),
                  _Tx(Icons.account_balance_rounded, 'Salary Deposit', 'BPI • 10:15 AM', '+ ₱45,000.00', true),
                  _Tx(Icons.music_note_rounded, 'Spotify Premium', 'Subscription • 2:00 PM', '- ₱149.00', false),
                ]),
                const SizedBox(height: 20),

                FadeSlideIn(delayMs: 600, child: _label('YESTERDAY')),
                const SizedBox(height: 8),
                ..._buildCards(700, [
                  _Tx(Icons.shopping_cart_rounded, 'SM Supermarket', 'Groceries • 6:45 PM', '- ₱3,450.50', false),
                  _Tx(Icons.account_balance_wallet_rounded, 'GCash Transfer', 'To: Maria D. • 11:20 AM', '- ₱1,500.00', false),
                ]),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text, style: GoogleFonts.plusJakartaSans(
    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.6,
  ));

  List<Widget> _buildCards(int baseDelay, List<_Tx> txs) {
    return List.generate(txs.length, (i) {
      final tx = txs[i];
      return FadeSlideIn(
        delayMs: baseDelay + (i * 100),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: NeumorphicContainer(
            state: NeumorphicState.extruded, borderRadius: 12, padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
                child: Icon(tx.icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tx.title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textCharcoal)),
                const SizedBox(height: 2),
                Text(tx.sub, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant)),
              ])),
              if (tx.amount.isNotEmpty)
                Text(tx.amount, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700,
                  color: tx.isIncome ? AppColors.primary : AppColors.textCharcoal)),
            ]),
          ),
        ),
      );
    });
  }
}

class _Tx { final IconData icon; final String title, sub, amount; final bool isIncome; const _Tx(this.icon, this.title, this.sub, this.amount, this.isIncome); }
