import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

class ApiClient {
  static const _baseUrl = 'https://api.edveo.co';

  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Mobile-Client': 'flutter',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(dio));
  }
}
