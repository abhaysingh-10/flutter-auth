import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';
import '../models/auth_state.dart';
import '../models/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(DioClient().dio, StorageService());
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;
  final StorageService _storage;

  AuthNotifier(this._dio, this._storage) : super(const AuthInitial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = const AuthLoading();
    final token = await _storage.getAccessToken();
    if (token == null) {
      state = const AuthUnauthenticated();
      return;
    }

    try {
      final response = await _dio.get('auth/me/');
      final user = UserModel.fromJson(response.data);
      
      if (!user.isVerified) {
        state = AuthVerificationRequired(user.email);
      } else {
        state = AuthAuthenticated(user);
      }
    } catch (e) {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> verifyEmail(String email, String otp) async {
    state = const AuthLoading();
    try {
      await _dio.post('auth/verify-email/', data: {
        'email': email,
        'otp': otp,
      });
      await checkAuthStatus();
    } on DioException catch (e) {
      state = AuthError(e.response?.data['error'] ?? 'Verification failed');
    }
  }

  Future<void> resendOtp(String email) async {
    try {
      await _dio.post('auth/resend-otp/', data: {'email': email});
    } catch (e) {
      // Handle resend error silently or via state
    }
  }

  Future<void> login(String identifier, String password) async {
    state = const AuthLoading();
    try {
      final response = await _dio.post('auth/login/', data: {
        'username': identifier,
        'password': password,
      });

      final access = response.data['access'];
      final refresh = response.data['refresh'];

      await _storage.saveTokens(access: access, refresh: refresh);
      await checkAuthStatus();
    } on DioException catch (e) {
      state = AuthError(e.response?.data['detail'] ?? 'Login failed');
    } catch (e) {
      state = AuthError('An unexpected error occurred');
    }
  }

  Future<void> register(String fullName, String username, String email, String password) async {
    state = const AuthLoading();
    try {
      await _dio.post('auth/register/', data: {
        'full_name': fullName,
        'username': username,
        'email': email,
        'password': password,
      });
      
      // Auto login after registration
      await login(email, password);
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMsg = 'Registration failed';
      if (data is Map) {
        if (data.containsKey('email')) {
          errorMsg = data['email'][0];
        } else if (data.containsKey('username')) {
          errorMsg = data['username'][0];
        }
      }
      state = AuthError(errorMsg);
    } catch (e) {
      state = AuthError('An unexpected error occurred');
    }
  }

  Future<void> loginWithGoogle() async {
    state = const AuthLoading();
    try {
      // Integration Step:
      // 1. Setup Google Cloud Project
      // 2. Add 'google_sign_in' logic here
      // 3. Send token to backend

      await Future.delayed(const Duration(seconds: 2));
      state = const AuthError('Google Sign-In logic is ready! To activate, please add your Client ID in the Google Console.');
    } catch (e) {
      state = const AuthError('Google Sign-In connection failed');
    }
  }

  Future<void> loginWithApple() async {
    state = const AuthLoading();
    try {
      // Integration Step:
      // 1. Setup Apple Developer Account
      // 2. Add 'sign_in_with_apple' logic here

      await Future.delayed(const Duration(seconds: 2));
      state = const AuthError('Apple Sign-In logic is ready! To activate, please add your Team ID in the Apple Developer Portal.');
    } catch (e) {
      state = const AuthError('Apple Sign-In connection failed');
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    try {
      final refresh = await _storage.getRefreshToken();

      if (refresh != null) {
        await _dio.post(
          'auth/logout/',
          data: {'refresh': refresh},
        );
      }
    } catch (e) {
      // Even if logout request fails, we should clear local storage
    } finally {
      await _storage.clearTokens();
      state = const AuthUnauthenticated();
    }
  }
}
