import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/user.dart';

// part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String passwordHash;

  UserModel({
    String? id,
    required this.email,
    required this.name,
    required this.passwordHash,
  }) : id = id ?? const Uuid().v4();

  factory UserModel.fromEntity(User user, {required String passwordHash}) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      passwordHash: passwordHash,
    );
  }

  User toEntity() {
    return User(id: id, email: email, name: name);
  }
}

// This is a placeholder for the generated adapter file
// In a real project, you would run 'flutter packages pub run build_runner build'
// to generate this file
class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      email: fields[1] as String,
      name: fields[2] as String,
      passwordHash: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.passwordHash);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
