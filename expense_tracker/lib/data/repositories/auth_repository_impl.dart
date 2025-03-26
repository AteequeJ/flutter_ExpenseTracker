import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Box<UserModel> _userBox;
  final Box _settingsBox;

  AuthRepositoryImpl({
    required Box<UserModel> userBox,
    required Box settingsBox,
  })  : _userBox = userBox,
        _settingsBox = settingsBox;

  @override
  Future<User?> getCurrentUser() async {
    final currentUserId = _settingsBox.get('currentUserId');
    if (currentUserId == null) return null;

    final userModel = _userBox.get(currentUserId);
    return userModel?.toEntity();
  }

  @override
  Future<User> login(String email, String password) async {
    final users = _userBox.values.where((user) => user.email == email);
    if (users.isEmpty) {
      throw Exception('User not found');
    }

    final user = users.first;
    final passwordHash = _hashPassword(password);

    if (user.passwordHash != passwordHash) {
      throw Exception('Invalid password');
    }

    await _settingsBox.put('currentUserId', user.id);
    return user.toEntity();
  }

  @override
  Future<User> register(String name, String email, String password) async {
    final existingUser = _userBox.values.any((user) => user.email == email);
    if (existingUser) {
      throw Exception('Email already in use');
    }

    final passwordHash = _hashPassword(password);
    final userModel = UserModel(
      email: email,
      name: name,
      passwordHash: passwordHash,
    );

    await _userBox.put(userModel.id, userModel);
    await _settingsBox.put('currentUserId', userModel.id);

    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    await _settingsBox.delete('currentUserId');
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

