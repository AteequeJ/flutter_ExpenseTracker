import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../domain/entities/expense.dart';
import '../../providers/expense_provider.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  final String expenseId;

  const ExpenseDetailsScreen({super.key, required this.expenseId});

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadExpense();
  }

  Future<void> _loadExpense() async {
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );
    await expenseProvider.getExpenseById(widget.expenseId);
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expense = expenseProvider.selectedExpense;
    final localizations = AppLocalizations.of(context);

    if (expenseProvider.isLoading || expense == null) {
      return Scaffold(
        appBar: AppBar(title: Text(localizations.translate('expense_details'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('expense_details')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                AppRouter.editExpenseRoute,
                arguments: {'expenseId': expense.id},
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                    Row(
                      children: [
                        Text(
                          '₹',
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Theme.of(context).colorScheme.primary,
                            // color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${localizations.translate('amount')}: ',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '\₹${expense.amount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${localizations.translate('category')}: ',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          expense.category.name.toUpperCase(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${localizations.translate('date')}: ',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          DateFormat('yyyy-MM-dd').format(expense.date),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate('description'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      expense.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
