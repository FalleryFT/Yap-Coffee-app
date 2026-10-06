import 'package:flutter/material.dart';

import '../network/api_exception.dart';
import 'app_snackbar.dart';

/// Logika yang sama di semua form: status loading, galat per kolom dari server,
/// dan snackbar untuk galat umum. Pakai dengan: `with FormSubmitMixin<NamaPage>`.
mixin FormSubmitMixin<T extends StatefulWidget> on State<T> {
  bool loading = false;
  Map<String, List<String>> fieldErrors = const {};

  /// Galat server untuk [field], atau null bila tidak ada.
  String? serverError(String field) {
    final list = fieldErrors[field];
    return (list == null || list.isEmpty) ? null : list.first;
  }

  /// Hapus galat server sebuah kolom begitu pengguna mulai mengetik ulang.
  void clearServerError(String field) {
    if (!fieldErrors.containsKey(field)) return;
    final updated = Map<String, List<String>>.of(fieldErrors)..remove(field);
    setState(() => fieldErrors = updated);
  }

  /// Menampilkan galat API: per kolom bila ada, selain itu lewat snackbar.
  void showApiError(ApiException e) {
    if (!mounted) return;
    setState(() => fieldErrors = e.fieldErrors);
    if (e.fieldErrors.isEmpty) showAppSnackBar(context, e.message);
  }

  /// Menjalankan [action] dengan status loading dan penanganan galat.
  /// Mengembalikan true bila berhasil.
  Future<bool> submit(Future<void> Function() action) async {
    FocusScope.of(context).unfocus();
    setState(() {
      loading = true;
      fieldErrors = const {};
    });

    try {
      await action();
      return true;
    } on ApiException catch (e) {
      showApiError(e);
      return false;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}
