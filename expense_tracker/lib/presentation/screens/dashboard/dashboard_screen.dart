import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/notification_helper.dart';
import '../../../domain/entities/expense.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/expense_list.dart';
import '../../widgets/expense_summary.dart';
import '../../widgets/filter_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _setupNotifications();
  }

  Future<void> _loadExpenses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      await expenseProvider.loadExpenses(authProvider.currentUser!.id);
    }
  }

  Future<void> _setupNotifications() async {
    await NotificationHelper.initialize();
    await NotificationHelper.scheduleDaily(
      id: 1,
      title: 'Expense Reminder',
      body: 'Don\'t forget to record your expenses for today!',
      hour: 20,
      minute: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final localizations = AppLocalizations.of(context);

    final List<Widget> pages = [
      // Home page with expense list
      Column(
        children: [
          FilterBar(
            onFilterByCategory: (category) {
              if (authProvider.currentUser != null) {
                expenseProvider.filterByCategory(
                  category,
                  authProvider.currentUser!.id,
                );
              }
            },
            onFilterByDateRange: (start, end) {
              if (authProvider.currentUser != null) {
                expenseProvider.filterByDateRange(
                  start,
                  end,
                  authProvider.currentUser!.id,
                );
              }
            },
            onClearFilters: () {
              if (authProvider.currentUser != null) {
                expenseProvider.clearFilters(authProvider.currentUser!.id);
              }
            },
            selectedCategory: expenseProvider.selectedCategory,
            startDate: expenseProvider.startDate,
            endDate: expenseProvider.endDate,
          ),
          Expanded(
            child: ExpenseList(
              expenses: expenseProvider.expenses,
              isLoading: expenseProvider.isLoading,
              onDelete: (String id) async {
                if (authProvider.currentUser != null) {
                  await expenseProvider.deleteExpense(
                    id,
                    authProvider.currentUser!.id,
                  );
                }
              },
              onEdit: (Expense expense) {
                Navigator.of(context).pushNamed(
                  AppRouter.editExpenseRoute,
                  arguments: {'expenseId': expense.id},
                );
              },
              onView: (Expense expense) {
                Navigator.of(context).pushNamed(
                  AppRouter.expenseDetailsRoute,
                  arguments: {'expenseId': expense.id},
                );
              },
            ),
          ),
        ],
      ),
      // Summary page
      ExpenseSummary(
        expenses: expenseProvider.expenses,
        categorySummary: expenseProvider.getCategorySummary(),
        totalExpenses: expenseProvider.getTotalExpenses(),
        dailySummary: expenseProvider.getDailySummary(),
      ),
    ];

    DateTime? lastPressed;

    Future<bool> onWillPop() async {
      DateTime now = DateTime.now();
      if (lastPressed == null ||
          now.difference(lastPressed!) > Duration(seconds: 2)) {
        lastPressed = now;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Press back again to exit"),
            duration: Duration(seconds: 2),
          ),
        );
        return Future.value(false); // Do not exit the app
      }
      return Future.value(true); // Exit the app
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.translate('expense_tracker')),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.settingsRoute);
              },
            ),
          ],
        ),
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.list),
              label: localizations.translate('expenses'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.pie_chart),
              label: localizations.translate('summary'),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRouter.addExpenseRoute);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
