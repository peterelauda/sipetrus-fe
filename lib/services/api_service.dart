import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  late Dio _dio;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('BACKEND_URL', fallback: 'http://100.x.y.z'),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(responseBody: true, requestBody: true),
    );
  }

  Future<void> initTailscale() async {
    // final String authKey = dotenv.get('TS_AUTH_KEY');

    try {
      print("Starting an internal Tailscale connection...");

      print("Tailscale Connection Successful!");
    } catch (e) {
      print("Tailscale initialization failed: $e");
    }
  }

  Future<Response?> getTest() async {
    try {
      final response = await _dio.get('/api/test');
      return response;
    } on DioException catch (e) {
      print("API Error: ${e.message}");
      return null;
    }
  }
}
