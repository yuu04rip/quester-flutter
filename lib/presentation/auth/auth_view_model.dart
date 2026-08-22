// lib/presentation/auth/auth_view_model.dart

import 'package:flutter/foundation.dart';
import '../../repository/auth_repository.dart';
import '../../domain/service/auth_service.dart';

class AuthUiState {
  final bool loading;
  final bool isAuthenticated;
  final String? error;

  AuthUiState({
    this.loading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthUiState copyWith({
    bool? loading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthUiState(
      loading: loading ?? this.loading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error ?? this.error,
    );
  }
}

class AuthViewModel extends ChangeNotifier {
  final AuthService authService;

  AuthViewModel({required this.authService}) {
    _init();
  }

  AuthUiState _uiState = AuthUiState();
  AuthUiState get uiState => _uiState;

  Future<void> _init() async {
    final loggedIn = await authService.isAuthenticated();
    _uiState = _uiState.copyWith(isAuthenticated: loggedIn);
    notifyListeners();
  }

  Future<void> register(String username, String? email, String password) async {
    _uiState = _uiState.copyWith(loading: true, error: null);
    notifyListeners();

    final result = await authService.register(username, email, password);

    if (result is AuthSuccess) {
      _uiState = _uiState.copyWith(loading: false, error: null, isAuthenticated: true);
    } else if (result is AuthError) {
      _uiState = _uiState.copyWith(loading: false, error: result.message);
    }
    notifyListeners();
  }

  Future<void> login(String identity, String password) async {
    _uiState = _uiState.copyWith(loading: true, error: null);
    notifyListeners();

    final result = await authService.login(identity, password);

    if (result is AuthSuccess) {
      _uiState = _uiState.copyWith(loading: false, error: null, isAuthenticated: true);
    } else if (result is AuthError) {
      _uiState = _uiState.copyWith(loading: false, error: result.message);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await authService.logout();
    _uiState = _uiState.copyWith(isAuthenticated: false);
    notifyListeners();
  }
}