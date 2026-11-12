import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/session/app_session.dart';
import '../../menu/data/menu_store.dart' show LoadStatus;
import 'notification_model.dart';

class NotificationRepository {
  NotificationRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<InboxFeed> fetch() => _guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/notifications');
        return InboxFeed.fromJson(res.data!['data'] as Map<String, dynamic>);
      });

  Future<void> markRead(int id) => _guard(() async {
        await _dio.post<Map<String, dynamic>>('/notifications/$id/read');
      });

  Future<void> markAllRead() => _guard(() async {
        await _dio.post<Map<String, dynamic>>('/notifications/read');
      });

  Future<void> setEnabled(bool enabled) => _guard(() async {
        await _dio.put<Map<String, dynamic>>(
          '/notifications/settings',
          data: {'enabled': enabled},
        );
      });

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on TypeError {
      throw const ApiException('Format respons server tidak sesuai.');
    }
  }
}

/// Kotak masuk notifikasi pelanggan: pesanan siap diambil dan menu baru.
///
/// Selama aplikasi terbuka, server ditanya tiap [pollInterval]. Notifikasi yang baru muncul
/// dikirim lewat [arrivals] supaya layar utama bisa menampilkannya sebagai banner. Notifikasi
/// saat aplikasi tertutup membutuhkan push (FCM), yang belum dipasang.
class NotificationStore extends ChangeNotifier {
  NotificationStore._() {
    AppSession.registerResetter(_reset);
  }

  static final NotificationStore instance = NotificationStore._();

  static const Duration pollInterval = Duration(seconds: 30);

  final NotificationRepository repository = NotificationRepository();

  LoadStatus status = LoadStatus.idle;
  String? error;
  List<InboxNotification> items = const [];
  int unreadCount = 0;

  /// Saklar Notifikasi. Nilai awal true sampai data pertama dari server tiba.
  bool enabled = true;

  final StreamController<InboxNotification> _arrivals =
      StreamController<InboxNotification>.broadcast();

  /// Notifikasi yang baru muncul sejak pemuatan sebelumnya (tidak termasuk yang sudah ada saat masuk).
  Stream<InboxNotification> get arrivals => _arrivals.stream;

  Timer? _timer;
  bool _busy = false;

  /// Id terbesar yang sudah pernah dilihat. Null sebelum pemuatan pertama berhasil, sehingga
  /// notifikasi lama tidak tampil sebagai banner saat pengguna baru masuk.
  int? _lastSeenId;

  /// Mulai memuat sekarang dan berkala. Dipanggil saat layar utama tampil atau aplikasi kembali dibuka.
  void startPolling() {
    _timer?.cancel();
    load();
    _timer = Timer.periodic(pollInterval, (_) {
      if (enabled) load();
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> load() async {
    if (_busy) return;
    _busy = true;

    final hadData = status == LoadStatus.ready;
    if (!hadData) {
      status = LoadStatus.loading;
      error = null;
      notifyListeners();
    }

    try {
      final feed = await repository.fetch();
      final previous = _lastSeenId;
      final newest =
          feed.items.fold<int>(0, (best, it) => math.max(best, it.id));

      enabled = feed.enabled;
      items = feed.items;
      unreadCount = feed.unreadCount;
      status = LoadStatus.ready;
      error = null;

      if (previous != null && feed.enabled) {
        final fresh = feed.items
            .where((it) => it.id > previous && !it.read)
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
        for (final item in fresh) {
          _arrivals.add(item);
        }
      }
      if (previous == null || newest > previous) _lastSeenId = newest;
    } on ApiException catch (e) {
      error = e.message;
      status = hadData ? LoadStatus.ready : LoadStatus.error;
    } finally {
      _busy = false;
    }
    notifyListeners();
  }

  /// Saklar Notifikasi di Profil. Tampilan langsung berubah; bila server menolak, dikembalikan
  /// dan galatnya dilempar ulang.
  Future<void> setEnabled(bool value) async {
    final previous = enabled;
    enabled = value;
    notifyListeners();
    try {
      await repository.setEnabled(value);
      if (value) await load();
    } on ApiException {
      enabled = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markRead(InboxNotification item) async {
    if (item.read) return;
    items = [for (final it in items) it.id == item.id ? it.asRead() : it];
    unreadCount = math.max(0, unreadCount - 1);
    notifyListeners();
    try {
      await repository.markRead(item.id);
    } on ApiException {
      // Gagal sesaat: muat ulang agar penghitung kembali sesuai server.
      await load();
    }
  }

  Future<void> markAllRead() async {
    if (unreadCount == 0) return;
    items = [for (final it in items) it.asRead()];
    unreadCount = 0;
    notifyListeners();
    try {
      await repository.markAllRead();
    } on ApiException {
      await load();
    }
  }

  void _reset() {
    stopPolling();
    status = LoadStatus.idle;
    error = null;
    items = const [];
    unreadCount = 0;
    enabled = true;
    _lastSeenId = null;
    notifyListeners();
  }
}
