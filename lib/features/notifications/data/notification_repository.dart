import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../model/notification_model.dart';

/// Satu-satunya jalur HTTP fitur notifikasi: kotak masuk dan pengaturannya.
class NotificationRepository {
  NotificationRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<InboxFeed> fetch() => _guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/notifications');
        return InboxFeed.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<void> markRead(int id) => _guard(() async {
        await _dio.post<Map<String, dynamic>>('/notifications/$id/read');
      });

  Future<void> markAllRead() => _guard(() async {
        await _dio.post<Map<String, dynamic>>('/notifications/read');
      });

  Future<void> setEnabled(bool enabled) => _guard(() async {
        await _dio.put<Map<String, dynamic>>(
          '/notifications/settings',
          data: {'enabled': enabled},
        );
      });

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on TypeError {
      throw const ApiException('Format respons server tidak sesuai.');
    }
  }
}
