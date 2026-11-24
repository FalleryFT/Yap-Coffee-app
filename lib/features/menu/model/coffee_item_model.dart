import 'menu_options.dart';
import '../../../core/config/api_config.dart';

/// Menentukan sumber gambar dari nilai yang dikirim API.
/// [asset] kosong berarti tidak ada gambar lokal (memakai [url] atau ikon pengganti).
({String asset, String? url}) resolveMenuImage(String? image) {
  if (image == null || image.isEmpty) return (asset: '', url: null);
  if (ApiConfig.isRemoteImage(image)) return (asset: '', url: image);
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

  /// Minuman (true): boleh punya pilihan ukuran dan tingkat manis. Makanan (false): tanpa pilihan.
  /// Ditentukan admin lewat Jenis Menu saat menu dibuat, bukan dari nama kategori.
  final bool hasOptions;

  /// Ukuran gelas menu ini (diatur admin per menu). Kosong = tanpa pilihan ukuran.
  final List<SizeOption> sizes;

  /// Tingkat manis menu ini (diatur admin per menu). Kosong = tanpa pilihan manis.
  final List<SugarOption> sugarLevels;

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
    this.sizes = const [],
    this.sugarLevels = const [],
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
      sizes: ((json['sizes'] as List?) ?? const [])
          .map((e) => SizeOption.fromApi(e as Map<String, dynamic>))
          .toList(),
      sugarLevels: ((json['sugarLevels'] as List?) ?? const [])
          .map((e) => SugarOption.fromApi(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Ada pilihan ukuran yang harus dipilih pelanggan.
  bool get hasSizeChoices => hasOptions && sizes.isNotEmpty;

  /// Ada pilihan tingkat manis yang harus dipilih pelanggan.
  bool get hasSugarChoices => hasOptions && sugarLevels.isNotEmpty;

  /// Ukuran bawaan; null bila menu ini tanpa pilihan ukuran.
  SizeOption? get defaultSize {
    if (!hasSizeChoices) return null;
    return sizes.firstWhere((s) => s.isDefault, orElse: () => sizes.first);
  }

  /// Tingkat manis bawaan; null bila menu ini tanpa pilihan manis.
  SugarOption? get defaultSugar {
    if (!hasSugarChoices) return null;
    return sugarLevels.firstWhere((s) => s.isDefault,
        orElse: () => sugarLevels.first);
  }

  /// Ukuran dengan nama ini; bila sudah tidak ada (admin mengubah daftar), yang bawaan.
  SizeOption? sizeByLabel(String? label) {
    if (!hasSizeChoices) return null;
    return sizes.firstWhere((s) => s.label == label, orElse: () => defaultSize!);
  }

  /// Tingkat manis dengan nama ini; bila sudah tidak ada, yang bawaan.
  SugarOption? sugarByLabel(String? label) {
    if (!hasSugarChoices) return null;
    return sugarLevels.firstWhere((s) => s.label == label,
        orElse: () => defaultSugar!);
  }

  /// Ringkasan pilihan untuk halaman detail menu; kosong bila menu tanpa pilihan.
  String get optionsSummary {
    final lines = <String>[
      if (hasSizeChoices)
        'Ukuran: ${sizes.map((s) => s.caption.isEmpty ? s.label : '${s.label} (${s.caption})').join(', ')}.',
      if (hasSugarChoices)
        'Tingkat manis: ${sugarLevels.map((s) => s.label).join(', ')}.',
    ];
    return lines.join('\n');
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
/// Ukuran dan tingkat manis ada di tiap [CoffeeItem].
class MenuCatalog {
  const MenuCatalog({
    required this.categories,
    required this.items,
  });

  final List<String> categories;
  final List<CoffeeItem> items;
}