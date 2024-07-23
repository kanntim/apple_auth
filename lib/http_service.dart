import 'dart:convert';

import 'package:apple_auth/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HttpUtil {
  factory HttpUtil() => _instance;

  HttpUtil._internal() {
    final options = BaseOptions(
      baseUrl: AppConstants.SERVER_API_URL,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {},
      contentType: 'application/json',
      responseType: ResponseType.json,
    );
    dio = Dio(options);
  }

  static final HttpUtil _instance = HttpUtil._internal();
  late Dio dio;

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    final requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    // final authorization = getAuthorizationHeader();
    // if (authorization.isNotEmpty) {
    //   requestOptions.headers!.addAll(authorization);
    // }

    try {
      print('base url: ${AppConstants.SERVER_API_URL}path: $path, data: $data');
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
      debugPrint('||||||||||||||||||||||||||||||||||||||||||||||||||||||||');
      debugPrint(e.response.toString());
      debugPrint('||||||||||||||||||||||||||||||||||||||||||||||||||||||||');
      rethrow;
    }
  }

  Future<dynamic> get(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    final requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    // final authorization = getAuthorizationHeader();
    // if (authorization.isNotEmpty) {
    //   requestOptions.headers!.addAll(authorization);
    // }
    try {
      final response = await dio.get<dynamic>(
        path,
        data: data,
        queryParameters: queryParams,
        options: requestOptions,
      );
      if (response.statusCode == 200) {
        return response.data!;
      } else {
        return {};
      }
    } on DioException catch (e) {
      debugPrint(
          '||||||||||||||||||||||||||ERROR||||||||||||||||||||||||||||||');
      debugPrint(e.response.toString());
      debugPrint(
          '||||||||||||||||||||||||||ERROR||||||||||||||||||||||||||||||');
      rethrow;
    }
  }

  // Map<String, dynamic> getAuthorizationHeader() {
  //   final headers = <String, dynamic>{};
  //   final accessToken = Globals.storageService.getUserAccessToken;
  //
  //   if (accessToken.isNotEmpty) {
  //     headers['Authorization'] = 'Bearer $accessToken';
  //   }
  //   return headers;
  // }
}
