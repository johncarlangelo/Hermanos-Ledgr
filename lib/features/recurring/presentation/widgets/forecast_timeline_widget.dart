import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hermanos_ledgr/app/theme/color_tokens.dart';
import 'package:hermanos_ledgr/core/utils/currency_formatter.dart';
import 'package:hermanos_ledgr/features/recurring/domain/forecast_engine.dart';
import 'package:hermanos_ledgr/shared/widgets/m3_card.dart';

/// Interactive Cashflow Forecast Timeline Widget using fl_chart (Task 8.8).
class ForecastTimelineWidget extends StatelessWidget {
  final CashflowForecast forecast;

  const ForecastTimelineWidget({
    super.key,
    required this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTeal = isDark ? StashColors.tealAccent : theme.colorScheme.primary;

    if (forecast.dataPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = <FlSpot>[];
    double minY = forecast.startingBalance;
    double maxY = forecast.startingBalance;

    for (final point in forecast.dataPoints) {
      spots.add(FlSpot(point.dayIndex.toDouble(), point.projectedBalance));
      minY = min(minY, point.projectedBalance);
      maxY = max(maxY, point.projectedBalance);
    }

    // Safety padding for Y range
    final yRange = maxY - minY;
    final yPadding = yRange > 0 ? yRange * 0.15 : (maxY.abs() * 0.15 + 1000);
    final chartMinY = minY - yPadding;
    final chartMaxY = maxY + yPadding;

    return M3Card(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROJECTED CASHFLOW CURVE',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: primaryTeal,
                ),
              ),
              Text(
                '${forecast.daysHorizon} Days',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),

          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: forecast.daysHorizon.toDouble(),
                minY: chartMinY,
                maxY: chartMaxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yRange > 0 ? yRange / 3 : 1000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: (forecast.daysHorizon / 3).floorToDouble().clamp(1.0, 30.0),
                      getTitlesWidget: (value, meta) {
                        final day = value.toInt();
                        if (day < 0 || day >= forecast.dataPoints.length) {
                          return const SizedBox.shrink();
                        }
                        final date = forecast.dataPoints[day].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('MMM d').format(date),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final dayIndex = spot.x.toInt();
                        if (dayIndex < 0 || dayIndex >= forecast.dataPoints.length) {
                          return null;
                        }
                        final pt = forecast.dataPoints[dayIndex];
                        final dateStr = DateFormat('MMM d').format(pt.date);
                        final balanceStr = CurrencyFormatter.format(pt.projectedBalance);

                        String title = '$dateStr · $balanceStr';
                        if (pt.events.isNotEmpty) {
                          final eventNames = pt.events.map((e) => e.rule.title).join(', ');
                          title += '\n$eventNames';
                        }

                        return LineTooltipItem(
                          title,
                          TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    preventCurveOverShooting: true,
                    color: primaryTeal,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) {
                        final idx = spot.x.toInt();
                        if (idx >= 0 && idx < forecast.dataPoints.length) {
                          return forecast.dataPoints[idx].events.isNotEmpty;
                        }
                        return false;
                      },
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: primaryTeal,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primaryTeal.withValues(alpha: 0.25),
                          primaryTeal.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
