import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/expense.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final int categoryIndex;

  @HiveField(5)
  final String userId;

  ExpenseModel({
    String? id,
    required this.amount,
    required this.description,
    required this.date,
    required this.categoryIndex,
    required this.userId,
  }) : id = (id == null || id.isEmpty) ? const Uuid().v4() : id;

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      amount: expense.amount,
      description: expense.description,
      date: expense.date,
      categoryIndex: expense.category.index,
      userId: expense.userId,
    );
  }

  Expense toEntity() {
    return Expense(
      id: id,
      amount: amount,
      description: description,
      date: date,
      category: ExpenseCategory.values[categoryIndex],
      userId: userId,
    );
  }
}

// This is a placeholder for the generated adapter file
// In a real project, you would run 'flutter packages pub run build_runner build'
// to generate this file
class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  @override
  final int typeId = 0;

  @override
  ExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseModel(
      id: fields[0] as String,
      amount: fields[1] as double,
      description: fields[2] as String,
      date: fields[3] as DateTime,
      categoryIndex: fields[4] as int,
      userId: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.categoryIndex)
      ..writeByte(5)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
