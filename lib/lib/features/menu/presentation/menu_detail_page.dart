import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/coffee_image.dart';
import '../component/add_to_cart_sheet.dart';
import '../data/coffee_item_model.dart';
import '../data/menu_store.dart';

/// Detail satu menu: foto besar, nama, harga, deskripsi lengkap, dan tambahan yang tersedia.
/// Dibuka dengan menyentuh gambar, nama, atau deskripsi pada kartu menu.
class MenuDetailPage extends StatelessWidget {
  const MenuDetailPage({super.key, required this.item});

  final CoffeeItem item;

  static Future<void> open(BuildContext context, CoffeeItem item) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => MenuDetailPage(item: item)),
    );
  }

  String get _stockLabel {
    if (item.soldOut) return 'Habis';
    final stock = item.stock;
    if (stock != null && stock <= 5) return 'Tersisa $stock';
    return 'Tersedia';
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 320,
                        width: double.infinity,
                        child: CoffeeImage(
                          asset: item.imageAsset,
                          url: item.imageUrl,
                          height: 320,
                          width: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: topInset + 8,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.espresso,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Chip(
                              label: item.category,
                              background: const Color(0xFFF2E2D4),
                              foreground: AppColors.textDark,
                            ),
                            _Chip(
                              label: _stockLabel,
                              background: item.soldOut
                                  ? const Color(0xFFFBDAD8)
                                  : const Color(0xFFDDE6BC),
                              foreground: item.soldOut
                                  ? const Color(0xFFB3261E)
                                  : AppColors.textDark,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          rupiah(item.price),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.espresso,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Color(0xFFECE7DE)),
                        const SizedBox(height: 20),
                        const _SectionTitle('Deskripsi'),
                        const SizedBox(height: 8),
                        Text(
                          item.description.isEmpty
                              ? 'Belum ada deskripsi untuk menu ini.'
                              : item.description,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.bark,
                          ),
                        ),
                        if (item.hasOptions) ...[
                          const SizedBox(height: 22),
                          const _SectionTitle('Pilihan'),
                          const SizedBox(height: 8),
                          Text(
                            MenuStore.instance.options.summary,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: AppColors.bark,
                            ),
                          ),
                        ],
                        if (item.addons.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          const _SectionTitle('Tambahan'),
                          const SizedBox(height: 10),
                          for (final addon in item.addons)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      addon.label,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    addon.extraPrice > 0
                                        ? '+ ${rupiah(addon.extraPrice)}'
                                        : 'Gratis',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: AppColors.cream,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed:
                      item.soldOut ? null : () => openAddToCartSheet(context, item),
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                  label: Text(
                    item.soldOut ? 'Stok Habis' : 'Tambah ke Keranjang',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonDark,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFD5CEBF),
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}
