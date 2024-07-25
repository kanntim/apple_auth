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
        ///Tests
        final testLoginRes = jsonEncode({
          "error_code": 1,
          "work_status": {
            "udid": "a0a5b1ca-0bba-4c2c-8264-5622444c605c",
            "user_info": {
              "login": "001399.69a9f24be4764a96bc101d6f7a73a46e.1431",
              "user_api_key": "ab4db082f006757ea4579fa1c9384f60",
              "type_login": "apple",
              "timeadd": "2024-06-08 23:28:49",
              "email": "",
              "date_last_login": "2024-07-24 16:53:39",
              "fl_block": "1",
              "vpn_time_expire": "",
              "vpn_time_expire_unixtime": "",
              "client_date_create": "2024-03-26 18:26:18",
              "client_date_create_unixtime": "1711466778",
              "tarif_info": {
                "tarif_id": "",
                "tarif_name": "",
                "tarif_cost_activation": "",
                "tarif_cost_per_mb": "",
                "tarif_days": "",
                "product_id": ""
              }
            }
          }
        });
        final testRegRes =
            jsonEncode({"error_code": 1, "work_status": "008926"});
        return jsonDecode(testLoginRes);

        ///End test
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
