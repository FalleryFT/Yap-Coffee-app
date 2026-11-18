import '../../menu/model/coffee_item_model.dart';
import '../../menu/model/menu_options.dart';

/// Satu baris keranjang: menu asal, varian terpilih, dan jumlahnya.
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
