import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/currency.dart';
import 'coffee_image.dart';
import '../../features/menu/data/coffee_item_model.dart';

/// Kartu menu ringkas untuk grid Home dan Menu.
///
/// Tinggi gambar dibuat tetap dan isi teks memakai jarak yang cukup supaya
/// kartu tidak sesak dan deskripsi punya sedikit ruang sebelum harga.
///
/// Dua area sentuh yang berbeda:
///  - gambar, nama, dan deskripsi → [onTap] (buka detail menu)
///  - harga dan tanda plus → [onAdd] (tambah ke keranjang)
class AppMenuCard extends StatelessWidget {
  const AppMenuCard({
    super.key,
    required this.item,
    this.onTap,
    this.onAdd,
    this.imageHeight = 190,
    this.padding = const EdgeInsets.fromLTRB(8, 9, 8, 9),
  });

  final CoffeeItem item;
  /// Membuka halaman detail menu.
  final VoidCallback? onTap;

  /// Menambahkan menu ke keranjang.
  final VoidCallback? onAdd;
  final double imageHeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFECE7DE)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar + badge rating → detail menu
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CoffeeImage(asset: item.imageAsset, url: item.imageUrl),
                    if (item.rating != null)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x18000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_border_rounded,
                                size: 12,
                                color: Color(0xFF5D3E28),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                item.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF28180E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Nama + deskripsi → detail menu; baris harga + plus → tambah ke keranjang
            Expanded(
              child: Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onTap,
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF24150A),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF8A8076),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onAdd,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              rupiah(item.price),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF24150A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: item.isDarkPlusButton
                                  ? AppColors.buttonDark
                                  : AppColors.buttonPeach,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              size: 17,
                              color: item.isDarkPlusButton
                                  ? Colors.white
                                  : const Color(0xFF4A2B15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}
