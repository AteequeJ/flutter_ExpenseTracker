import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpensesUseCase {
  final ExpenseRepository repository;

  GetExpensesUseCase(this.repository);

  Future<List<Expense>> execute(String userId) {
    return repository.getExpenses(userId);
  }
}

class GetExpenseByIdUseCase {
  final ExpenseRepository repository;

  GetExpenseByIdUseCase(this.repository);

  Future<Expense> execute(String id) {
    return repository.getExpenseById(id);
  }
}

class GetExpensesByCategoryUseCase {
  final ExpenseRepository repository;

  GetExpensesByCategoryUseCase(this.repository);

  Future<List<Expense>> execute(String userId, ExpenseCategory category) {
    return repository.getExpensesByCategory(userId, category);
  }
}

class GetExpensesByDateRangeUseCase {
  final ExpenseRepository repository;

  GetExpensesByDateRangeUseCase(this.repository);

  Future<List<Expense>> execute(String userId, DateTime start, DateTime end) {
    return repository.getExpensesByDateRange(userId, start, end);
  }
}

class AddExpenseUseCase {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  Future<String> execute(Expense expense) {
    return repository.addExpense(expense);
  }
}

class UpdateExpenseUseCase {
  final ExpenseRepository repository;

  UpdateExpenseUseCase(this.repository);

  Future<void> execute(Expense expense) {
    return repository.updateExpense(expense);
  }
}

class DeleteExpenseUseCase {
  final ExpenseRepository repository;

  DeleteExpenseUseCase(this.repository);

  Future<void> execute(String id) {
    return repository.deleteExpense(id);
  }
}

