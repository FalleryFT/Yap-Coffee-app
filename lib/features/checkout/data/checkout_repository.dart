import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../model/pickup_schedule.dart';

/// Satu-satunya jalur HTTP fitur checkout: jadwal pengambilan yang masih dibuka.
class CheckoutRepository {
  CheckoutRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<List<PickupSchedule>> fetchOpen() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/schedules');
      return (res.data!['data'] as List)
          .map((e) => PickupSchedule.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on TypeError {
      throw const ApiException('Format respons server tidak sesuai.');
    }
  }
}
