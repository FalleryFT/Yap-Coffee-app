import '../../menu/model/coffee_item_model.dart';
import '../../orders/model/order_model.dart';

/// Kontak toko dari GET /api/home → store. Diatur admin di halaman Pengaturan web.
class StoreContact {
  const StoreContact({
    required this.name,
    required this.whatsapp,
    required this.whatsappUrl,
    required this.instagramUrl,
    required this.instagramHandle,
  });

  /// Nama outlet yang diatur admin.
  final String name;

  /// Contoh '+6281231242277'.
  final String whatsapp;

  /// Tautan wa.me untuk membuka percakapan; kosong bila nomor tidak valid.
  final String whatsappUrl;

  /// Tautan profil Instagram.
  final String instagramUrl;

  /// Contoh '@yap_coffee_'.
  final String instagramHandle;

  factory StoreContact.fromJson(Map<String, dynamic> json) {
    return StoreContact(
      name: (json['name'] as String?) ?? '',
      whatsapp: (json['whatsapp'] as String?) ?? '',
      whatsappUrl: (json['whatsappUrl'] as String?) ?? '',
      instagramUrl: (json['instagram'] as String?) ?? '',
      instagramHandle: (json['instagramHandle'] as String?) ?? '',
    );
  }
}

/// Isi GET /api/home: semua data layar Home dalam satu permintaan.
class HomeData {
  const HomeData({
    required this.firstName,
    required this.store,
    required this.readyOrder,
    required this.categories,
    required this.favorites,
  });

  /// Nama depan pelanggan untuk sapaan; kosong bila server tidak mengirimnya.
  final String firstName;
  final StoreContact store;

  /// Pesanan yang sudah lunas dan siap diambil, atau null.
  final OrderModel? readyOrder;
  final List<String> categories;

  /// Menu favorit (terlaris, masih ada stok). Bentuknya sama dengan elemen `items` pada GET /api/menu.
  final List<CoffeeItem> favorites;

  factory HomeData.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>;
    final ready = json['readyOrder'];

    return HomeData(
      firstName: (customer['firstName'] as String?) ?? '',
      store: StoreContact.fromJson(json['store'] as Map<String, dynamic>),
      readyOrder: ready == null
          ? null
          : OrderModel.fromJson(ready as Map<String, dynamic>),
      categories:
          (json['categories'] as List).map((e) => e as String).toList(),
      favorites: (json['favorites'] as List)
          .map((e) => CoffeeItem.fromApi(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
