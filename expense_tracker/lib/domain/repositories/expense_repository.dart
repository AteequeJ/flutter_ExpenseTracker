import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses(String userId);
  Future<Expense> getExpenseById(String id);
  Future<List<Expense>> getExpensesByCategory(String userId, ExpenseCategory category);
  Future<List<Expense>> getExpensesByDateRange(String userId, DateTime start, DateTime end);
  Future<String> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
}

