import 'package:flutter/foundation.dart';

import '../../../core/session/app_session.dart';
import '../../menu/data/coffee_item_model.dart';
import '../../menu/data/menu_options.dart';

class CartItem {
  final String id;
  String name;
  String variant;
  int price;
  int quantity;
  String imageAsset;
  final CoffeeItem? originalItem;

  /// Pilihan pelanggan. [size] dan [sugar] null untuk menu tanpa pilihan (Makanan Ringan).
  SizeOption? size;
  SugarOption? sugar;
  List<MenuAddon> addons;

  CartItem({
    required this.id,
    required this.name,
    required this.variant,
    required this.price,
    this.quantity = 1,
    required this.imageAsset,
    this.originalItem,
    this.size,
    this.sugar,
    this.addons = const [],
  });

  /// Harga satuan (sudah termasuk ukuran dan tambahan) × jumlah.
  int get totalPrice => price * quantity;

  /// Foto unggahan admin, bila ada.
  String? get imageUrl => originalItem?.imageUrl;

  /// Ukuran untuk dikirim ke server; null untuk menu tanpa pilihan.
  String? get sizeLabel => size?.label;

  /// Tingkat manis untuk dikirim ke server; null untuk menu tanpa pilihan.
  String? get sugarLabel => sugar?.label;

  /// Id tambahan untuk dikirim ke server sebagai `addonIds`.
  List<int> get addonIds => addons.map((a) => a.id).toList();
}

class CartManager extends ChangeNotifier {
  static final CartManager instance = CartManager._internal();
  CartManager._internal() {
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
  /// Menu tanpa pilihan memakai "Porsi".
  static String variantFor(
    CoffeeItem item,
    SizeOption size,
    SugarOption sugar, [
    List<MenuAddon> addons = const [],
  ]) {
    final parts = <String>[
      if (item.hasOptions) ...[size.label, sugar.label] else 'Porsi',
      ..._sorted(addons).map((a) => a.label),
    ];
    return parts.join(', ');
  }

  /// Harga satuan: harga menu + tambahan ukuran (hanya menu yang punya pilihan) + semua tambahan.
  /// Sama dengan perhitungan server saat pesanan dibuat.
  static int unitPriceFor(
    CoffeeItem item,
    SizeOption size, [
    List<MenuAddon> addons = const [],
  ]) {
    final addonTotal = addons.fold<int>(0, (sum, a) => sum + a.extraPrice);
    return item.price + (item.hasOptions ? size.extraPrice : 0) + addonTotal;
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
    required SizeOption size,
    required SugarOption sugar,
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
    required SizeOption size,
    required SugarOption sugar,
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
