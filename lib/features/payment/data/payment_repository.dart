import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../orders/model/order_model.dart';
import '../model/snap_session.dart';

/// Satu-satunya jalur HTTP fitur pembayaran: sesi Midtrans (Snap) dan sinkronisasi status.
class PaymentRepository {
  PaymentRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  /// Membuat sesi pembayaran Midtrans (Snap) untuk pesanan yang belum dibayar.
  Future<SnapSession> createSnap(String code) => _guard(() async {
        final res = await _dio.post<Map<String, dynamic>>('/orders/$code/snap');
        return SnapSession.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  /// Mengambil pesanan terbaru. Untuk pesanan yang masih menunggu, server mencocokkannya
  /// dengan Midtrans lebih dulu (GET /orders/:code), jadi pembayaran yang webhook-nya belum
  /// sampai tetap tercatat lunas.
  Future<OrderModel> syncPayment(String code) => _guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/orders/$code');
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