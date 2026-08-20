import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../models/login_response.dart';

class AuthRepository {
  final Dio dio;

  AuthRepository(ApiClient apiClient) : dio = apiClient.dio;

  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth',
        data: {'username': username, 'password': password},
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      if (loginResponse.token.isEmpty) {
        throw Exception('Token not received');
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', loginResponse.token);

      return loginResponse;
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Login failed');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
  }
}
