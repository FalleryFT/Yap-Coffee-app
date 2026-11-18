import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/date_labels.dart';
import '../../cart/model/cart_item.dart';
import '../../cart/viewmodel/cart_view_model.dart';
import '../../menu/viewmodel/menu_view_model.dart';
import '../../orders/data/order_repository.dart';
import '../../orders/model/order_model.dart';
import '../../orders/viewmodel/order_view_model.dart';
import '../data/checkout_repository.dart';
import '../model/pickup_schedule.dart';

/// State halaman checkout: jadwal pengambilan, pilihan tanggal/jam, dan pembuatan pesanan.
/// Halaman hanya menampilkan state ini lalu mengurus navigasi dan snackbar.
class CheckoutViewModel extends ChangeNotifier {
  CheckoutViewModel({
    CheckoutRepository? repository,
    OrderRepository? orderRepository,
    CartViewModel? cart,
    OrderViewModel? orders,
    MenuViewModel? menu,
  })  : _repository = repository ?? CheckoutRepository(),
        _orderRepository = orderRepository ?? OrderRepository(),
        cart = cart ?? CartViewModel.instance,
        _orders = orders ?? OrderViewModel.instance,
        _menu = menu ?? MenuViewModel.instance {
    // Jumlah di keranjang bisa berubah dari halaman ini; tampilan ikut diperbarui.
    this.cart.addListener(_onCartChanged);
  }

  final CheckoutRepository _repository;
  final OrderRepository _orderRepository;
  final OrderViewModel _orders;
  final MenuViewModel _menu;

  /// Keranjang yang sedang di-checkout.
  final CartViewModel cart;

  List<PickupSchedule> schedules = const [];
  bool loadingSchedules = true;
  String? scheduleError;

  int selectedDate = 0;
  int selectedWindow = 0;

  bool submitting = false;

  /// Setelah pesanan dibuat keranjang dikosongkan; halaman ini tidak boleh menutup dirinya sendiri.
  bool submitted = false;

  /// Pesan galat yang perlu ditampilkan halaman sebagai snackbar; null bila tidak ada.
  String? errorMessage;

  List<CartItem> get items => cart.items;
  int get subtotal => cart.subtotal;
  int get tax => cart.tax;
  int get serviceFee => cart.serviceFee;
  int get grandTotal => cart.grandTotal;

  void updateQuantity(CartItem item, int delta) => cart.updateQuantity(item, delta);

  /// Tanggal unik, urut seperti dari server (sudah urut tanggal).
  List<String> get dateKeys {
    final keys = <String>[];
    for (final s in schedules) {
      if (!keys.contains(s.date)) keys.add(s.date);
    }
    return keys;
  }

  /// Kloter pada tanggal yang sedang dipilih.
  List<PickupSchedule> get schedulesOnSelectedDate {
    final keys = dateKeys;
    if (keys.isEmpty) return const [];
    final key = keys[selectedDate.clamp(0, keys.length - 1)];
    return schedules.where((s) => s.date == key).toList();
  }

  PickupSchedule? get selectedSchedule {
    final list = schedulesOnSelectedDate;
    if (list.isEmpty) return null;
    return list[selectedWindow.clamp(0, list.length - 1)];
  }

  /// Indeks kloter terpilih yang sudah dijepit ke jumlah kloter tanggal itu.
  int get clampedWindow {
    final list = schedulesOnSelectedDate;
    return list.isEmpty ? 0 : selectedWindow.clamp(0, list.length - 1);
  }

  /// Label hari/tanggal/bulan untuk chip tanggal pada tanggal ke-[index].
  ({String day, String date, String month}) dateLabel(int index) {
    final keys = dateKeys;
    if (index >= keys.length) return (day: '', date: keys.isEmpty ? '' : keys[index], month: '');
    final parsed = DateLabels.parse(keys[index]);
    if (parsed == null) return (day: '', date: keys[index], month: '');
    return (
      day: DateLabels.dayShort(parsed),
      date: DateLabels.dayOfMonth(parsed),
      month: DateLabels.monthShort(parsed),
    );
  }

  void selectDate(int index) {
    selectedDate = index;
    selectedWindow = 0;
    notifyListeners();
  }

  void selectWindow(int index) {
    selectedWindow = index;
    notifyListeners();
  }

  void _onCartChanged() {
    if (submitted) return;
    notifyListeners();
  }

  /// Memuat jadwal pengambilan yang masih dibuka.
  Future<void> loadSchedules() async {
    // Pemanggilan pertama dari initState: nilai awal sudah "memuat", jadi tidak perlu notify.
    if (!loadingSchedules) {
      loadingSchedules = true;
      scheduleError = null;
      notifyListeners();
    }
    try {
      final schedules = await _repository.fetchOpen();
      this.schedules = schedules;
      selectedDate = 0;
      selectedWindow = 0;
      loadingSchedules = false;
      notifyListeners();
    } on ApiException catch (e) {
      scheduleError = e.message;
      loadingSchedules = false;
      notifyListeners();
    }
  }

  String _firstError(ApiException e) {
    for (final key in const ['items', 'scheduleId']) {
      final message = e.errorFor(key);
      if (message != null) return message;
    }
    return e.message;
  }

  /// Membuat pesanan dari keranjang. Mengembalikan pesanan baru, atau null bila gagal.
  Future<OrderModel?> submit() async {
    final schedule = selectedSchedule;
    if (schedule == null || submitting) return null;

    final lines = <Map<String, dynamic>>[];
    for (final item in cart.items) {
      final menuId = item.originalItem?.apiId;
      if (menuId == null) {
        errorMessage =
            '${item.name} tidak valid. Hapus dari keranjang lalu pilih ulang.';
        notifyListeners();
        return null;
      }
      lines.add({
        'menuItemId': menuId,
        'qty': item.quantity,
        if (item.sizeLabel != null) 'size': item.sizeLabel,
        if (item.sugarLabel != null) 'sugarLevel': item.sugarLabel,
        if (item.addons.isNotEmpty) 'addonIds': item.addonIds,
      });
    }

    submitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      final order = await _orderRepository.create(
        scheduleId: schedule.id,
        items: lines,
      );
      submitted = true;
      _orders.upsert(order);
      cart.clearCart();
      return order;
    } on ApiException catch (e) {
      errorMessage = _firstError(e);
      // Stok atau jadwal bisa berubah; segarkan agar pilihan berikutnya akurat.
      _menu.load(force: true);
      loadSchedules();
      return null;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}
