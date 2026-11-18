import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../model/home_model.dart';

/// Satu-satunya jalur HTTP fitur home: GET /api/home.
class HomeRepository {
  HomeRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<HomeData> fetch() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/home');
      return HomeData.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on TypeError {
      throw const ApiException('Format respons server tidak sesuai.');
    }
  }
}
