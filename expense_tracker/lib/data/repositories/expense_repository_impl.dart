import 'package:hive/hive.dart';

import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final Box<ExpenseModel> _expenseBox;

  ExpenseRepositoryImpl({required Box<ExpenseModel> expenseBox})
    : _expenseBox = expenseBox;

  @override
  Future<List<Expense>> getExpenses(String userId) async {
    print('Getting expenses for user: $userId');
    print('Current box size: ${_expenseBox.length}');
    print('All keys in box: ${_expenseBox.keys.toList()}');

    final expenses =
        _expenseBox.values
            .where((expense) => expense.userId == userId)
            .map((model) => model.toEntity())
            .toList();

    print('Found ${expenses.length} expenses for user');

    // Sort by date (newest first)
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  @override
  Future<Expense> getExpenseById(String id) async {
    final expenseModel = _expenseBox.get(id);
    if (expenseModel == null) {
      throw Exception('Expense not found');
    }
    return expenseModel.toEntity();
  }

  @override
  Future<List<Expense>> getExpensesByCategory(
    String userId,
    ExpenseCategory category,
  ) async {
    final expenses =
        _expenseBox.values
            .where(
              (expense) =>
                  expense.userId == userId &&
                  expense.categoryIndex == category.index,
            )
            .map((model) => model.toEntity())
            .toList();

    // Sort by date (newest first)
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final expenses =
        _expenseBox.values
            .where(
              (expense) =>
                  expense.userId == userId &&
                  expense.date.isAfter(
                    start.subtract(const Duration(days: 1)),
                  ) &&
                  expense.date.isBefore(end.add(const Duration(days: 1))),
            )
            .map((model) => model.toEntity())
            .toList();

    // Sort by date (newest first)
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  @override
  Future<String> addExpense(Expense expense) async {
    final expenseModel = ExpenseModel.fromEntity(expense);
    print('Adding expense with ID: ${expenseModel.id}');
    print('Current box size before adding: ${_expenseBox.length}');
    await _expenseBox.put(expenseModel.id, expenseModel);
    print('Current box size after adding: ${_expenseBox.length}');
    return expenseModel.id;
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final expenseModel = ExpenseModel.fromEntity(expense);
    await _expenseBox.put(expenseModel.id, expenseModel);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _expenseBox.delete(id);
  }
}
