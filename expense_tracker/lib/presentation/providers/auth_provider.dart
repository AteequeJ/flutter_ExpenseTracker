import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  late AuthRepositoryImpl _repository;
  late GetCurrentUserUseCase _getCurrentUserUseCase;
  late LoginUseCase _loginUseCase;
  late RegisterUseCase _registerUseCase;
  late LogoutUseCase _logoutUseCase;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider() {
    _initialize();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> _initialize() async {
    final userBox = Hive.box<UserModel>('users');
    final settingsBox = Hive.box('settings');

    _repository = AuthRepositoryImpl(
      userBox: userBox,
      settingsBox: settingsBox,
    );

    _getCurrentUserUseCase = GetCurrentUserUseCase(_repository);
    _loginUseCase = LoginUseCase(_repository);
    _registerUseCase = RegisterUseCase(_repository);
    _logoutUseCase = LogoutUseCase(_repository);
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Add a small delay to ensure the splash screen is visible
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = await _getCurrentUserUseCase.execute();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _loginUseCase.execute(email, password);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _registerUseCase.execute(name, email, password);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _logoutUseCase.execute();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
