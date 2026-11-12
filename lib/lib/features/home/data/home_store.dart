import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/session/app_session.dart';
import '../../menu/data/coffee_item_model.dart';
import '../../menu/data/menu_store.dart' show LoadStatus;
import '../../orders/data/order_model.dart';

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

class HomeRepository {
  HomeRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<HomeData> fetch() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/home');
      return HomeData.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on TypeError {
      throw const ApiException('Format respons server tidak sesuai.');
    }
  }
}

/// Data layar Home. Dimuat sekali, lalu disegarkan saat tab Home dibuka kembali.
class HomeStore extends ChangeNotifier {
  HomeStore._() {
    AppSession.registerResetter(clear);
  }

  static final HomeStore instance = HomeStore._();

  final HomeRepository _repository = HomeRepository();

  LoadStatus status = LoadStatus.idle;
  String? error;
  HomeData? data;

  bool _busy = false;

  String get firstName => data?.firstName ?? '';
  StoreContact? get store => data?.store;
  String get instagramHandle => data?.store.instagramHandle ?? '';
  OrderModel? get readyOrder => data?.readyOrder;
  List<String> get categories => data?.categories ?? const [];
  List<CoffeeItem> get favorites => data?.favorites ?? const [];

  /// Memuat data Home. Tanpa [force], data yang sudah ada tidak dimuat ulang.
  /// Saat memuat ulang, data lama tetap tampil sampai data baru tiba.
  Future<void> load({bool force = false}) async {
    if (_busy) return;
    if (status == LoadStatus.ready && !force) return;

    _busy = true;
    final hadData = data != null;
    if (!hadData) {
      status = LoadStatus.loading;
      error = null;
      notifyListeners();
    }

    try {
      data = await _repository.fetch();
      status = LoadStatus.ready;
      error = null;
    } on ApiException catch (e) {
      error = e.message;
      status = hadData ? LoadStatus.ready : LoadStatus.error;
    } finally {
      _busy = false;
    }
    notifyListeners();
  }

  void clear() {
    status = LoadStatus.idle;
    error = null;
    data = null;
    notifyListeners();
  }
}
