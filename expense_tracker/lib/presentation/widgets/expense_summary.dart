import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/localization/app_localizations.dart';
import '../../domain/entities/expense.dart';

class ExpenseSummary extends StatelessWidget {
  final List<Expense> expenses;
  final Map<ExpenseCategory, double> categorySummary;
  final double totalExpenses;
  final Map<DateTime, double> dailySummary;

  const ExpenseSummary({
    super.key,
    required this.expenses,
    required this.categorySummary,
    required this.totalExpenses,
    required this.dailySummary,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('no_expenses_to_summarize'),
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('total_expenses'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\₹${totalExpenses.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.translate('expenses_by_category'),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PieChart(
                  PieChartData(
                    sections: _getCategorySections(context),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoryLegend(context),
          const SizedBox(height: 24),
          Text(
            localizations.translate('daily_expenses'),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxDailyExpense() * 1.2,
                    barGroups: _getDailyBarGroups(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text('\₹${value.toInt()}');
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final date = _getDateFromIndex(value.toInt());
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat('MM/dd').format(date),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getCategorySections(BuildContext context) {
    final theme = Theme.of(context);
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    int colorIndex = 0;
    categorySummary.forEach((category, amount) {
      final double percentage = (amount / totalExpenses) * 100;
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return sections;
  }

  Widget _buildCategoryLegend(BuildContext context) {
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: List.generate(categorySummary.length, (index) {
            final category = categorySummary.keys.elementAt(index);
            final amount = categorySummary[category]!;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  color: colors[index % colors.length],
                ),
                const SizedBox(width: 4),
                Text(
                  '${category.name}: \₹${amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  List<BarChartGroupData> _getDailyBarGroups() {
    final sortedDates =
        dailySummary.keys.toList()..sort((a, b) => a.compareTo(b));

    return List.generate(sortedDates.length, (index) {
      final date = sortedDates[index];
      final amount = dailySummary[date]!;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: amount,
            // color: theme.colorScheme.primary,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  double _getMaxDailyExpense() {
    if (dailySummary.isEmpty) return 100;
    return dailySummary.values.reduce(
      (max, value) => max > value ? max : value,
    );
  }

  DateTime _getDateFromIndex(int index) {
    final sortedDates =
        dailySummary.keys.toList()..sort((a, b) => a.compareTo(b));

    if (index >= 0 && index < sortedDates.length) {
      return sortedDates[index];
    }
    return DateTime.now();
  }
}
