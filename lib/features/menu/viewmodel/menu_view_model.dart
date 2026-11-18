import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/session/app_session.dart';
import '../../../core/viewmodel/load_status.dart';
import '../data/menu_repository.dart';
import '../model/coffee_item_model.dart';
import '../model/menu_options.dart';

/// Katalog menu yang dipakai bersama oleh Home dan Menu, dimuat sekali dari server.
class MenuViewModel extends ChangeNotifier {
  MenuViewModel({MenuRepository? repository})
      : _repository = repository ?? MenuRepository() {
    AppSession.registerResetter(clear);
  }

  static final MenuViewModel instance = MenuViewModel();

  final MenuRepository _repository;

  /// Label chip untuk "tanpa filter kategori".
  static const String allCategories = 'Semua Kopi';

  LoadStatus status = LoadStatus.idle;
  String? error;
  List<CoffeeItem> items = const [];
  List<String> categories = const [];

  /// Kategori yang sedang dipilih pada chip. Hanya state tampilan, bukan data server.
  String selectedCategory = allCategories;

  /// Teks yang sedang diketik di kolom cari.
  String searchQuery = '';

  List<String> get categoryChips => [allCategories, ...categories];

  /// Menu yang lolos filter kategori dan pencarian.
  List<CoffeeItem> get filteredItems {
    final query = searchQuery.toLowerCase();
    return items.where((item) {
      final matchesCategory = selectedCategory == allCategories ||
          item.category.toLowerCase() == selectedCategory.toLowerCase();
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void selectCategory(String category) {
    if (selectedCategory == category) return;
    selectedCategory = category;
    notifyListeners();
  }

  void setQuery(String query) {
    if (searchQuery == query) return;
    searchQuery = query;
    notifyListeners();
  }

  /// Ukuran dan tingkat manis yang diatur admin; bawaan sampai katalog termuat.
  MenuOptions options = MenuOptions.fallback;

  bool _busy = false;

  /// Satu menu menurut id-nya dari katalog yang sudah dimuat; null bila tidak ada.
  CoffeeItem? findById(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

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
      // Kategori yang dipilih bisa hilang setelah katalog dimuat ulang.
      if (selectedCategory != allCategories &&
          !categories.contains(selectedCategory)) {
        selectedCategory = allCategories;
      }
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
    selectedCategory = allCategories;
    searchQuery = '';
    notifyListeners();
  }
}
