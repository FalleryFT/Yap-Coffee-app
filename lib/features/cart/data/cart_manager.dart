import 'package:flutter/foundation.dart';

import '../../menu/data/coffee_item_model.dart';
import '../../menu/presentation/add_to_cart_bottom_sheet.dart';

class CartItem {
  final String id;
  String name;
  String variant;
  int price;
  int quantity;
  String imageAsset;
  final CoffeeItem? originalItem;

  CartItem({
    required this.id,
    required this.name,
    required this.variant,
    required this.price,
    this.quantity = 1,
    required this.imageAsset,
    this.originalItem,
  });

  int get totalPrice => price * quantity;
}

class CartManager extends ChangeNotifier {
  static final CartManager instance = CartManager._internal();
  CartManager._internal();

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
    required CupSize size,
    required SugarLevel sugar,
  }) {
    _hasPressedPlus = true;
    final variantText = '${size.label}, ${sugar.label}';
    final unitPrice = item.price + size.extraPrice;

    final existingIndex = _items.indexWhere(
      (it) => it.name == item.name && it.variant == variantText,
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

  void updateVariant(CartItem item, String newVariant, int newPrice) {
    item.variant = newVariant;
    item.price = newPrice;
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
