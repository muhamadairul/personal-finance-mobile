import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencatat_keuangan/models/user.dart';
import 'package:pencatat_keuangan/services/api_service.dart';
import 'package:pencatat_keuangan/config/api_config.dart';

// Auth state
@immutable
class AuthState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService = ApiService();

  AuthNotifier() : super(const AuthState());

  // Check if user is already logged in
  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);

    try {
      final token = await _apiService.getToken();
      if (token != null) {
        final response = await _apiService.get(ApiConfig.user);
        final user = User.fromJson(response.data['data']);
        state = AuthState(
          user: user.copyWith(token: token),
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = const AuthState(isLoading: false);
      }
    } catch (e) {
      await _apiService.clearToken();
      state = const AuthState(isLoading: false);
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.post(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'] as String;
      await _apiService.saveToken(token);

      final user = User.fromJson(response.data['user']);
      state = AuthState(
        user: user.copyWith(token: token),
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Email atau kata sandi salah',
      );
      return false;
    }
  }

  // Register
  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.post(
        ApiConfig.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );

      final token = response.data['token'] as String;
      await _apiService.saveToken(token);

      final user = User.fromJson(response.data['user']);
      state = AuthState(
        user: user.copyWith(token: token),
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Registrasi gagal. Silakan coba lagi.',
      );
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _apiService.post(ApiConfig.logout);
    } catch (_) {}

    await _apiService.clearToken();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Riverpod providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
