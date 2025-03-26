import 'package:equatable/equatable.dart';

enum ExpenseCategory {
  food,
  transportation,
  entertainment,
  shopping,
  utilities,
  health,
  education,
  other,
}

class Expense extends Equatable {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final ExpenseCategory category;
  final String userId;

  const Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
    required this.userId,
  });

  @override
  List<Object?> get props => [id, amount, description, date, category, userId];
}
