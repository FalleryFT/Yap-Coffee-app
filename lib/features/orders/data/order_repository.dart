import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../model/order_model.dart';
import '../../payment/model/snap_session.dart';

/// Satu-satunya jalur HTTP fitur pesanan: daftar, detail, buat, bayar, batal.
class OrderRepository {
  OrderRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<List<OrderModel>> list({required bool active}) {
    return _guard(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/orders',
        queryParameters: {'tab': active ? 'active' : 'history'},
      );
      return (res.data!['data'] as List)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<OrderModel> get(String code) => _guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/orders/$code');
        return OrderModel.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  /// [items]: daftar {menuItemId, qty, size?, sugarLevel?}. Harga dihitung server.
  Future<OrderModel> create({
    required int scheduleId,
    required List<Map<String, dynamic>> items,
    String? note,
  }) {
    return _guard(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/orders',
        data: {
          'scheduleId': scheduleId,
          'items': items,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
      return OrderModel.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }
  /// Membuat sesi pembayaran Midtrans (Snap) untuk pesanan yang belum dibayar.
  Future<SnapSession> createSnap(String code) => _guard(() async {
        final res = await _dio.post<Map<String, dynamic>>('/orders/$code/snap');
        return SnapSession.fromJson(res.data!['data'] as Map<String, dynamic>);
      });
  /// Pelunasan simulasi (server harus PAYMENT_SIMULATED=true).
  Future<OrderModel> pay(String code) => _guard(() async {
        final res = await _dio.post<Map<String, dynamic>>('/orders/$code/pay');
        return OrderModel.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<OrderModel> cancel(String code) => _guard(() async {
        final res = await _dio.post<Map<String, dynamic>>('/orders/$code/cancel');
        return OrderModel.fromJson(res.data!['data'] as Map<String, dynamic>);
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
