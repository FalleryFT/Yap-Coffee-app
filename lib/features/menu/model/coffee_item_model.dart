import 'menu_options.dart';
import '../../../core/config/api_config.dart';

/// Foto yang diunggah admin diberi nama UUID oleh server; foto bawaan aplikasi
/// (yap_latte.png dan sebagainya) dimuat dari assets.
final RegExp _uploadedName = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-');

/// Menentukan sumber gambar dari nama berkas yang dikirim API.
/// [asset] kosong berarti tidak ada gambar (tampil ikon pengganti).
({String asset, String? url}) resolveMenuImage(String? image) {
  if (image == null || image.isEmpty) return (asset: '', url: null);
  if (_uploadedName.hasMatch(image)) {
    return (asset: '', url: ApiConfig.menuImageUrl(image));
  }
  return (asset: 'assets/images/$image', url: null);
}

/// Tambahan opsional untuk satu menu (contoh: Oat Milk +Rp 5.000). Harganya per gelas/porsi.
class MenuAddon {
  const MenuAddon({
    required this.id,
    required this.label,
    required this.extraPrice,
  });

  /// Id tambahan di database; dikirim sebagai `addonIds` saat checkout.
  final int id;
  final String label;
  final int extraPrice;

  factory MenuAddon.fromApi(Map<String, dynamic> json) {
    return MenuAddon(
      id: (json['id'] as num).toInt(),
      label: json['label'] as String,
      extraPrice: (json['extraPrice'] as num?)?.toInt() ?? 0,
    );
  }
}

class CoffeeItem {
  final String id;

  /// Id menu di database; dikirim ke server saat checkout.
  final int? apiId;
  final String name;
  final String description;
  final int price;
  final String category;
  final double? rating;
  final String imageAsset;

  /// Foto unggahan admin. Bila terisi, dipakai menggantikan [imageAsset].
  final String? imageUrl;
  final String? modalImageAsset;
  final bool isFavorite;
  final bool isDarkPlusButton;
  final bool soldOut;

  /// Sisa stok dari server; null untuk data bawaan aplikasi.
  final int? stock;

  /// Tambahan yang boleh dipilih pelanggan untuk menu ini.
  final List<MenuAddon> addons;

  /// Minuman (true): pelanggan memilih ukuran dan tingkat manis. Makanan (false): tanpa pilihan.
  /// Ditentukan admin per kategori, bukan dari nama kategori.
  final bool hasOptions;

  const CoffeeItem({
    required this.id,
    this.apiId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.rating,
    required this.imageAsset,
    this.imageUrl,
    this.modalImageAsset,
    this.isFavorite = false,
    this.isDarkPlusButton = false,
    this.soldOut = false,
    this.stock,
    this.addons = const [],
    this.hasOptions = true,
  });

  /// Dari elemen `items` pada GET /api/menu.
  factory CoffeeItem.fromApi(Map<String, dynamic> json) {
    final image = resolveMenuImage(json['image'] as String?);
    final apiId = (json['id'] as num).toInt();
    return CoffeeItem(
      id: '$apiId',
      apiId: apiId,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      price: (json['price'] as num).toInt(),
      category: json['category'] as String,
      imageAsset: image.asset,
      imageUrl: image.url,
      soldOut: json['soldOut'] == true,
      stock: (json['stock'] as num?)?.toInt(),
      addons: ((json['addons'] as List?) ?? const [])
          .map((e) => MenuAddon.fromApi(e as Map<String, dynamic>))
          .toList(),
      hasOptions: json['hasOptions'] != false,
    );
  }


  String get formattedPrice {
    final str = price.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }
}

/// Isi GET /api/menu: nama kategori dan daftar menu yang tersedia.
class MenuCatalog {
  const MenuCatalog({
    required this.categories,
    required this.items,
    this.options = MenuOptions.fallback,
  });

  final List<String> categories;
  final List<CoffeeItem> items;

  /// Ukuran dan tingkat manis yang diatur admin.
  final MenuOptions options;
}
