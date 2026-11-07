import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/app_notification.dart';
import '../../../core/widgets/app_quantity_stepper.dart';
import '../../cart/data/cart_manager.dart';
import '../data/coffee_item_model.dart';

enum CupSize { reguler, large }

enum SugarLevel { normal, lessSugar, noSugar }

extension CupSizeX on CupSize {
  String get label => this == CupSize.reguler ? 'Reguler' : 'Large';

  int get extraPrice => this == CupSize.large ? 5000 : 0;

  String get detail =>
      this == CupSize.reguler ? '16 oz' : '+ Rp 5.000 (22 oz)';

  double get iconSize => this == CupSize.reguler ? 22 : 26;
}

extension SugarLevelX on SugarLevel {
  String get label => switch (this) {
        SugarLevel.normal => 'Normal',
        SugarLevel.lessSugar => 'Less Sugar',
        SugarLevel.noSugar => 'No Sugar',
      };
}

/// Sheet pilihan ukuran, tingkat manis, dan jumlah sebelum masuk keranjang.
class AddToCartSheet extends StatefulWidget {
  final CoffeeItem item;
  final void Function(
    CoffeeItem item,
    int quantity,
    CupSize size,
    SugarLevel sugar,
  )? onAddToCart;

  const AddToCartSheet({
    super.key,
    required this.item,
    this.onAddToCart,
  });

  static Future<void> show(
    BuildContext context, {
    required CoffeeItem item,
    void Function(CoffeeItem item, int quantity, CupSize size, SugarLevel sugar)?
        onAddToCart,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToCartSheet(
        item: item,
        onAddToCart: onAddToCart,
      ),
    );
  }

  @override
  State<AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<AddToCartSheet> {
  int _quantity = 1;
  CupSize _selectedSize = CupSize.reguler;
  SugarLevel _selectedSugar = SugarLevel.lessSugar;

  int get _calculatedPrice =>
      (widget.item.price + _selectedSize.extraPrice) * _quantity;

  String get _variantSummary =>
      '${_selectedSize.label}, ${_selectedSugar.label}';

  void _onAddPressed() {
    widget.onAddToCart?.call(
      widget.item,
      _quantity,
      _selectedSize,
      _selectedSugar,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.paddingOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tambahkan Menu',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.textDark,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SelectedItemSummaryCard(
            item: widget.item,
            variant: _variantSummary,
            totalPrice: _calculatedPrice,
            quantity: _quantity,
            onDecrement: () {
              if (_quantity > 1) setState(() => _quantity--);
            },
            onIncrement: () => setState(() => _quantity++),
          ),
          const SizedBox(height: 22),
          const Text(
            'Pilih Ukuran',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final size in CupSize.values) ...[
                if (size != CupSize.values.first) const SizedBox(width: 12),
                Expanded(
                  child: CupSizeOption(
                    title: size.label,
                    detail: size.detail,
                    iconSize: size.iconSize,
                    isSelected: _selectedSize == size,
                    onTap: () => setState(() => _selectedSize = size),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Tingkat Manis',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final sugar in SugarLevel.values) ...[
                if (sugar != SugarLevel.values.first) const SizedBox(width: 10),
                SugarLevelChip(
                  label: sugar.label,
                  isSelected: _selectedSugar == sugar,
                  onTap: () => setState(() => _selectedSugar = sugar),
                ),
              ],
            ],
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _onAddPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Masukan Keranjang',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Alur standar: buka sheet, tambahkan ke keranjang, lalu tampilkan
/// notifikasi "ditambahkan ke keranjang" di atas layar.
Future<void> openAddToCartSheet(BuildContext context, CoffeeItem item) {
  return AddToCartSheet.show(
    context,
    item: item,
    onAddToCart: (coffeeItem, quantity, size, sugar) {
      CartManager.instance.addCoffeeItem(
        item: coffeeItem,
        quantity: quantity,
        size: size,
        sugar: sugar,
      );
      AppNotification.cartAdded(
        context,
        itemName: coffeeItem.name,
        variant: '${size.label}, ${sugar.label}',
      );
    },
  );
}

/// Pilihan ukuran gelas (Reguler / Large).
class CupSizeOption extends StatelessWidget {
  const CupSizeOption({
    super.key,
    required this.title,
    required this.detail,
    required this.iconSize,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String detail;
  final double iconSize;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5D39) : const Color(0xFFE5DFD4),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.coffee_rounded,
              size: iconSize,
              color: isSelected
                  ? const Color(0xFF2C190D)
                  : const Color(0xFF5E4B3E),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip tingkat manis (Normal / Less Sugar / No Sugar).
class SugarLevelChip extends StatelessWidget {
  const SugarLevelChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5D39) : const Color(0xFFE5DFD4),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.textDark : const Color(0xFF3C2C20),
          ),
        ),
      ),
    );
  }
}

/// Ringkasan produk di dalam sheet "Tambahkan Menu": gambar, nama,
/// varian, harga, dan pengatur jumlah.
class SelectedItemSummaryCard extends StatelessWidget {
  const SelectedItemSummaryCard({
    super.key,
    required this.item,
    required this.variant,
    required this.totalPrice,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final CoffeeItem item;
  final String variant;
  final int totalPrice;
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final imageToUse = item.modalImageAsset ?? item.imageAsset;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECE7DE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imageToUse,
              width: 76,
              height: 76,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  variant,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rupiah(totalPrice),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    AppQuantityStepper(
                      quantity: quantity,
                      onDecrement: onDecrement,
                      onIncrement: onIncrement,
                      width: 88,
                      height: 32,
                      iconSize: 15,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
