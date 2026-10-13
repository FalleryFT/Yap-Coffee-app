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

  /// Default demo items matching Figma design in tampilan apps/Keranjang.svg
  final List<CartItem> _items = [
    CartItem(
      id: 'yap-latte-design',
      name: 'Yap Latte',
      variant: 'Reguler, Less Sugar',
      price: 22000,
      quantity: 1,
      imageAsset: 'assets/images/Keranjang.svg_0.jpeg',
      originalItem: CoffeeData.homeFavorites.firstWhere(
        (it) => it.id == 'yap-latte',
        orElse: () => CoffeeData.homeFavorites.first,
      ),
    ),
    CartItem(
      id: 'classic-croissant-design',
      name: 'Classic Croissant',
      variant: 'Toasted',
      price: 25000,
      quantity: 2,
      imageAsset: 'assets/images/Keranjang.svg_1.jpeg',
      originalItem: CoffeeData.homeFavorites.firstWhere(
        (it) => it.id == 'butter-croissant',
        orElse: () => CoffeeData.homeFavorites.last,
      ),
    ),
  ];

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
    final sizeText = size == CupSize.reguler ? 'Reguler' : 'Large';
    final sugarText = switch (sugar) {
      SugarLevel.normal => 'Normal',
      SugarLevel.lessSugar => 'Less Sugar',
      SugarLevel.noSugar => 'No Sugar',
    };
    final variantText = '$sizeText, $sugarText';
    final extraPrice = size == CupSize.large ? 5000 : 0;
    final unitPrice = item.price + extraPrice;

    final existingIndex = _items.indexWhere(
      (it) => it.name == item.name && it.variant == variantText,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      String imageToUse = item.imageAsset;
      if (item.name.toLowerCase().contains('latte')) {
        imageToUse = 'assets/images/Keranjang.svg_0.jpeg';
      } else if (item.name.toLowerCase().contains('croissant')) {
        imageToUse = 'assets/images/Keranjang.svg_1.jpeg';
      }

      _items.add(
        CartItem(
          id: '${DateTime.now().millisecondsSinceEpoch}_${item.id}',
          name: item.name,
          variant: variantText,
          price: unitPrice,
          quantity: quantity,
          imageAsset: imageToUse,
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
