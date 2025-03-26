import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../domain/entities/expense.dart';

class FilterBar extends StatelessWidget {
  final Function(ExpenseCategory?) onFilterByCategory;
  final Function(DateTime, DateTime) onFilterByDateRange;
  final Function() onClearFilters;
  final ExpenseCategory? selectedCategory;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterBar({
    super.key,
    required this.onFilterByCategory,
    required this.onFilterByDateRange,
    required this.onClearFilters,
    this.selectedCategory,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    String filterText = localizations.translate('all_expenses');
    if (selectedCategory != null) {
      filterText = '${localizations.translate('category')}: ${selectedCategory!.name}';
    } else if (startDate != null && endDate != null) {
      final startFormatted = DateFormat('MM/dd/yyyy').format(startDate!);
      final endFormatted = DateFormat('MM/dd/yyyy').format(endDate!);
      filterText = '$startFormatted - $endFormatted';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  filterText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) async {
                  if (value == 'category') {
                    _showCategoryFilterDialog(context);
                  } else if (value == 'date') {
                    _showDateFilterDialog(context);
                  } else if (value == 'clear') {
                    onClearFilters();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'category',
                    child: Row(
                      children: [
                        const Icon(Icons.category, size: 18),
                        const SizedBox(width: 8),
                        Text(localizations.translate('filter_by_category')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'date',
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Text(localizations.translate('filter_by_date')),
                      ],
                    ),
                  ),
                  if (selectedCategory != null || startDate != null)
                    PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          const Icon(Icons.clear, size: 18),
                          const SizedBox(width: 8),
                          Text(localizations.translate('clear_filters')),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCategoryFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('select_category')),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context).translate('all_categories')),
                  onTap: () {
                    onFilterByCategory(null);
                    Navigator.of(context).pop();
                  },
                ),
                ...ExpenseCategory.values.map((category) {
                  return ListTile(
                    leading: _getCategoryIcon(category),
                    title: Text(category.name.toUpperCase()),
                    selected: selectedCategory == category,
                    onTap: () {
                      onFilterByCategory(category);
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDateFilterDialog(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    DateTime start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    DateTime end = endDate ?? DateTime.now();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(start: start, end: end),
      saveText: localizations.translate('apply'),
      cancelText: localizations.translate('cancel'),
      confirmText: localizations.translate('confirm'),
      helpText: localizations.translate('select_date_range'),
    );

    if (picked != null) {
      onFilterByDateRange(picked.start, picked.end);
    }
  }

  Widget _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return const Icon(Icons.restaurant);
      case ExpenseCategory.transportation:
        return const Icon(Icons.directions_car);
      case ExpenseCategory.entertainment:
        return const Icon(Icons.movie);
      case ExpenseCategory.shopping:
        return const Icon(Icons.shopping_bag);
      case ExpenseCategory.utilities:
        return const Icon(Icons.lightbulb);
      case ExpenseCategory.health:
        return const Icon(Icons.medical_services);
      case ExpenseCategory.education:
        return const Icon(Icons.school);
      case ExpenseCategory.other:
        return const Icon(Icons.category);
    }
  }
}

