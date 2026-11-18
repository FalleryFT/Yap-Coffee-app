import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/session/app_session.dart';
import '../../../core/viewmodel/load_status.dart';
import '../../menu/model/coffee_item_model.dart';
import '../../menu/viewmodel/menu_view_model.dart';
import '../../orders/model/order_model.dart';
import '../data/home_repository.dart';
import '../model/home_model.dart';

/// Data layar Home. Dimuat sekali, lalu disegarkan saat tab Home dibuka kembali.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({HomeRepository? repository, MenuViewModel? menu})
      : _repository = repository ?? HomeRepository(),
        _menu = menu ?? MenuViewModel.instance {
    AppSession.registerResetter(clear);
    // Katalog menu dipakai untuk chip kategori dan daftar saat difilter.
    _menu.addListener(_onMenuChanged);
  }

  static final HomeViewModel instance = HomeViewModel();

  /// Label chip untuk "tanpa filter kategori".
  static const String allCategories = 'Semua Kopi';

  /// Jumlah menu yang ditampilkan di "Menu Favorit Tetangga" bila tanpa filter kategori.
  static const int _favoriteCount = 6;

  final HomeRepository _repository;
  final MenuViewModel _menu;

  LoadStatus status = LoadStatus.idle;
  String? error;
  HomeData? data;

  /// Kategori yang sedang dipilih pada chip. Hanya state tampilan, bukan data server.
  String selectedCategory = allCategories;

  bool _busy = false;

  String get firstName => data?.firstName ?? '';
  StoreContact? get store => data?.store;
  String get instagramHandle => data?.store.instagramHandle ?? '';
  OrderModel? get readyOrder => data?.readyOrder;
  List<String> get categories => data?.categories ?? const [];
  List<CoffeeItem> get favorites => data?.favorites ?? const [];

  /// Nama kategori untuk chip. Katalog menu dipakai bila sudah dimuat; selama belum,
  /// kategori dari GET /api/home supaya chip tidak kosong.
  List<String> get categoryNames =>
      _menu.categories.isNotEmpty ? _menu.categories : categories;

  List<String> get categoryChips => [allCategories, ...categoryNames];

  /// Tanpa filter: menu favorit dari server. Bila /home gagal tetapi katalog sudah ada,
  /// jatuh ke enam menu pertama yang stoknya masih ada. Dengan filter: seluruh menu kategori itu.
  List<CoffeeItem> get displayedItems {
    if (selectedCategory == allCategories) {
      if (status == LoadStatus.ready) return favorites;
      return _menu.items.where((it) => !it.soldOut).take(_favoriteCount).toList();
    }
    return _menu.items.where((it) => it.category == selectedCategory).toList();
  }

  /// Status muat untuk daftar yang sedang tampil.
  LoadStatus get listStatus {
    if (selectedCategory != allCategories) return _menu.status;
    if (status == LoadStatus.ready || _menu.status == LoadStatus.ready) {
      return LoadStatus.ready;
    }
    if (status == LoadStatus.error && _menu.status == LoadStatus.error) {
      return LoadStatus.error;
    }
    return LoadStatus.loading;
  }

  String get listError =>
      (selectedCategory == allCategories ? error : null) ??
      _menu.error ??
      'Menu belum bisa dimuat.';

  void selectCategory(String category) {
    if (selectedCategory == category) return;
    selectedCategory = category;
    notifyListeners();
  }

  void retry() {
    _menu.load(force: true);
    load(force: true);
  }

  /// Kategori yang dipilih bisa hilang setelah katalog menu dimuat ulang.
  void _onMenuChanged() {
    if (selectedCategory != allCategories &&
        !categoryNames.contains(selectedCategory)) {
      selectedCategory = allCategories;
    }
    notifyListeners();
  }

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
    selectedCategory = allCategories;
    notifyListeners();
  }
}
