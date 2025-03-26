import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../core/localization/app_localizations.dart';
import '../../domain/entities/expense.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final bool isLoading;
  final Function(String) onDelete;
  final Function(Expense) onEdit;
  final Function(Expense) onView;

  const ExpenseList({
    super.key,
    required this.expenses,
    required this.isLoading,
    required this.onDelete,
    required this.onEdit,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('no_expenses'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              localizations.translate('add_expense_prompt'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final formattedDate = DateFormat('MMM dd, yyyy').format(expense.date);
        final formattedAmount = '\₹${expense.amount.toStringAsFixed(2)}';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(expense.category),
              child: _getCategoryIcon(expense.category),
            ),
            title: Text(
              expense.description,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            subtitle: Text(formattedDate),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedAmount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit(expense);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, expense);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 18),
                              const SizedBox(width: 8),
                              Text(localizations.translate('edit')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                localizations.translate('delete'),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
            onTap: () => onView(expense),
          ),
        );
      },
    );
  }

  Widget _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return const Icon(Icons.restaurant, color: Colors.white);
      case ExpenseCategory.transportation:
        return const Icon(Icons.directions_car, color: Colors.white);
      case ExpenseCategory.entertainment:
        return const Icon(Icons.movie, color: Colors.white);
      case ExpenseCategory.shopping:
        return const Icon(Icons.shopping_bag, color: Colors.white);
      case ExpenseCategory.utilities:
        return const Icon(Icons.lightbulb, color: Colors.white);
      case ExpenseCategory.health:
        return const Icon(Icons.medical_services, color: Colors.white);
      case ExpenseCategory.education:
        return const Icon(Icons.school, color: Colors.white);
      case ExpenseCategory.other:
        return const Icon(Icons.category, color: Colors.white);
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.amber;
      case ExpenseCategory.transportation:
        return Colors.green;
      case ExpenseCategory.entertainment:
        return Colors.purple;
      case ExpenseCategory.shopping:
        return Colors.teal;
      case ExpenseCategory.utilities:
        return Colors.blue;
      case ExpenseCategory.health:
        return Colors.indigo;
      case ExpenseCategory.education:
        return Colors.orange;
      case ExpenseCategory.other:
        return Colors.red;
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    Expense expense,
  ) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.translate('confirm_delete')),
            content: Text(localizations.translate('delete_confirmation')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(localizations.translate('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(localizations.translate('delete')),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      onDelete(expense.id);
    }
  }
}
