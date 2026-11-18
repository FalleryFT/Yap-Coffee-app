import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/session/app_session.dart';
import '../../../core/viewmodel/load_status.dart';
import '../data/order_repository.dart';
import '../model/order_model.dart';

/// Pesanan milik pengguna yang sedang login, dipakai Home, Pesanan, dan Pembayaran.
class OrderViewModel extends ChangeNotifier {
  OrderViewModel({OrderRepository? repository})
      : _repository = repository ?? OrderRepository() {
    AppSession.registerResetter(clear);
  }

  static final OrderViewModel instance = OrderViewModel();

  final OrderRepository _repository;

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
        _repository.list(active: true),
        _repository.list(active: false),
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
