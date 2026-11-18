import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../auth/data/auth_repository.dart';
import '../../home/viewmodel/home_view_model.dart';
import '../../orders/data/order_repository.dart';
import '../../orders/model/order_model.dart';
import '../../orders/viewmodel/order_view_model.dart';

/// State halaman pembayaran: hitung mundur, pengecekan status berkala, dan pelunasan.
/// Halaman hanya menampilkan state ini lalu mengurus navigasi dan snackbar.
class PaymentViewModel extends ChangeNotifier {
  PaymentViewModel({
    required OrderModel order,
    OrderRepository? repository,
    AuthRepository? authRepository,
    OrderViewModel? orders,
    HomeViewModel? home,
    this.pollInterval = const Duration(seconds: 5),
  })  : _repository = repository ?? OrderRepository(),
        _authRepository = authRepository ?? AuthRepository(),
        _orders = orders ?? OrderViewModel.instance,
        _home = home ?? HomeViewModel.instance,
        _order = order,
        // Batas bayar dihitung dari sisa waktu menurut server, bukan dari jam perangkat.
        _deadline = DateTime.now().add(
          Duration(seconds: order.paymentSecondsLeft),
        );

  final OrderRepository _repository;
  final AuthRepository _authRepository;
  final OrderViewModel _orders;
  final HomeViewModel _home;

  /// Jeda pengecekan status pembayaran ke server.
  final Duration pollInterval;

  OrderModel _order;
  DateTime _deadline;

  String customerName = '';
  bool paying = false;
  bool refreshing = false;

  /// Waktu pembayaran habis dan pesanan dibatalkan server; halaman perlu menutup diri.
  bool cancelled = false;

  /// Pesan galat yang perlu ditampilkan halaman sebagai snackbar; null bila tidak ada.
  String? errorMessage;

  Timer? _timer;
  Timer? _poller;
  bool _disposed = false;

  OrderModel get order => _order;

  bool get paid =>
      _order.status != OrderStatus.belumDibayar &&
      _order.status != OrderStatus.dibatalkan;

  int get remaining {
    final seconds = _deadline.difference(DateTime.now()).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }

  String get timerText {
    final m = (remaining ~/ 60).toString().padLeft(2, '0');
    final s = (remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Nama outlet dari pengaturan admin; 'Yap Coffee' selama belum termuat.
  String get storeName {
    final name = _home.store?.name;
    return name != null && name.isNotEmpty ? name : 'Yap Coffee';
  }

  List<String> get orderLines =>
      _order.items.map((it) => '${it.qty}x ${it.name}').toList();

  /// Mulai hitung mundur dan pengecekan status berkala.
  void start() {
    loadCustomerName();

    if (paid) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (paid) return;
      if (remaining <= 0) {
        refresh();
        return;
      }
      _notify();
    });
    // Pelunasan lewat penyedia pembayaran terjadi di luar aplikasi, jadi status dicek berkala.
    _poller = Timer.periodic(pollInterval, (_) => refresh());
  }

  void stop() {
    _timer?.cancel();
    _poller?.cancel();
  }

  @override
  void dispose() {
    _disposed = true;
    stop();
    super.dispose();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
  }

  Future<void> loadCustomerName() async {
    try {
      final me = await _authRepository.me();
      customerName = me.name;
      _notify();
    } on ApiException {
      // Nama hanya hiasan tiket; tidak mengganggu pembayaran.
    }
  }

  /// Menyamakan status dan sisa waktu dengan server. Server yang memutuskan lunas atau kedaluwarsa.
  Future<void> refresh() async {
    if (refreshing || _disposed) return;
    refreshing = true;
    try {
      final latest = await _repository.get(_order.id);
      _applyOrder(latest);
    } on ApiException {
      // Gangguan jaringan sesaat; coba lagi pada putaran berikutnya.
    } finally {
      refreshing = false;
    }
  }

  void _applyOrder(OrderModel latest) {
    _orders.upsert(latest);

    if (latest.status == OrderStatus.dibatalkan) {
      stop();
      cancelled = true;
      _order = latest;
      _notify();
      return;
    }

    _order = latest;
    if (latest.status == OrderStatus.belumDibayar) {
      _deadline = DateTime.now().add(
        Duration(seconds: latest.paymentSecondsLeft),
      );
    }
    if (paid) stop();
    _notify();
  }

  /// Pelunasan simulasi untuk uji coba (server PAYMENT_SIMULATED=true).
  Future<void> pay() async {
    if (paying) return;
    paying = true;
    errorMessage = null;
    _notify();
    try {
      final paidOrder = await _repository.pay(_order.id);
      _applyOrder(paidOrder);
    } on ApiException catch (e) {
      errorMessage = e.message;
      // Status di server bisa lebih baru (mis. sudah lunas atau kedaluwarsa).
      if (e.statusCode == 409) refresh();
    } finally {
      paying = false;
      _notify();
    }
  }
}
