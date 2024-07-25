import 'dart:convert';

import 'package:dio/dio.dart';

class HttpUtil {
  static final HttpUtil _instance = HttpUtil._internal();

  factory HttpUtil({String? url}) {
    _instance.dio.options.baseUrl = url ?? '';
    return _instance;
  }

  HttpUtil._internal() {
    final options = BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {},
      contentType: 'application/json',
      responseType: ResponseType.json,
    );
    dio = Dio(options);
  }

  late Dio dio;

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    final requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParams,
        options: requestOptions,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.data);
      } else {
        return {};
      }
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    final requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    try {
      final response = await dio.get<dynamic>(
        path,
        data: data,
        queryParameters: queryParams,
        options: requestOptions,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.data!);
      } else {
        return {};
      }
    } on DioException catch (e) {
      rethrow;
    }
  }
}
