import 'package:flutter/foundation.dart';

import '../../../core/session/app_session.dart';
import '../../menu/model/coffee_item_model.dart';
import '../../menu/model/menu_options.dart';
import '../model/cart_item.dart';

class CartViewModel extends ChangeNotifier {
  static final CartViewModel instance = CartViewModel._internal();
  CartViewModel._internal() {
    AppSession.registerResetter(() {
      _items.clear();
      _hasPressedPlus = false;
      notifyListeners();
    });
  }

  /// Tambahan diurutkan berdasarkan id supaya teks varian dan pengecekan baris yang sama stabil.
  static List<MenuAddon> _sorted(List<MenuAddon> addons) =>
      [...addons]..sort((a, b) => a.id.compareTo(b.id));

  /// Teks varian yang tampil di keranjang, contoh "Reguler, Less Sugar, Oat Milk".
  /// Makanan memakai "Porsi". Minuman yang admin tidak beri pilihan ukuran/manis dan tanpa
  /// tambahan memakai "Standar". [size] dan [sugar] null bila menu tidak punya pilihan itu.
  static String variantFor(
    CoffeeItem item,
    SizeOption? size,
    SugarOption? sugar, [
    List<MenuAddon> addons = const [],
  ]) {
    final parts = <String>[
      if (!item.hasOptions)
        'Porsi'
      else ...[
        if (size != null) size.label,
        if (sugar != null) sugar.label,
      ],
      ..._sorted(addons).map((a) => a.label),
    ];
    return parts.isEmpty ? 'Standar' : parts.join(', ');
  }

  /// Harga satuan: harga menu + tambahan ukuran (hanya menu yang punya pilihan) + semua tambahan.
  /// Sama dengan perhitungan server saat pesanan dibuat.
  static int unitPriceFor(
    CoffeeItem item,
    SizeOption? size, [
    List<MenuAddon> addons = const [],
  ]) {
    final addonTotal = addons.fold<int>(0, (sum, a) => sum + a.extraPrice);
    return item.price + (item.hasOptions ? (size?.extraPrice ?? 0) : 0) + addonTotal;
  }

  /// Keranjang mulai kosong; item hanya masuk saat pengguna menekan '+'.
  final List<CartItem> _items = [];

  /// Cart icon is hidden by default on Home/Menu until user taps '+' button.
  bool _hasPressedPlus = false;

  bool get hasPressedPlus => _hasPressedPlus;

  /// Icon keranjang hanya ada jika tombol plus di home dan menu dipencet
  bool get isCartButtonVisible => _hasPressedPlus && _items.isNotEmpty;

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItemCount => _items.fold(0, (sum, it) => sum + it.quantity);

  int get subtotal => _items.fold(0, (sum, it) => sum + it.totalPrice);

  int get tax => (subtotal * 0.11).round();

  int get serviceFee => _items.isEmpty ? 0 : 2000;

  int get grandTotal => subtotal + tax + serviceFee;

  /// Triggered as soon as the '+' button in Home or Menu is pressed
  void triggerPlusPressed() {
    _hasPressedPlus = true;
    notifyListeners();
  }

  void addCoffeeItem({
    required CoffeeItem item,
    required int quantity,
    SizeOption? size,
    SugarOption? sugar,
    List<MenuAddon> addons = const [],
  }) {
    _hasPressedPlus = true;
    final chosenAddons = _sorted(addons);
    final variantText = variantFor(item, size, sugar, chosenAddons);
    final unitPrice = unitPriceFor(item, size, chosenAddons);

    final existingIndex = _items.indexWhere(
      (it) => it.originalItem?.id == item.id && it.variant == variantText,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          id: '${DateTime.now().millisecondsSinceEpoch}_${item.id}',
          name: item.name,
          variant: variantText,
          price: unitPrice,
          quantity: quantity,
          imageAsset: item.imageAsset,
          originalItem: item,
          size: item.hasOptions ? size : null,
          sugar: item.hasOptions ? sugar : null,
          addons: chosenAddons,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int delta) {
    item.quantity += delta;
    if (item.quantity <= 0) {
      _items.remove(item);
    }
    notifyListeners();
  }

  /// Mengubah pilihan satu baris keranjang (tombol "Ubah"). Bila hasilnya sama dengan baris lain
  /// untuk menu yang sama, kedua baris digabung.
  void updateOptions(
    CartItem item, {
    SizeOption? size,
    SugarOption? sugar,
    required List<MenuAddon> addons,
    required int quantity,
  }) {
    final original = item.originalItem;
    if (original == null) return;

    final chosenAddons = _sorted(addons);
    final variantText = variantFor(original, size, sugar, chosenAddons);

    final duplicate = _items.where(
      (it) =>
          !identical(it, item) &&
          it.originalItem?.id == original.id &&
          it.variant == variantText,
    );
    if (duplicate.isNotEmpty) {
      duplicate.first.quantity += quantity;
      _items.remove(item);
      notifyListeners();
      return;
    }

    item.variant = variantText;
    item.price = unitPriceFor(original, size, chosenAddons);
    item.size = original.hasOptions ? size : null;
    item.sugar = original.hasOptions ? sugar : null;
    item.addons = chosenAddons;
    item.quantity = quantity;
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}