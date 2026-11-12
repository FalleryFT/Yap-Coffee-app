import 'package:flutter/material.dart';

import '../../../core/utils/external_links.dart';
import '../../../core/widgets/app_notification.dart';
import 'home_store.dart';

/// Membuka WhatsApp dan Instagram toko. Nomor dan akun diatur admin di web (Pengaturan)
/// dan dibaca lewat GET /api/home, jadi berubah tanpa perlu memperbarui aplikasi.
class StoreLinks {
  StoreLinks._();

  /// Kontak terbaru; bila Home belum sempat dimuat, dimuat dulu.
  static Future<StoreContact?> _contact() async {
    final home = HomeStore.instance;
    if (home.store == null) await home.load(force: true);
    return home.store;
  }

  static Future<void> openWhatsapp(BuildContext context) async {
    final contact = await _contact();
    if (!context.mounted) return;

    if (contact == null || contact.whatsappUrl.isEmpty) {
      AppNotification.error(
        context,
        'Kontak penjual belum tersedia. Coba lagi sebentar lagi.',
      );
      return;
    }

    final outlet = contact.name.isEmpty ? 'Yap Coffee' : contact.name;
    AppNotification.contactSeller(context, outletName: outlet);
    final greeting = 'Halo $outlet, saya ingin bertanya.';
    final url = '${contact.whatsappUrl}?text=${Uri.encodeComponent(greeting)}';
    final opened = await openExternalUrl(url);
    if (!opened && context.mounted) {
      AppNotification.error(
        context,
        'WhatsApp tidak bisa dibuka. Pastikan WhatsApp sudah terpasang.',
      );
    }
  }

  static Future<void> openInstagram(BuildContext context) async {
    final contact = await _contact();
    if (!context.mounted) return;

    if (contact == null || contact.instagramUrl.isEmpty) {
      AppNotification.error(
        context,
        'Akun Instagram belum tersedia. Coba lagi sebentar lagi.',
      );
      return;
    }

    final opened = await openExternalUrl(contact.instagramUrl);
    if (!opened && context.mounted) {
      AppNotification.error(context, 'Instagram tidak bisa dibuka.');
    }
  }
}
