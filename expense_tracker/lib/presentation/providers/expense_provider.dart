import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/expense.dart';
import '../../domain/usecases/expense_usecases.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../data/models/expense_model.dart';

class ExpenseProvider with ChangeNotifier {
  late ExpenseRepositoryImpl _repository;
  late GetExpensesUseCase _getExpensesUseCase;
  late GetExpenseByIdUseCase _getExpenseByIdUseCase;
  late GetExpensesByCategoryUseCase _getExpensesByCategoryUseCase;
  late GetExpensesByDateRangeUseCase _getExpensesByDateRangeUseCase;
  late AddExpenseUseCase _addExpenseUseCase;
  late UpdateExpenseUseCase _updateExpenseUseCase;
  late DeleteExpenseUseCase _deleteExpenseUseCase;

  List<Expense> _expenses = [];
  Expense? _selectedExpense;
  bool _isLoading = false;
  String? _error;
  ExpenseCategory? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  ExpenseProvider() {
    _initialize();
  }

  List<Expense> get expenses => _expenses;
  Expense? get selectedExpense => _selectedExpense;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ExpenseCategory? get selectedCategory => _selectedCategory;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  Future<void> _initialize() async {
    final expenseBox = Hive.box<ExpenseModel>('expenses');

    _repository = ExpenseRepositoryImpl(expenseBox: expenseBox);

    _getExpensesUseCase = GetExpensesUseCase(_repository);
    _getExpenseByIdUseCase = GetExpenseByIdUseCase(_repository);
    _getExpensesByCategoryUseCase = GetExpensesByCategoryUseCase(_repository);
    _getExpensesByDateRangeUseCase = GetExpensesByDateRangeUseCase(_repository);
    _addExpenseUseCase = AddExpenseUseCase(_repository);
    _updateExpenseUseCase = UpdateExpenseUseCase(_repository);
    _deleteExpenseUseCase = DeleteExpenseUseCase(_repository);
  }

  Future<void> loadExpenses(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_selectedCategory != null) {
        _expenses = await _getExpensesByCategoryUseCase.execute(
          userId,
          _selectedCategory!,
        );
      } else if (_startDate != null && _endDate != null) {
        _expenses = await _getExpensesByDateRangeUseCase.execute(
          userId,
          _startDate!,
          _endDate!,
        );
      } else {
        _expenses = await _getExpensesUseCase.execute(userId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getExpenseById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedExpense = await _getExpenseByIdUseCase.execute(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> addExpense(Expense expense) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _addExpenseUseCase.execute(expense);
      await loadExpenses(expense.userId);
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw Exception(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateExpense(Expense expense) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _updateExpenseUseCase.execute(expense);
      await loadExpenses(expense.userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _deleteExpenseUseCase.execute(id);
      await loadExpenses(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByCategory(ExpenseCategory? category, String userId) {
    _selectedCategory = category;
    _startDate = null;
    _endDate = null;
    loadExpenses(userId);
  }

  void filterByDateRange(DateTime start, DateTime end, String userId) {
    _startDate = start;
    _endDate = end;
    _selectedCategory = null;
    loadExpenses(userId);
  }

  void clearFilters(String userId) {
    _selectedCategory = null;
    _startDate = null;
    _endDate = null;
    loadExpenses(userId);
  }

  Map<ExpenseCategory, double> getCategorySummary() {
    final summary = <ExpenseCategory, double>{};

    for (final expense in _expenses) {
      summary[expense.category] =
          (summary[expense.category] ?? 0) + expense.amount;
    }

    return summary;
  }

  double getTotalExpenses() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Map<DateTime, double> getDailySummary() {
    final summary = <DateTime, double>{};

    for (final expense in _expenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      summary[date] = (summary[date] ?? 0) + expense.amount;
    }

    return summary;
  }
}
