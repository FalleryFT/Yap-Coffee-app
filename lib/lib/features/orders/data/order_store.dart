import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/session/app_session.dart';
import '../../menu/data/menu_store.dart' show LoadStatus;
import 'order_model.dart';

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

/// Pesanan milik pengguna yang sedang login, dipakai Home, Pesanan, dan Pembayaran.
class OrderStore extends ChangeNotifier {
  OrderStore._() {
    AppSession.registerResetter(clear);
  }

  static final OrderStore instance = OrderStore._();

  final OrderRepository repository = OrderRepository();

  LoadStatus status = LoadStatus.idle;
  String? error;
  List<OrderModel> active = const [];
  List<OrderModel> history = const [];

  bool _busy = false;

  /// Pesanan aktif pertama yang sudah ditandai siap diambil, atau null.
  OrderModel? get readyOrder {
    for (final order in active) {
      if (order.status == OrderStatus.siapDiambil) return order;
    }
    return null;
  }

  /// Satu pesanan menurut kodenya (WK-8493), dari daftar aktif atau riwayat. null bila tidak ada.
  OrderModel? findById(String id) {
    for (final order in [...active, ...history]) {
      if (order.id == id) return order;
    }
    return null;
  }

  /// Memuat pesanan aktif dan riwayat. Data lama tetap tampil selama memuat ulang.
  Future<void> load() async {
    if (_busy) return;
    _busy = true;

    final hadData = status == LoadStatus.ready;
    if (!hadData) {
      status = LoadStatus.loading;
      error = null;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        repository.list(active: true),
        repository.list(active: false),
      ]);
      active = results[0];
      history = results[1];
      status = LoadStatus.ready;
      error = null;
    } on ApiException catch (e) {
      error = e.message;
      status = hadData ? LoadStatus.ready : LoadStatus.error;
    } finally {
      _busy = false;
    }
    notifyListeners();
  }

  /// Memasukkan atau memperbarui satu pesanan tanpa menunggu muat ulang penuh.
  void upsert(OrderModel order) {
    final inActive = active.indexWhere((o) => o.id == order.id);
    final inHistory = history.indexWhere((o) => o.id == order.id);

    final nextActive = List<OrderModel>.of(active);
    final nextHistory = List<OrderModel>.of(history);
    if (inActive >= 0) nextActive.removeAt(inActive);
    if (inHistory >= 0) nextHistory.removeAt(inHistory);

    if (order.isActive) {
      nextActive.insert(0, order);
    } else {
      nextHistory.insert(0, order);
    }
    active = nextActive;
    history = nextHistory;
    if (status != LoadStatus.ready) status = LoadStatus.ready;
    notifyListeners();
  }

  void clear() {
    status = LoadStatus.idle;
    error = null;
    active = const [];
    history = const [];
    notifyListeners();
  }
}
