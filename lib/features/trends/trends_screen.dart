// Spending Trends screen with staggered animations.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/neumorphic_box.dart';
import '../../core/widgets/animations.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true, backgroundColor: AppColors.background, elevation: 0,
            title: Text('Hermanos Ledgr', style: GoogleFonts.plusJakartaSans(
              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary,
            )),
            centerTitle: true,
            actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.settings_rounded, color: AppColors.primary))],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header
                FadeSlideIn(delayMs: 100, child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Spending Trends', style: GoogleFonts.plusJakartaSans(
                      fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textCharcoal,
                    )),
                    NeumorphicContainer(
                      state: NeumorphicState.extruded, borderRadius: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Text('OCT 2025', style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant,
                      )),
                    ),
                  ],
                )),
                const SizedBox(height: 20),

                // Total Spend
                ScaleIn(delayMs: 200, child: NeumorphicContainer(
                  state: NeumorphicState.extruded, borderRadius: 12, padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('TOTAL SPEND THIS MONTH', style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.6,
                    )),
                    const SizedBox(height: 8),
                    Text('₱ 1,240.50', style: GoogleFonts.plusJakartaSans(
                      fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textCharcoal, letterSpacing: -0.96,
                    )),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.arrow_downward_rounded, color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text('12% less than last month', style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary,
                      )),
                    ]),
                  ]),
                )),
                const SizedBox(height: 24),

                // Chart
                FadeSlideIn(delayMs: 350, child: Text('Weekly Activity', style: GoogleFonts.plusJakartaSans(
                  fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textCharcoal,
                ))),
                const SizedBox(height: 16),
                FadeSlideIn(delayMs: 450, child: NeumorphicContainer(
                  state: NeumorphicState.extruded, borderRadius: 12, padding: const EdgeInsets.all(20), height: 200,
                  child: BarChart(BarChartData(
                    alignment: BarChartAlignment.spaceAround, maxY: 500,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) =>
                        Padding(padding: const EdgeInsets.only(top: 8), child: Text('WK ${v.toInt() + 1}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
                        )),
                      )),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [_bar(0, 280), _bar(1, 350), _bar(2, 180), _bar(3, 420), _bar(4, 310)],
                  )),
                )),
                const SizedBox(height: 24),

                // Categories
                FadeSlideIn(delayMs: 550, child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Categories', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textCharcoal)),
                    Text('VIEW ALL', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.6)),
                  ],
                )),
                const SizedBox(height: 12),
                ...List.generate(_cats.length, (i) => FadeSlideIn(
                  delayMs: 650 + (i * 80),
                  child: Padding(padding: const EdgeInsets.only(bottom: 10), child: NeumorphicContainer(
                    state: NeumorphicState.extruded, borderRadius: 12,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(children: [
                      Icon(_cats[i].icon, color: AppColors.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_cats[i].name, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textCharcoal))),
                      Text(_cats[i].amount, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textCharcoal)),
                    ]),
                  )),
                )),
                const SizedBox(height: 16),

                // Smart Insight
                FadeSlideIn(delayMs: 900, child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Smart Insight', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text("You've spent ₱47 more on Food than last month. Cooking at home twice more could save ₱350 by Sunday.",
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white70, height: 1.4)),
                    ])),
                  ]),
                )),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double y) => BarChartGroupData(x: x, barRods: [
    BarChartRodData(toY: y, width: 28, color: AppColors.primaryContainer,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
  ]);
}

class _Cat { final IconData icon; final String name, amount; const _Cat(this.icon, this.name, this.amount); }
const _cats = [
  _Cat(Icons.restaurant_rounded, 'Food & Dining', '₱450.20'),
  _Cat(Icons.directions_car_rounded, 'Transport', '₱120.00'),
  _Cat(Icons.receipt_long_rounded, 'Rent & Utilities', '₱670.50'),
];
