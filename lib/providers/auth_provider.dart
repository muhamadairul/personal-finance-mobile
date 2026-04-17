import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencatat_keuangan/models/user.dart';
import 'package:pencatat_keuangan/services/api_service.dart';
import 'package:pencatat_keuangan/services/social_auth_service.dart';
import 'package:pencatat_keuangan/services/notification_service.dart';
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
  final SocialAuthService _socialAuthService = SocialAuthService();
  final NotificationService _notificationService = NotificationService();

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

        // Register FCM token after confirming auth
        await _notificationService.registerToken();
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

      // Register FCM token after login
      await _notificationService.registerToken();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Email atau kata sandi salah',
      );
      return false;
    }
  }

  // Login with Google
  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Google Sign-In (native SDK)
      final result = await _socialAuthService.signInWithGoogle();

      if (result == null) {
        // User cancelled
        state = state.copyWith(isLoading: false);
        return false;
      }

      // 2. Send ID token to backend for verification & user creation
      final response = await _apiService.post(
        ApiConfig.socialLogin,
        data: {
          'provider': 'google',
          'id_token': result.idToken,
          'name': result.name,
          'email': result.email,
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

      // Register FCM token after social login
      await _notificationService.registerToken();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login dengan Google gagal. Silakan coba lagi.',
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

      // Register FCM token after registration
      await _notificationService.registerToken();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Registrasi gagal. Silakan coba lagi.',
      );
      return false;
    }
  }

  // Update Profile (multi-field)
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put(
        ApiConfig.updateProfile,
        data: data,
      );

      final updatedUser = User.fromJson(response.data['data']);
      state = state.copyWith(
        user: updatedUser.copyWith(token: state.user?.token),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Upload Photo
  Future<bool> uploadPhoto(File image) async {
    try {
      final response = await _apiService.uploadFile(
        ApiConfig.uploadPhoto,
        image,
        fieldName: 'photo',
      );

      final updatedUser = User.fromJson(response.data['data']);
      state = state.copyWith(
        user: updatedUser.copyWith(token: state.user?.token),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete Photo
  Future<bool> deletePhoto() async {
    try {
      final response = await _apiService.delete(ApiConfig.deletePhoto);

      final updatedUser = User.fromJson(response.data['data']);
      state = state.copyWith(
        user: updatedUser.copyWith(token: state.user?.token),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      // Unregister FCM token before logout
      await _notificationService.unregisterToken();
      await _socialAuthService.signOutGoogle();
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
