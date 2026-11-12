import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/session/app_session.dart';
import 'coffee_item_model.dart';
import 'menu_options.dart';

enum LoadStatus { idle, loading, ready, error }

class MenuRepository {
  MenuRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<MenuCatalog> fetchCatalog() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/menu');
      final data = res.data!['data'] as Map<String, dynamic>;
      return MenuCatalog(
        categories: (data['categories'] as List).map((e) => e as String).toList(),
        items: (data['items'] as List)
            .map((e) => CoffeeItem.fromApi(e as Map<String, dynamic>))
            .toList(),
        options: data['options'] is Map<String, dynamic>
            ? MenuOptions.fromApi(data['options'] as Map<String, dynamic>)
            : MenuOptions.fallback,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on TypeError {
      throw const ApiException('Format respons server tidak sesuai.');
    }
  }
}

/// Katalog menu yang dipakai bersama oleh Home dan Menu, dimuat sekali dari server.
class MenuStore extends ChangeNotifier {
  MenuStore._() {
    AppSession.registerResetter(clear);
  }

  static final MenuStore instance = MenuStore._();

  final MenuRepository _repository = MenuRepository();

  LoadStatus status = LoadStatus.idle;
  String? error;
  List<CoffeeItem> items = const [];
  List<String> categories = const [];

  /// Ukuran dan tingkat manis yang diatur admin; bawaan sampai katalog termuat.
  MenuOptions options = MenuOptions.fallback;

  bool _busy = false;

  /// Memuat katalog. Tanpa [force], katalog yang sudah ada tidak dimuat ulang.
  /// Saat memuat ulang, data lama tetap tampil sampai data baru tiba.
  Future<void> load({bool force = false}) async {
    if (_busy) return;
    if (status == LoadStatus.ready && !force) return;

    _busy = true;
    final hadData = items.isNotEmpty;
    if (!hadData) {
      status = LoadStatus.loading;
      error = null;
      notifyListeners();
    }

    try {
      final catalog = await _repository.fetchCatalog();
      items = catalog.items;
      categories = catalog.categories;
      options = catalog.options;
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
    items = const [];
    categories = const [];
    options = MenuOptions.fallback;
    notifyListeners();
  }
}
